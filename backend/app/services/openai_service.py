"""OpenAI service for ingredient detection and recipe generation"""
from openai import OpenAI
from typing import List, Dict, Any, Optional
import base64
import uuid
from app.config import settings
from app.services.language_strings import (
    INGREDIENT_DETECTION_PROMPTS,
    NON_FOOD_KEYWORDS,
    ERROR_MESSAGES,
)


class OpenAIService:
    """Service for OpenAI API interactions"""
    
    def __init__(self):
        self.client = OpenAI(api_key=settings.openai_api_key)
        self.vision_model = settings.openai_model_vision
        self.text_model = settings.openai_model_text
        self.max_tokens = settings.openai_max_tokens
        self.temperature = settings.openai_temperature
    
    async def detect_ingredients(
        self,
        images: List[bytes],
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Detect ingredients from images using OpenAI Vision API
        
        Args:
            images: List of image bytes
            language: Language code for ingredient names
            
        Returns:
            Dict with ingredients, detection_id, and confidence
        """
        # Prepare image content for API
        image_contents = []
        for img_bytes in images:
            # Encode image as base64
            base64_image = base64.b64encode(img_bytes).decode('utf-8')
            image_contents.append({
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/jpeg;base64,{base64_image}"
                }
            })
        
        # Get language-specific prompt for ingredient detection
        prompt = INGREDIENT_DETECTION_PROMPTS.get(language, INGREDIENT_DETECTION_PROMPTS["en"])
        
        try:
            # COST REDUCTION: Strict token limit for ingredient detection (100-200 tokens is enough)
            # This dramatically reduces cost since vision API charges per token
            detection_max_tokens = 150  # Enough for ~10 ingredients
            
            response = self.client.chat.completions.create(
                model=self.vision_model,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": prompt},
                            *image_contents
                        ]
                    }
                ],
                max_tokens=detection_max_tokens,  # Strict limit for cost control
                temperature=0.2,  # Lower temperature for more consistent detection
            )
            
            # Parse response - handle comma-separated list format
            content = response.choices[0].message.content.strip()
            
            # Split by various separators (comma, Japanese comma, semicolon, etc.)
            # Handle multiple separator types to ensure proper splitting
            # Define all possible separators (order matters - try most common first)
            # Japanese comma (、), regular comma (,), semicolon (;), pipe (|), and newlines
            separators = ['、', ',', ';', '|', '\n']
            
            # Split by ALL separators iteratively to handle mixed separators
            # This ensures "卵、にんじん, avocado" gets split properly
            parts = [content]  # Start with the whole content
            for separator in separators:
                # Split all current parts by this separator
                new_parts = []
                for part in parts:
                    new_parts.extend(part.split(separator))
                parts = new_parts
            
            # Clean up each part and filter out empty strings
            ingredient_names = [name.strip() for name in parts if name.strip()]
            
            # Second pass: check if any item still contains separators (nested splitting)
            # This handles edge cases where separators weren't caught in first pass
            final_ingredient_names = []
            for name in ingredient_names:
                # Check if this item contains any separators that weren't split
                needs_split = False
                for sep in separators:
                    if sep in name:
                        needs_split = True
                        break
                
                if needs_split:
                    # Split this item further by all separators
                    sub_parts = [name]
                    for sep in separators:
                        new_sub_parts = []
                        for sub_part in sub_parts:
                            new_sub_parts.extend(sub_part.split(sep))
                        sub_parts = new_sub_parts
                    final_ingredient_names.extend([sub.strip() for sub in sub_parts if sub.strip()])
                else:
                    # No additional separators found, keep as is
                    final_ingredient_names.append(name)
            
            ingredient_names = final_ingredient_names
            
            # Limit to max 10 items as per prompt
            ingredient_names = ingredient_names[:10]
            
            # Get language-specific keywords or use English as fallback
            keywords_to_filter = NON_FOOD_KEYWORDS.get(language, NON_FOOD_KEYWORDS['en'])
            error_keywords = ERROR_MESSAGES.get(language, ERROR_MESSAGES['en'])
            
            # Create ingredient objects
            ingredients = []
            for name in ingredient_names:
                # Clean up ingredient name (remove leading/trailing numbers, bullets, periods, etc.)
                clean_name = name.lstrip('0123456789.-• ').rstrip('.-• ').strip()
                
                # Remove trailing periods and other punctuation
                while clean_name and clean_name[-1] in '.,;:!?•':
                    clean_name = clean_name[:-1].strip()
                
                # Skip if empty after cleaning
                if not clean_name:
                    continue
                
                # Filter out error messages (case-insensitive check)
                clean_lower = clean_name.lower()
                is_error_message = any(error in clean_lower for error in error_keywords)
                if is_error_message:
                    continue  # Skip error messages
                
                # Filter out non-food items (case-insensitive check)
                is_non_food = any(keyword.lower() in clean_lower for keyword in keywords_to_filter)
                if is_non_food:
                    continue  # Skip this ingredient
                
                ingredients.append({
                    "id": f"ing_{str(uuid.uuid4())[:8]}",
                    "name": clean_name
                })
            
            # Generate detection ID
            detection_id = f"det_{str(uuid.uuid4())[:12]}"
            
            # Calculate confidence (simplified - could be improved)
            confidence = min(0.95, 0.7 + (len(ingredients) * 0.05))
            
            return {
                "ingredients": ingredients,
                "detection_id": detection_id,
                "confidence": round(confidence, 2)
            }
            
        except Exception as e:
            raise Exception(f"OpenAI API error: {str(e)}")
    
    async def generate_recipes(
        self,
        ingredients: List[Any],
        language: str = "en",
        max_recipes: int = 3,
        user_tier: str = "free",
        diet_preferences: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Generate recipes from ingredients using OpenAI GPT-4
        
        Args:
            ingredients: List of ingredient objects (Pydantic models or dicts) with 'id' and 'name'
            language: Language code for recipe generation
            max_recipes: Maximum number of recipes to generate
            user_tier: 'free' or 'premium' - determines prompt strategy
            diet_preferences: Optional dict with avoid_ingredients, diet_style, cooking_preferences, religious
            
        Returns:
            Dict with recipes and generation_id
        """
        # Build ingredient list
        # Handle both dict and Pydantic model formats
        ingredient_names = []
        for ing in ingredients:
            if isinstance(ing, dict):
                ingredient_names.append(ing.get("name", ""))
            else:
                # Pydantic model - access as attribute
                ingredient_names.append(getattr(ing, "name", ""))
        ingredient_list = ", ".join(ingredient_names)
        
        # Build diet preferences constraints if premium user
        constraints_text = ""
        if user_tier == "premium" and diet_preferences:
            constraints = []
            
            # Avoid ingredients
            avoid = diet_preferences.get("avoid_ingredients", [])
            if avoid:
                constraints.append(f"Avoid these ingredients: {', '.join(avoid)}")
            
            # Diet style
            diet_style = diet_preferences.get("diet_style", [])
            if diet_style:
                constraints.append(f"Diet style: {', '.join(diet_style)}")
            
            # Cooking preferences
            cooking = diet_preferences.get("cooking_preferences", [])
            if cooking:
                constraints.append(f"Cooking preferences: {', '.join(cooking)}")
            
            # Religious
            religious = diet_preferences.get("religious", [])
            if religious:
                constraints.append(f"Religious requirements: {', '.join(religious)}")
            
            if constraints:
                constraints_text = "\n\nIMPORTANT CONSTRAINTS (MUST BE FOLLOWED STRICTLY):\n" + "\n".join(f"- {c}" for c in constraints) + "\n\nIf no safe recipe exists with these constraints, return an empty array with a message explaining why."
        
        # Determine prompt strategy based on user tier
        if user_tier == "premium" and diet_preferences:
            # Premium user: Conservative, safety-first, strict constraints
            system_message = """You are a careful, safety-first chef assistant. Generate recipes that strictly respect dietary preferences and constraints. Safety and compliance are more important than creativity. If ingredients conflict with preferences, exclude those ingredients or suggest alternatives. Never violate dietary constraints. If no safe recipe exists, politely explain why."""
            temperature = 0.3  # Lower temperature for more conservative responses
        else:
            # Free user: Creative, forgiving, flexible
            system_message = """You are a creative chef assistant. Generate practical, delicious recipes based on available ingredients. Be flexible and forgiving - messy fridges are okay. Make reasonable guesses. Prefer simple recipes."""
            temperature = self.temperature  # Use configured temperature (medium)
        
        # COST REDUCTION: Shorter, focused prompts - max 5 steps per recipe, keep it short
        # Language order matches Flutter AppLanguage enum: english, arabic, bengali, chinese, danish, dutch, finnish, french, german, greek, hebrew, hindi, indonesian, italian, japanese, korean, norwegian, polish, portuguese, romanian, russian, spanish, swedish, thai, turkish, ukrainian, vietnamese
        # Base prompt template - constraints_text is added to all languages
        base_prompts = {
            # English (first)
            "en": f"""Ingredients: {ingredient_list}{constraints_text}

Create {max_recipes} simple recipes. Each recipe max 5 steps. Keep it short. No introductions.

JSON format:
[
  {{"emoji": "🍝", "badge": "fastLazy", "title": "Title", "steps": ["Step 1", "Step 2"], "ingredients": ["ing1", "ing2"]}},
  ...
]

Return ONLY valid JSON array. Do not include "id" field - it will be generated automatically.""",
            # Arabic
            "ar": f"""المكونات: {ingredient_list}{constraints_text}

أنشئ {max_recipes} وصفات بسيطة. كل وصفة بحد أقصى 5 خطوات. اجعلها قصيرة. بدون مقدمات.

تنسيق JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "العنوان", "steps": ["خطوة 1"], "ingredients": ["مكون1"]}}]

أعد مصفوفة JSON صالحة فقط.""",
            # Bengali
            "bn": f"""উপাদান: {ingredient_list}

{max_recipes}টি সহজ রেসিপি তৈরি করুন। প্রতিটি রেসিপি সর্বোচ্চ 5 ধাপ। সংক্ষিপ্ত রাখুন। কোন ভূমিকা নেই।

JSON ফরম্যাট: [{{"emoji": "🍝", "badge": "fastLazy", "title": "শিরোনাম", "steps": ["ধাপ 1"], "ingredients": ["উপাদান1"]}}]

শুধুমাত্র বৈধ JSON অ্যারে ফেরত দিন।""",
            # Chinese
            "zh": f"""食材: {ingredient_list}

创建{max_recipes}个简单食谱。每个食谱最多5步。保持简短。无介绍。

JSON格式: [{{"emoji": "🍝", "badge": "fastLazy", "title": "标题", "steps": ["步骤1"], "ingredients": ["食材1"]}}]

仅返回有效JSON数组。""",
            # Danish
            "da": f"""Ingredienser: {ingredient_list}

Lav {max_recipes} simple opskrifter. Hver opskrift max 5 trin. Hold det kort. Ingen introduktioner.

JSON format: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Trin 1"], "ingredients": ["ing1"]}}]

Returner KUN gyldig JSON array.""",
            # Dutch
            "nl": f"""Ingrediënten: {ingredient_list}

Maak {max_recipes} eenvoudige recepten. Elk recept max 5 stappen. Houd het kort. Geen inleidingen.

JSON formaat: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Stap 1"], "ingredients": ["ing1"]}}]

Geef ALLEEN geldig JSON array terug.""",
            # Finnish
            "fi": f"""Aineet: {ingredient_list}

Luo {max_recipes} yksinkertaista reseptiä. Jokainen resepti max 5 vaihetta. Pidä lyhyenä. Ei johdantoja.

JSON muoto: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Otsikko", "steps": ["Vaihe 1"], "ingredients": ["aine1"]}}]

Palauta VAIN kelvollinen JSON taulukko.""",
            # French
            "fr": f"""Ingrédients: {ingredient_list}

Créez {max_recipes} recettes simples. Chaque recette max 5 étapes. Gardez court. Pas d'introductions.

Format JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titre", "steps": ["Étape 1"], "ingredients": ["ing1"]}}]

Retournez UNIQUEMENT un tableau JSON valide.""",
            # German
            "de": f"""Zutaten: {ingredient_list}

Erstellen Sie {max_recipes} einfache Rezepte. Jedes Rezept max 5 Schritte. Kurz halten. Keine Einleitungen.

JSON Format: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Schritt 1"], "ingredients": ["Zutat1"]}}]

Geben Sie NUR gültiges JSON Array zurück.""",
            # Greek
            "el": f"""Συστατικά: {ingredient_list}

Δημιουργήστε {max_recipes} απλές συνταγές. Κάθε συνταγή max 5 βήματα. Κρατήστε το σύντομο. Χωρίς εισαγωγές.

JSON μορφή: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Τίτλος", "steps": ["Βήμα 1"], "ingredients": ["συσ1"]}}]

Επιστρέψτε ΜΟΝΟ έγκυρο JSON array.""",
            # Hebrew
            "he": f"""מרכיבים: {ingredient_list}

צור {max_recipes} מתכונים פשוטים. כל מתכון מקסימום 5 שלבים. שמור קצר. ללא הקדמות.

פורמט JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "כותרת", "steps": ["שלב 1"], "ingredients": ["מרכיב1"]}}]

החזר רק מערך JSON תקין.""",
            # Hindi
            "hi": f"""सामग्री: {ingredient_list}

{max_recipes} सरल व्यंजन बनाएं। प्रत्येक व्यंजन अधिकतम 5 चरण। संक्षिप्त रखें। कोई परिचय नहीं।

JSON प्रारूप: [{{"emoji": "🍝", "badge": "fastLazy", "title": "शीर्षक", "steps": ["चरण 1"], "ingredients": ["सामग्री1"]}}]

केवल वैध JSON सरणी लौटाएं।""",
            # Indonesian
            "id": f"""Bahan: {ingredient_list}

Buat {max_recipes} resep sederhana. Setiap resep max 5 langkah. Buat singkat. Tanpa pengantar.

Format JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Judul", "steps": ["Langkah 1"], "ingredients": ["bahan1"]}}]

Kembalikan HANYA array JSON yang valid.""",
            # Italian
            "it": f"""Ingredienti: {ingredient_list}

Crea {max_recipes} ricette semplici. Ogni ricetta max 5 passi. Mantieni breve. Nessuna introduzione.

Formato JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titolo", "steps": ["Passo 1"], "ingredients": ["ing1"]}}]

Restituisci SOLO array JSON valido.""",
            # Japanese
            "ja": f"""材料: {ingredient_list}

{max_recipes}つの簡単なレシピを作成。各レシピ最大5ステップ。簡潔に。紹介なし。

JSON形式: [{{"emoji": "🍝", "badge": "fastLazy", "title": "タイトル", "steps": ["ステップ1"], "ingredients": ["材料1"]}}]

有効なJSON配列のみ返す。""",
            # Korean
            "ko": f"""재료: {ingredient_list}

{max_recipes}개의 간단한 레시피 생성. 각 레시피 최대 5단계. 간결하게. 소개 없음.

JSON 형식: [{{"emoji": "🍝", "badge": "fastLazy", "title": "제목", "steps": ["단계1"], "ingredients": ["재료1"]}}]

유효한 JSON 배열만 반환.""",
            # Norwegian
            "no": f"""Ingredienser: {ingredient_list}

Lag {max_recipes} enkle oppskrifter. Hver oppskrift max 5 steg. Hold kort. Ingen introduksjoner.

JSON format: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Tittel", "steps": ["Steg 1"], "ingredients": ["ing1"]}}]

Returner KUN gyldig JSON array.""",
            # Polish
            "pl": f"""Składniki: {ingredient_list}

Utwórz {max_recipes} proste przepisy. Każdy przepis max 5 kroków. Krótko. Bez wstępów.

Format JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Tytuł", "steps": ["Krok 1"], "ingredients": ["składnik1"]}}]

Zwróć TYLKO prawidłową tablicę JSON.""",
            # Portuguese
            "pt": f"""Ingredientes: {ingredient_list}

Crie {max_recipes} receitas simples. Cada receita máx 5 passos. Mantenha curto. Sem introduções.

Formato JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Título", "steps": ["Passo 1"], "ingredients": ["ing1"]}}]

Retorne APENAS array JSON válido.""",
            # Romanian
            "ro": f"""Ingrediente: {ingredient_list}

Creează {max_recipes} rețete simple. Fiecare rețetă max 5 pași. Păstrează scurt. Fără introduceri.

Format JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titlu", "steps": ["Pas 1"], "ingredients": ["ing1"]}}]

Returnează DOAR array JSON valid.""",
            # Russian
            "ru": f"""Ингредиенты: {ingredient_list}

Создайте {max_recipes} простых рецептов. Каждый рецепт макс 5 шагов. Кратко. Без вступлений.

Формат JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Название", "steps": ["Шаг 1"], "ingredients": ["инг1"]}}]

Возвращайте ТОЛЬКО действительный JSON массив.""",
            # Spanish
            "es": f"""Ingredientes: {ingredient_list}

Crea {max_recipes} recetas simples. Cada receta máx 5 pasos. Mantén corto. Sin introducciones.

Formato JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Título", "steps": ["Paso 1"], "ingredients": ["ing1"]}}]

Devuelve SOLO array JSON válido.""",
            # Swedish
            "sv": f"""Ingredienser: {ingredient_list}

Skapa {max_recipes} enkla recept. Varje recept max 5 steg. Håll kort. Inga inledningar.

JSON format: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Steg 1"], "ingredients": ["ing1"]}}]

Returnera ENDAST giltigt JSON array.""",
            # Thai
            "th": f"""ส่วนผสม: {ingredient_list}

สร้างสูตรอาหารง่ายๆ {max_recipes} รายการ แต่ละสูตรสูงสุด 5 ขั้นตอน สั้นๆ ไม่มีคำนำ

รูปแบบ JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "ชื่อ", "steps": ["ขั้นตอน1"], "ingredients": ["ส่วนผสม1"]}}]

คืนค่าเฉพาะอาร์เรย์ JSON ที่ถูกต้อง""",
            # Turkish
            "tr": f"""Malzemeler: {ingredient_list}

{max_recipes} basit tarif oluştur. Her tarif max 5 adım. Kısa tut. Giriş yok.

JSON formatı: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Başlık", "steps": ["Adım 1"], "ingredients": ["malzeme1"]}}]

SADECE geçerli JSON dizisi döndür.""",
            # Ukrainian
            "uk": f"""Інгредієнти: {ingredient_list}

Створіть {max_recipes} простих рецептів. Кожен рецепт макс 5 кроків. Коротко. Без вступів.

Формат JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Назва", "steps": ["Крок 1"], "ingredients": ["інг1"]}}]

Повертайте ЛИШЕ дійсний JSON масив.""",
            # Vietnamese
            "vi": f"""Nguyên liệu: {ingredient_list}

Tạo {max_recipes} công thức đơn giản. Mỗi công thức tối đa 5 bước. Ngắn gọn. Không giới thiệu.

Định dạng JSON: [{{"emoji": "🍝", "badge": "fastLazy", "title": "Tiêu đề", "steps": ["Bước 1"], "ingredients": ["nguyên liệu1"]}}]

Chỉ trả về mảng JSON hợp lệ.""",
        }
        
        prompt = base_prompts.get(language, base_prompts["en"])
        
        try:
            # COST REDUCTION: Controlled token limit for recipe generation
            # ~300 tokens per recipe (title, 5 steps, ingredients) = 900 tokens for 3 recipes
            # Add buffer for JSON structure = ~1000 tokens total
            recipe_max_tokens = min(1000, max_recipes * 350)  # Scale with number of recipes
            
            response = self.client.chat.completions.create(
                model=self.text_model,
                messages=[
                    {
                        "role": "system",
                        "content": system_message + " Always return valid JSON arrays."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                max_tokens=recipe_max_tokens,  # Controlled limit for cost reduction
                temperature=temperature,
                response_format={"type": "json_object"} if max_recipes == 1 else None
            )
            
            content = response.choices[0].message.content.strip()
            
            # Parse JSON response
            import json
            import re
            try:
                # Remove markdown code blocks if present
                if content.startswith("```"):
                    # Extract JSON from code block
                    json_match = re.search(r'```(?:json)?\s*(\[.*?\]|\{.*?\})\s*```', content, re.DOTALL)
                    if json_match:
                        content = json_match.group(1)
                    else:
                        # Try to extract just the JSON part
                        content = re.sub(r'```[a-z]*\s*', '', content)
                        content = re.sub(r'\s*```', '', content)
                
                # Try to parse as JSON
                data = json.loads(content)
                
                # Handle different response formats
                if isinstance(data, list):
                    recipes = data
                elif isinstance(data, dict):
                    if "recipes" in data:
                        recipes = data["recipes"]
                    else:
                        # Single recipe object
                        recipes = [data]
                else:
                    raise ValueError("Unexpected response format")
                
                # Ensure we have the right number of recipes
                recipes = recipes[:max_recipes]
                
                # Validate and fix recipe structure
                for recipe in recipes:
                    # ALWAYS generate a unique ID server-side to prevent collisions
                    # OpenAI may return generic IDs like "rec_001" which get reused
                    recipe["id"] = f"rec_{str(uuid.uuid4())[:8]}"
                    
                    # Ensure required fields exist
                    if "emoji" not in recipe:
                        recipe["emoji"] = "🍽️"
                    if "badge" not in recipe:
                        recipe["badge"] = "fastLazy"
                    if "steps" not in recipe:
                        recipe["steps"] = []
                    if "ingredients" not in recipe:
                        recipe["ingredients"] = []
                
                # Generate generation ID
                generation_id = f"gen_{str(uuid.uuid4())[:12]}"
                
                return {
                    "recipes": recipes,
                    "generation_id": generation_id
                }
                
            except (json.JSONDecodeError, ValueError) as e:
                # Fallback: try to extract JSON from text
                json_match = re.search(r'(\[.*?\]|\{.*?\})', content, re.DOTALL)
                if json_match:
                    try:
                        data = json.loads(json_match.group(1))
                        if isinstance(data, list):
                            recipes = data
                        elif isinstance(data, dict) and "recipes" in data:
                            recipes = data["recipes"]
                        else:
                            recipes = [data]
                        
                        recipes = recipes[:max_recipes]
                        for recipe in recipes:
                            if "id" not in recipe:
                                recipe["id"] = f"rec_{str(uuid.uuid4())[:8]}"
                        
                        return {
                            "recipes": recipes,
                            "generation_id": f"gen_{str(uuid.uuid4())[:12]}"
                        }
                    except:
                        pass
                
                raise Exception(f"Failed to parse recipe JSON from OpenAI response: {str(e)}. Content: {content[:200]}")
                    
        except Exception as e:
            raise Exception(f"OpenAI API error: {str(e)}")
    
    async def translate_recipe(
        self,
        recipe: Dict[str, Any],
        target_language: str
    ) -> Dict[str, Any]:
        """
        Translate a recipe to a different language using OpenAI
        
        Args:
            recipe: Recipe dict with id, emoji, badge, title, steps, ingredients
            target_language: Target language code
            
        Returns:
            Translated recipe dict
        """
        # Build recipe text for translation
        recipe_text = f"""Recipe: {recipe.get('title', '')}
Badge: {recipe.get('badge', '')}
Steps: {', '.join(recipe.get('steps', []))}
Ingredients: {', '.join(recipe.get('ingredients', []))}"""
        
        # Language-specific translation prompts
        translation_prompts = {
            "en": f"Translate this recipe to English. Maintain the same structure and format.",
            "es": f"Traduce esta receta al español. Mantén la misma estructura y formato.",
            "ja": f"このレシピを日本語に翻訳してください。同じ構造と形式を維持してください。",
            # Add more as needed - for now, use a generic prompt
        }
        
        prompt = translation_prompts.get(target_language, f"Translate this recipe to {target_language}. Maintain the same structure, format, and emoji. Return as JSON with the same structure as the original recipe.")
        
        try:
            response = self.client.chat.completions.create(
                model=self.text_model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a recipe translator. Translate recipes accurately while maintaining the same structure, format, and emoji. Always return valid JSON."
                    },
                    {
                        "role": "user",
                        "content": f"{prompt}\n\n{recipe_text}\n\nReturn the translated recipe as JSON with the same structure: {{'id': '{recipe.get('id')}', 'emoji': '{recipe.get('emoji')}', 'badge': '...', 'title': '...', 'steps': [...], 'ingredients': [...]}}"
                    }
                ],
                max_tokens=self.max_tokens,
                temperature=0.5,  # Lower temperature for more accurate translation
            )
            
            content = response.choices[0].message.content.strip()
            
            # Parse JSON response
            import json
            import re
            
            # Remove markdown if present
            if content.startswith("```"):
                json_match = re.search(r'```(?:json)?\s*(\{.*?\})\s*```', content, re.DOTALL)
                if json_match:
                    content = json_match.group(1)
            
            translated = json.loads(content)
            
            # Ensure original ID and emoji are preserved
            translated["id"] = recipe.get("id")
            translated["emoji"] = recipe.get("emoji")
            translated["badge"] = recipe.get("badge")  # Badge names stay the same
            
            return translated
            
        except Exception as e:
            raise Exception(f"Translation failed: {str(e)}")


openai_service = OpenAIService()

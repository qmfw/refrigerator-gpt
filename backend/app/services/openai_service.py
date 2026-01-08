"""OpenAI service for ingredient detection and recipe generation"""
from openai import OpenAI
from typing import List, Dict, Any, Optional
import base64
import uuid
from app.config import settings


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
        
        # Create ultra-short prompt for cost optimization
        # COST REDUCTION: Return ONLY comma-separated list, no JSON, no descriptions, max 10 items
        # Language order matches Flutter AppLanguage enum: english, arabic, bengali, chinese, danish, dutch, finnish, french, german, greek, hebrew, hindi, indonesian, italian, japanese, korean, norwegian, polish, portuguese, romanian, russian, spanish, swedish, thai, turkish, ukrainian, vietnamese
        language_prompts = {
            # English (first)
            "en": "Return ONLY a comma-separated list of ingredients you see. No explanations. No sentences. Max 10 items.",
            # Arabic
            "ar": "أعد فقط قائمة مكونات مفصولة بفواصل. لا تفسيرات. لا جمل. حد أقصى 10 عناصر.",
            # Bengali
            "bn": "শুধুমাত্র কমা দ্বারা পৃথক করা উপাদানের তালিকা ফেরত দিন। কোন ব্যাখ্যা নেই। কোন বাক্য নেই। সর্বোচ্চ 10টি আইটেম।",
            # Chinese
            "zh": "只返回用逗号分隔的成分列表。无解释。无句子。最多10项。",
            # Danish
            "da": "Returner kun komma-separeret liste af ingredienser. Ingen forklaringer. Ingen sætninger. Max 10 emner.",
            # Dutch
            "nl": "Geef alleen een komma-gescheiden lijst van ingrediënten. Geen uitleg. Geen zinnen. Max 10 items.",
            # Finnish
            "fi": "Palauta vain pilkulla erotettu aineiden lista. Ei selityksiä. Ei lauseita. Max 10 kohdetta.",
            # French
            "fr": "Retournez uniquement une liste d'ingrédients séparés par des virgules. Pas d'explications. Pas de phrases. Max 10 éléments.",
            # German
            "de": "Geben Sie nur eine kommagetrennte Liste von Zutaten zurück. Keine Erklärungen. Keine Sätze. Max 10 Artikel.",
            # Greek
            "el": "Επιστρέψτε μόνο λίστα συστατικών διαχωρισμένη με κόμματα. Χωρίς εξηγήσεις. Χωρίς προτάσεις. Μέγιστο 10 στοιχεία.",
            # Hebrew
            "he": "החזר רק רשימת מרכיבים מופרדת בפסיקים. ללא הסברים. ללא משפטים. מקסימום 10 פריטים.",
            # Hindi
            "hi": "केवल अल्पविराम से अलग किए गए सामग्री की सूची लौटाएं। कोई स्पष्टीकरण नहीं। कोई वाक्य नहीं। अधिकतम 10 आइटम।",
            # Indonesian
            "id": "Kembalikan hanya daftar bahan yang dipisahkan koma. Tanpa penjelasan. Tanpa kalimat. Maks 10 item.",
            # Italian
            "it": "Restituisci solo un elenco di ingredienti separati da virgole. Nessuna spiegazione. Nessuna frase. Max 10 elementi.",
            # Japanese
            "ja": "見える材料をカンマ区切りのリストのみ返す。説明なし。文なし。最大10項目。",
            # Korean
            "ko": "보이는 재료만 쉼표로 구분된 목록으로 반환. 설명 없음. 문장 없음. 최대 10개 항목.",
            # Norwegian
            "no": "Returner kun komma-separert liste av ingredienser. Ingen forklaringer. Ingen setninger. Maks 10 elementer.",
            # Polish
            "pl": "Zwróć tylko listę składników oddzielonych przecinkami. Bez wyjaśnień. Bez zdań. Max 10 pozycji.",
            # Portuguese
            "pt": "Retorne apenas uma lista de ingredientes separados por vírgulas. Sem explicações. Sem frases. Máx 10 itens.",
            # Romanian
            "ro": "Returnează doar o listă de ingrediente separate prin virgulă. Fără explicații. Fără propoziții. Max 10 elemente.",
            # Russian
            "ru": "Верните только список ингредиентов через запятую. Без объяснений. Без предложений. Макс 10 элементов.",
            # Spanish
            "es": "Devuelve solo una lista de ingredientes separados por comas. Sin explicaciones. Sin oraciones. Máx 10 elementos.",
            # Swedish
            "sv": "Returnera endast en komma-separerad lista av ingredienser. Inga förklaringar. Inga meningar. Max 10 objekt.",
            # Thai
            "th": "คืนเฉพาะรายการส่วนผสมที่คั่นด้วยจุลภาค ไม่มีคำอธิบาย ไม่มีประโยค สูงสุด 10 รายการ",
            # Turkish
            "tr": "Sadece virgülle ayrılmış malzeme listesi döndür. Açıklama yok. Cümle yok. Maks 10 öğe.",
            # Ukrainian
            "uk": "Поверніть лише список інгредієнтів через кому. Без пояснень. Без речень. Макс 10 елементів.",
            # Vietnamese
            "vi": "Chỉ trả về danh sách nguyên liệu cách nhau bằng dấu phẩy. Không giải thích. Không câu. Tối đa 10 mục.",
        }
        
        prompt = language_prompts.get(language, language_prompts["en"])
        
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
            
            # Split by comma and clean up
            ingredient_names = []
            if ',' in content:
                # Comma-separated format
                ingredient_names = [name.strip() for name in content.split(',') if name.strip()]
            else:
                # Fallback: try line-separated format
                ingredient_lines = [line.strip() for line in content.split('\n') if line.strip()]
                for line in ingredient_lines:
                    # If line contains commas, split it
                    if ',' in line:
                        ingredient_names.extend([name.strip() for name in line.split(',') if name.strip()])
                    else:
                        ingredient_names.append(line)
            
            # Limit to max 10 items as per prompt
            ingredient_names = ingredient_names[:10]
            
            # Create ingredient objects
            ingredients = []
            for name in ingredient_names:
                # Clean up ingredient name (remove numbers, bullets, etc.)
                clean_name = name.lstrip('0123456789.-• ').strip()
                if clean_name:
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
        max_recipes: int = 3
    ) -> Dict[str, Any]:
        """
        Generate recipes from ingredients using OpenAI GPT-4
        
        Args:
            ingredients: List of ingredient objects (Pydantic models or dicts) with 'id' and 'name'
            language: Language code for recipe generation
            max_recipes: Maximum number of recipes to generate
            
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
        
        # COST REDUCTION: Shorter, focused prompts - max 5 steps per recipe, keep it short
        # Language order matches Flutter AppLanguage enum: english, arabic, bengali, chinese, danish, dutch, finnish, french, german, greek, hebrew, hindi, indonesian, italian, japanese, korean, norwegian, polish, portuguese, romanian, russian, spanish, swedish, thai, turkish, ukrainian, vietnamese
        language_prompts = {
            # English (first)
            "en": f"""Ingredients: {ingredient_list}

Create {max_recipes} simple recipes. Each recipe max 5 steps. Keep it short. No introductions.

JSON format:
[
  {{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Title", "steps": ["Step 1", "Step 2"], "ingredients": ["ing1", "ing2"]}},
  ...
]

Return ONLY valid JSON array.""",
            # Arabic
            "ar": f"""المكونات: {ingredient_list}

أنشئ {max_recipes} وصفات بسيطة. كل وصفة بحد أقصى 5 خطوات. اجعلها قصيرة. بدون مقدمات.

تنسيق JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "العنوان", "steps": ["خطوة 1"], "ingredients": ["مكون1"]}}]

أعد مصفوفة JSON صالحة فقط.""",
            # Bengali
            "bn": f"""উপাদান: {ingredient_list}

{max_recipes}টি সহজ রেসিপি তৈরি করুন। প্রতিটি রেসিপি সর্বোচ্চ 5 ধাপ। সংক্ষিপ্ত রাখুন। কোন ভূমিকা নেই।

JSON ফরম্যাট: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "শিরোনাম", "steps": ["ধাপ 1"], "ingredients": ["উপাদান1"]}}]

শুধুমাত্র বৈধ JSON অ্যারে ফেরত দিন।""",
            # Chinese
            "zh": f"""食材: {ingredient_list}

创建{max_recipes}个简单食谱。每个食谱最多5步。保持简短。无介绍。

JSON格式: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "标题", "steps": ["步骤1"], "ingredients": ["食材1"]}}]

仅返回有效JSON数组。""",
            # Danish
            "da": f"""Ingredienser: {ingredient_list}

Lav {max_recipes} simple opskrifter. Hver opskrift max 5 trin. Hold det kort. Ingen introduktioner.

JSON format: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Trin 1"], "ingredients": ["ing1"]}}]

Returner KUN gyldig JSON array.""",
            # Dutch
            "nl": f"""Ingrediënten: {ingredient_list}

Maak {max_recipes} eenvoudige recepten. Elk recept max 5 stappen. Houd het kort. Geen inleidingen.

JSON formaat: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Stap 1"], "ingredients": ["ing1"]}}]

Geef ALLEEN geldig JSON array terug.""",
            # Finnish
            "fi": f"""Aineet: {ingredient_list}

Luo {max_recipes} yksinkertaista reseptiä. Jokainen resepti max 5 vaihetta. Pidä lyhyenä. Ei johdantoja.

JSON muoto: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Otsikko", "steps": ["Vaihe 1"], "ingredients": ["aine1"]}}]

Palauta VAIN kelvollinen JSON taulukko.""",
            # French
            "fr": f"""Ingrédients: {ingredient_list}

Créez {max_recipes} recettes simples. Chaque recette max 5 étapes. Gardez court. Pas d'introductions.

Format JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titre", "steps": ["Étape 1"], "ingredients": ["ing1"]}}]

Retournez UNIQUEMENT un tableau JSON valide.""",
            # German
            "de": f"""Zutaten: {ingredient_list}

Erstellen Sie {max_recipes} einfache Rezepte. Jedes Rezept max 5 Schritte. Kurz halten. Keine Einleitungen.

JSON Format: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Schritt 1"], "ingredients": ["Zutat1"]}}]

Geben Sie NUR gültiges JSON Array zurück.""",
            # Greek
            "el": f"""Συστατικά: {ingredient_list}

Δημιουργήστε {max_recipes} απλές συνταγές. Κάθε συνταγή max 5 βήματα. Κρατήστε το σύντομο. Χωρίς εισαγωγές.

JSON μορφή: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Τίτλος", "steps": ["Βήμα 1"], "ingredients": ["συσ1"]}}]

Επιστρέψτε ΜΟΝΟ έγκυρο JSON array.""",
            # Hebrew
            "he": f"""מרכיבים: {ingredient_list}

צור {max_recipes} מתכונים פשוטים. כל מתכון מקסימום 5 שלבים. שמור קצר. ללא הקדמות.

פורמט JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "כותרת", "steps": ["שלב 1"], "ingredients": ["מרכיב1"]}}]

החזר רק מערך JSON תקין.""",
            # Hindi
            "hi": f"""सामग्री: {ingredient_list}

{max_recipes} सरल व्यंजन बनाएं। प्रत्येक व्यंजन अधिकतम 5 चरण। संक्षिप्त रखें। कोई परिचय नहीं।

JSON प्रारूप: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "शीर्षक", "steps": ["चरण 1"], "ingredients": ["सामग्री1"]}}]

केवल वैध JSON सरणी लौटाएं।""",
            # Indonesian
            "id": f"""Bahan: {ingredient_list}

Buat {max_recipes} resep sederhana. Setiap resep max 5 langkah. Buat singkat. Tanpa pengantar.

Format JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Judul", "steps": ["Langkah 1"], "ingredients": ["bahan1"]}}]

Kembalikan HANYA array JSON yang valid.""",
            # Italian
            "it": f"""Ingredienti: {ingredient_list}

Crea {max_recipes} ricette semplici. Ogni ricetta max 5 passi. Mantieni breve. Nessuna introduzione.

Formato JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titolo", "steps": ["Passo 1"], "ingredients": ["ing1"]}}]

Restituisci SOLO array JSON valido.""",
            # Japanese
            "ja": f"""材料: {ingredient_list}

{max_recipes}つの簡単なレシピを作成。各レシピ最大5ステップ。簡潔に。紹介なし。

JSON形式: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "タイトル", "steps": ["ステップ1"], "ingredients": ["材料1"]}}]

有効なJSON配列のみ返す。""",
            # Korean
            "ko": f"""재료: {ingredient_list}

{max_recipes}개의 간단한 레시피 생성. 각 레시피 최대 5단계. 간결하게. 소개 없음.

JSON 형식: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "제목", "steps": ["단계1"], "ingredients": ["재료1"]}}]

유효한 JSON 배열만 반환.""",
            # Norwegian
            "no": f"""Ingredienser: {ingredient_list}

Lag {max_recipes} enkle oppskrifter. Hver oppskrift max 5 steg. Hold kort. Ingen introduksjoner.

JSON format: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Tittel", "steps": ["Steg 1"], "ingredients": ["ing1"]}}]

Returner KUN gyldig JSON array.""",
            # Polish
            "pl": f"""Składniki: {ingredient_list}

Utwórz {max_recipes} proste przepisy. Każdy przepis max 5 kroków. Krótko. Bez wstępów.

Format JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Tytuł", "steps": ["Krok 1"], "ingredients": ["składnik1"]}}]

Zwróć TYLKO prawidłową tablicę JSON.""",
            # Portuguese
            "pt": f"""Ingredientes: {ingredient_list}

Crie {max_recipes} receitas simples. Cada receita máx 5 passos. Mantenha curto. Sem introduções.

Formato JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Título", "steps": ["Passo 1"], "ingredients": ["ing1"]}}]

Retorne APENAS array JSON válido.""",
            # Romanian
            "ro": f"""Ingrediente: {ingredient_list}

Creează {max_recipes} rețete simple. Fiecare rețetă max 5 pași. Păstrează scurt. Fără introduceri.

Format JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titlu", "steps": ["Pas 1"], "ingredients": ["ing1"]}}]

Returnează DOAR array JSON valid.""",
            # Russian
            "ru": f"""Ингредиенты: {ingredient_list}

Создайте {max_recipes} простых рецептов. Каждый рецепт макс 5 шагов. Кратко. Без вступлений.

Формат JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Название", "steps": ["Шаг 1"], "ingredients": ["инг1"]}}]

Возвращайте ТОЛЬКО действительный JSON массив.""",
            # Spanish
            "es": f"""Ingredientes: {ingredient_list}

Crea {max_recipes} recetas simples. Cada receta máx 5 pasos. Mantén corto. Sin introducciones.

Formato JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Título", "steps": ["Paso 1"], "ingredients": ["ing1"]}}]

Devuelve SOLO array JSON válido.""",
            # Swedish
            "sv": f"""Ingredienser: {ingredient_list}

Skapa {max_recipes} enkla recept. Varje recept max 5 steg. Håll kort. Inga inledningar.

JSON format: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Titel", "steps": ["Steg 1"], "ingredients": ["ing1"]}}]

Returnera ENDAST giltigt JSON array.""",
            # Thai
            "th": f"""ส่วนผสม: {ingredient_list}

สร้างสูตรอาหารง่ายๆ {max_recipes} รายการ แต่ละสูตรสูงสุด 5 ขั้นตอน สั้นๆ ไม่มีคำนำ

รูปแบบ JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "ชื่อ", "steps": ["ขั้นตอน1"], "ingredients": ["ส่วนผสม1"]}}]

คืนค่าเฉพาะอาร์เรย์ JSON ที่ถูกต้อง""",
            # Turkish
            "tr": f"""Malzemeler: {ingredient_list}

{max_recipes} basit tarif oluştur. Her tarif max 5 adım. Kısa tut. Giriş yok.

JSON formatı: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Başlık", "steps": ["Adım 1"], "ingredients": ["malzeme1"]}}]

SADECE geçerli JSON dizisi döndür.""",
            # Ukrainian
            "uk": f"""Інгредієнти: {ingredient_list}

Створіть {max_recipes} простих рецептів. Кожен рецепт макс 5 кроків. Коротко. Без вступів.

Формат JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Назва", "steps": ["Крок 1"], "ingredients": ["інг1"]}}]

Повертайте ЛИШЕ дійсний JSON масив.""",
            # Vietnamese
            "vi": f"""Nguyên liệu: {ingredient_list}

Tạo {max_recipes} công thức đơn giản. Mỗi công thức tối đa 5 bước. Ngắn gọn. Không giới thiệu.

Định dạng JSON: [{{"id": "rec_001", "emoji": "🍝", "badge": "fastLazy", "title": "Tiêu đề", "steps": ["Bước 1"], "ingredients": ["nguyên liệu1"]}}]

Chỉ trả về mảng JSON hợp lệ.""",
        }
        
        prompt = language_prompts.get(language, language_prompts["en"])
        
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
                        "content": "You are a creative chef assistant. Generate practical, delicious recipes based on available ingredients. Always return valid JSON arrays."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                max_tokens=recipe_max_tokens,  # Controlled limit for cost reduction
                temperature=self.temperature,
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
                    # Generate ID if missing
                    if "id" not in recipe:
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

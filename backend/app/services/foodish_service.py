"""Foodish API service for fetching free food images"""
import httpx
import re
from typing import Optional
from app.services.food_image_matcher import food_image_matcher


class FoodishService:
    """Service for fetching food images from Foodish API"""
    
    BASE_URL = "https://foodish-api.com"
    
    # Foodish categories (from https://foodish-api.com/)
    # Available categories: biryani, burger, butter-chicken, dessert, dosa, idly, pasta, pizza, rice, samosa
    FOOD_CATEGORIES = [
        "burger", "pizza", "biryani", "pasta", "dosa", "idly", 
        "samosa", "dessert", "rice", "butter-chicken"
    ]
    
    def __init__(self):
        self.client = httpx.AsyncClient(timeout=5.0)  # 5 second timeout
    
    async def get_food_image(self, recipe_title: str, ingredients: list = None, language: str = "en") -> Optional[str]:
        """
        Get a food image from Foodish API based on recipe title and ingredients.
        Uses description-based matching to find the best image from all 364 available images.
        
        Args:
            recipe_title: Recipe title
            ingredients: List of ingredient names
            language: Language code for multilingual matching (default: "en")
            
        Returns:
            Image URL if successful, None if failed
        """
        try:
            # Strategy 1: Use description-based matcher (most accurate)
            match_result = food_image_matcher.find_best_match(recipe_title, ingredients or [], language)
            
            if match_result:
                image_path, score = match_result
                
                # Only use description match if score is reasonable (>= 0.2)
                if score >= 0.2:
                    image_url = food_image_matcher.get_image_url(image_path)
                    
                    # Verify image exists
                    try:
                        check_response = await self.client.head(image_url, timeout=2.0)
                        if check_response.status_code == 200:
                            print(f"✅ Foodish: Description match '{recipe_title}' -> {image_path} (score: {score:.2f})")
                            return image_url
                    except:
                        pass  # Fall through to category-based matching
            
            # Strategy 2: Fallback to category-based matching (if description match fails or score too low)
            category = self._match_to_category(recipe_title, ingredients or [])
            
            if category:
                # Select best image index based on recipe characteristics
                image_index = self._select_best_image_index(category, recipe_title, ingredients or [])
                
                # Try to fetch specific image by index
                specific_url = f"{self.BASE_URL}/images/{category}/{category}{image_index}.jpg"
                
                # Verify image exists
                try:
                    check_response = await self.client.head(specific_url, timeout=2.0)
                    if check_response.status_code == 200:
                        print(f"🍽️  Foodish: Category match '{recipe_title}' -> category: {category}, image: {image_index}")
                        return specific_url
                except:
                    pass  # Fall back to API endpoint
                
                # Fallback to API endpoint (returns random image from category)
                url = f"{self.BASE_URL}/api/images/{category}"
                print(f"🍽️  Foodish: Category match '{recipe_title}' -> {category} (using API endpoint)")
            else:
                # Fallback to random food image only after all matching strategies fail
                url = f"{self.BASE_URL}/api/"
                print(f"🍽️  Foodish: No match for '{recipe_title}', using random image")
            
            response = await self.client.get(url)
            
            if response.status_code == 200:
                data = response.json()
                image_url = data.get("image")
                if image_url:
                    print(f"✅ Foodish: Successfully fetched image from {category or 'random'}")
                return image_url
            
            return None
            
        except Exception as e:
            # Log error but don't fail recipe generation
            print(f"⚠️  Failed to fetch Foodish image: {str(e)}")
            return None
    
    def _match_to_category(self, title: str, ingredients: list) -> Optional[str]:
        """
        Match recipe title and ingredients to a Foodish category.
        Uses multiple matching strategies before falling back to random.
        
        Args:
            title: Recipe title
            ingredients: List of ingredients
            
        Returns:
            Category name if matched, None otherwise
        """
        # Normalize text for matching
        title_lower = title.lower()
        ingredients_text = " ".join(ingredients).lower() if ingredients else ""
        combined_text = (title_lower + " " + ingredients_text).lower()
        
        # Strategy 0: Multi-word phrase matching FIRST (highest priority)
        # Check for phrases like "soft cream", "ice cream", "fried rice", etc. BEFORE single words
        phrases = [
            # Dessert phrases (multilingual)
            ("dessert", [
                # English
                "soft cream", "ice cream", "soft serve", "chocolate dip", "choco dip", "crunchy ice", "corn ice",
                # Japanese
                "アイスクリーム", "ソフトクリーム", "クリーム", "アイスコーン",
                # Korean
                "아이스크림", "소프트크림",
                # Chinese
                "冰淇淋", "软冰淇淋", "甜筒",
                # Spanish
                "crema suave",
                # French
                "crème glacée",
                # German
                "eiscreme", "speiseeis",
                # Italian
                "crema",
                # Portuguese
                "creme",
                # Russian
                "мороженое",
                # Arabic
                "آيس كريم",
                # Hindi
                "आइसक्रीम",
                # Thai
                "ไอศกรีม",
                # Vietnamese
                "kem lạnh",
                # Indonesian
                "es krim",
                # Dutch
                "roomijs",
            ]),
            # Rice phrases (multilingual)
            ("rice", [
                # English
                "fried rice", "kimchi rice", "kimchi fried", "cabbage rice", "curry rice",
                # Japanese
                "チャーハン", "キムチ", "オムライス",
                # Korean
                "볶음밥", "김치", "김치볶음밥",
                # Chinese
                "炒饭", "泡菜", "泡菜炒饭",
                # Spanish
                "arroz frito",
                # French
                "riz frit",
                # German
                "gebratener reis",
                # Italian
                "riso fritto",
                # Portuguese
                "arroz frito",
                # Russian
                "жареный рис",
                # Arabic
                "أرز مقلي",
                # Hindi
                "तले हुए चावल",
                # Thai
                "ข้าวผัด",
                # Vietnamese
                "cơm chiên",
                # Indonesian
                "nasi goreng",
                # Dutch
                "gebakken rijst",
                # Polish
                "smażony ryż",
                # Turkish
                "kızarmış pirinç",
                # Greek
                "τηγανητό ρύζι",
                # Hebrew
                "אורז מטוגן",
                # Swedish
                "stekt ris",
                # Norwegian
                "stekt ris",
                # Danish
                "stegt ris",
                # Finnish
                "paistettu riisi",
                # Romanian
                "orez prăjit",
                # Ukrainian
                "смажений рис",
                # Bengali
                "ভাজা ভাত",
            ]),
            # Pasta phrases
            ("pasta", ["spaghetti", "lasagna", "carbonara"]),
            # Butter chicken phrases
            ("butter-chicken", ["butter chicken", "chicken curry"]),
        ]
        
        for category, phrase_list in phrases:
            if category in self.FOOD_CATEGORIES:
                for phrase in phrase_list:
                    if phrase in combined_text:
                        return category
        
        # Comprehensive keyword mapping (priority order matters - specific first)
        # Based on Foodish API available categories: biryani, burger, butter-chicken, dessert, dosa, idly, pasta, pizza, rice, samosa
        category_keywords = {
            # Specific dishes (high priority - exact matches first)
            "biryani": ["biryani", "biriyani", "briyani"],
            "dosa": ["dosa", "dosai", "dosha"],
            "idly": ["idly", "idli", "idlee"],
            "samosa": ["samosa"],
            "butter-chicken": ["butter chicken", "butter-chicken", "butterchicken", "makhani"],
            
            # Ice cream and desserts (HIGH PRIORITY - must match before other categories)
            "dessert": [
                # English
                "ice cream", "icecream", "soft cream", "softcream", "soft serve", "softserve",
                "chocolate dip", "choco dip", "crunchy ice", "corn ice", "cone",
                "dessert", "cake", "pie", "cookie", "pudding", "brownie", "muffin",
                "cupcake", "donut", "doughnut", "tiramisu", "cheesecake", "tart", "pastry", "sweet",
                # Japanese (日本語)
                "アイス", "アイスクリーム", "ソフトクリーム", "クリーム", "コーン", "アイスコーン",
                "デザート", "ケーキ", "クッキー",
                # Korean (한국어)
                "아이스크림", "소프트크림", "아이스", "크림", "콘", "디저트", "케이크",
                # Chinese (中文)
                "冰淇淋", "冰激凌", "软冰淇淋", "甜筒", "蛋卷", "甜品", "蛋糕", "甜点",
                # Spanish (Español)
                "helado", "helados", "crema suave", "postre", "dulce", "pastel", "tarta",
                # French (Français)
                "glace", "crème glacée", "dessert", "gâteau", "douceur", "sucré",
                # German (Deutsch)
                "eis", "eiscreme", "speiseeis", "dessert", "kuchen", "süß",
                # Italian (Italiano)
                "gelato", "crema", "dolce", "dessert", "torta", "dolci",
                # Portuguese (Português)
                "sorvete", "gelado", "creme", "sobremesa", "doce", "bolo",
                # Russian (Русский)
                "мороженое", "мороженное", "десерт", "торт", "сладкое", "крем",
                # Arabic (العربية)
                "آيس كريم", "بوظة", "حلوى", "كعكة", "حلويات",
                # Hindi (हिन्दी)
                "आइसक्रीम", "क्रीम", "मिठाई", "केक", "मीठा",
                # Thai (ไทย)
                "ไอศกรีม", "ครีม", "ของหวาน", "เค้ก", "ขนม",
                # Vietnamese (Tiếng Việt)
                "kem", "kem lạnh", "tráng miệng", "bánh ngọt", "ngọt",
                # Indonesian (Bahasa Indonesia)
                "es krim", "krim", "pencuci mulut", "kue", "manis",
                # Dutch (Nederlands)
                "ijs", "ijsje", "roomijs", "dessert", "taart", "zoet",
                # Polish (Polski)
                "lody", "deser", "ciasto", "słodkie",
                # Turkish (Türkçe)
                "dondurma", "tatlı", "pasta", "kek", "şekerli",
                # Greek (Ελληνικά)
                "παγωτό", "γλυκό", "γλυκό", "τούρτα",
                # Hebrew (עברית)
                "גלידה", "קרם", "קינוח", "עוגה", "מתוק",
                # Swedish (Svenska)
                "glass", "dessert", "kaka", "söt",
                # Norwegian (Norsk)
                "is", "dessert", "kake", "søt",
                # Danish (Dansk)
                "is", "dessert", "kage", "sød",
                # Finnish (Suomi)
                "jäätelö", "jälkiruoka", "kakku", "makea",
                # Romanian (Română)
                "înghețată", "desert", "tort", "dulce",
                # Ukrainian (Українська)
                "морозиво", "десерт", "торт", "солодке",
                # Bengali (বাংলা)
                "আইসক্রিম", "ক্রিম", "মিষ্টি", "কেক",
            ],
            
            # Pasta dishes
            "pasta": [
                "pasta", "spaghetti", "macaroni", "penne", "fettuccine", 
                "lasagna", "lasagne", "ravioli", "gnocchi", "linguine",
                "carbonara", "bolognese", "alfredo", "marinara"
            ],
            
            # Pizza variations
            "pizza": [
                "pizza", "margherita", "pepperoni", "cheese pizza",
                "neapolitan", "calzone", "pizzetta"
            ],
            
            # Burger variations
            "burger": [
                "burger", "hamburger", "cheeseburger", "patty", "bun",
                "slider", "whopper", "big mac"
            ],
            
            # Rice dishes (including kimchi fried rice, cabbage rice, etc.)
            "rice": [
                # English
                "rice", "fried rice", "risotto", "paella", "jambalaya",
                "pilaf", "pilau", "congee", "curry rice", "omurice",
                # Korean/Asian rice dishes
                "kimchi", "kimchi rice", "kimchi fried rice",
                # Cabbage-related (no salad category, use rice)
                "cabbage", "lettuce", "salad rice",
                # Japanese (日本語)
                "ご飯", "ごはん", "ライス", "チャーハン", "キムチ", "キャベツ", "レタス", "オムライス",
                # Korean (한국어)
                "밥", "볶음밥", "김치", "김치볶음밥", "양배추",
                # Chinese (中文)
                "米饭", "炒饭", "泡菜", "泡菜炒饭", "卷心菜", "生菜",
                # Spanish (Español)
                "arroz", "arroz frito", "col", "lechuga",
                # French (Français)
                "riz", "riz frit", "chou", "laitue",
                # German (Deutsch)
                "reis", "gebratener reis", "kohl", "salat",
                # Italian (Italiano)
                "riso", "riso fritto", "cavolo", "lattuga",
                # Portuguese (Português)
                "arroz", "arroz frito", "repolho", "alface",
                # Russian (Русский)
                "рис", "жареный рис", "капуста", "салат",
                # Arabic (العربية)
                "أرز", "أرز مقلي", "ملفوف", "خس",
                # Hindi (हिन्दी)
                "चावल", "तले हुए चावल", "गोभी", "सलाद",
                # Thai (ไทย)
                "ข้าว", "ข้าวผัด", "กะหล่ำปลี", "ผักกาด",
                # Vietnamese (Tiếng Việt)
                "cơm", "cơm chiên", "bắp cải", "rau diếp",
                # Indonesian (Bahasa Indonesia)
                "nasi", "nasi goreng", "kubis", "selada",
                # Dutch (Nederlands)
                "rijst", "gebakken rijst", "kool", "sla",
                # Polish (Polski)
                "ryż", "smażony ryż", "kapusta", "sałata",
                # Turkish (Türkçe)
                "pirinç", "kızarmış pirinç", "lahana", "marul",
                # Greek (Ελληνικά)
                "ρύζι", "τηγανητό ρύζι", "λάχανο", "μαρούλι",
                # Hebrew (עברית)
                "אורז", "אורז מטוגן", "כרוב", "חסה",
                # Swedish (Svenska)
                "ris", "stekt ris", "kål", "sallad",
                # Norwegian (Norsk)
                "ris", "stekt ris", "kål", "salat",
                # Danish (Dansk)
                "ris", "stegt ris", "kål", "salat",
                # Finnish (Suomi)
                "riisi", "paistettu riisi", "kaali", "salaatti",
                # Romanian (Română)
                "orez", "orez prăjit", "varză", "salată",
                # Ukrainian (Українська)
                "рис", "смажений рис", "капуста", "салат",
                # Bengali (বাংলা)
                "ভাত", "ভাজা ভাত", "বাঁধাকপি", "লেটুস",
            ],
        }
        
        # Strategy 1: Exact title match (check whole words to avoid false matches)
        for category, keywords in category_keywords.items():
            if category in self.FOOD_CATEGORIES:
                for keyword in keywords:
                    # Use word boundary matching to avoid "ice" matching "rice" or "spice"
                    pattern = r'\b' + re.escape(keyword) + r'\b'
                    if re.search(pattern, title_lower, re.IGNORECASE):
                        return category
        
        # Strategy 2: Combined text match (title + ingredients) with word boundaries
        for category, keywords in category_keywords.items():
            if category in self.FOOD_CATEGORIES:
                for keyword in keywords:
                    # Use word boundary matching
                    pattern = r'\b' + re.escape(keyword) + r'\b'
                    if re.search(pattern, combined_text, re.IGNORECASE):
                        return category
        
        # Strategy 3: Ingredient-based matching
        if ingredients:
            for category, keywords in category_keywords.items():
                if category in self.FOOD_CATEGORIES:
                    for keyword in keywords:
                        if keyword in ingredients_text:
                            return category
        
        # Strategy 4: Partial word matching (e.g., "burger" in "cheeseburger")
        words = combined_text.split()
        for word in words:
            for category, keywords in category_keywords.items():
                if category in self.FOOD_CATEGORIES:
                    for keyword in keywords:
                        if keyword in word or word in keyword:
                            return category
        
        # Strategy 5: Common food type detection (fallback)
        food_type_patterns = {
            "dessert": ["sweet", "sugar", "chocolate", "vanilla", "cream", "cone", "コーン"],
            "rice": ["grain", "cooked rice", "ご飯", "ごはん"],
        }
        
        for category, patterns in food_type_patterns.items():
            if category in self.FOOD_CATEGORIES:
                for pattern in patterns:
                    if pattern in combined_text:
                        return category
        
        # If no match found after all strategies, return None (will use random image)
        return None
    
    def _select_best_image_index(self, category: str, title: str, ingredients: list) -> int:
        """
        Select the best image index for a recipe based on its characteristics.
        Uses automatic hash-based selection for consistent image picking within category.
        
        Note: This is a fallback method. Primary matching uses description-based matcher
        which has access to all 364 images with AI-generated descriptions.
        """
        # Use automatic selection (hash-based for consistency)
        return self._select_best_image_index_auto(category, title, ingredients)
    
    def _select_best_image_index_auto(self, category: str, title: str, ingredients: list) -> int:
        """
        Select the best image index for a recipe based on its characteristics.
        Uses recipe title and ingredients to determine which image best matches.
        
        Args:
            category: Foodish category (e.g., "rice", "dessert", "pasta")
            title: Recipe title
            ingredients: List of ingredient names
            
        Returns:
            Image index (1-based) that best matches the recipe
        """
        import hashlib
        
        title_lower = title.lower()
        ingredients_text = " ".join(ingredients).lower() if ingredients else ""
        combined_text = (title_lower + " " + ingredients_text).lower()
        
        # Category-specific image selection logic
        # Each category has different image counts and characteristics
        
        if category == "rice":
            # Rice category has ~35 images
            # Prioritize images that look like fried rice, kimchi rice, etc.
            
            # Kimchi fried rice - prefer images with red/orange color (kimchi)
            if any(kw in combined_text for kw in ["kimchi", "キムチ", "김치", "泡菜"]):
                # Use hash to consistently select from images 1-15 (likely fried rice with color)
                hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
                return (hash_val % 15) + 1  # Images 1-15
            
            # Fried rice - prefer images 1-20 (most are fried rice variations)
            if any(kw in combined_text for kw in ["fried", "frito", "frit", "炒", "볶음", "チャーハン"]):
                hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
                return (hash_val % 20) + 1  # Images 1-20
            
            # Cabbage/lettuce - prefer images that might have vegetables
            if any(kw in combined_text for kw in ["cabbage", "lettuce", "キャベツ", "レタス", "양배추", "卷心菜"]):
                hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
                return (hash_val % 25) + 1  # Images 1-25
            
            # Default: use hash to select from all available images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 35) + 1  # Rice has ~35 images
        
        elif category == "dessert":
            # Dessert category has ~36 images
            # Prioritize ice cream images
            
            # Ice cream / soft cream - prefer images 1-25 (likely ice cream)
            if any(kw in combined_text for kw in [
                "ice cream", "soft cream", "アイスクリーム", "ソフトクリーム", 
                "아이스크림", "冰淇淋", "helado", "glace", "gelato"
            ]):
                hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
                return (hash_val % 25) + 1  # Images 1-25
            
            # Chocolate - prefer images with chocolate
            if any(kw in combined_text for kw in ["chocolate", "choco", "チョコ", "초콜릿"]):
                hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
                return (hash_val % 20) + 1  # Images 1-20
            
            # Default: use hash to select from all available images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 36) + 1  # Dessert has ~36 images
        
        elif category == "pasta":
            # Pasta category has ~34 images
            # Most are spaghetti/pasta dishes
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 34) + 1
        
        elif category == "pizza":
            # Pizza category has ~95 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 95) + 1
        
        elif category == "burger":
            # Burger category has ~87 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 87) + 1
        
        elif category == "biryani":
            # Biryani category has ~81 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 81) + 1
        
        elif category == "dosa":
            # Dosa category has ~83 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 83) + 1
        
        elif category == "idly":
            # Idly category has ~77 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 77) + 1
        
        elif category == "samosa":
            # Samosa category has ~22 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 22) + 1
        
        elif category == "butter-chicken":
            # Butter-chicken category has ~22 images
            hash_val = int(hashlib.md5(combined_text.encode()).hexdigest(), 16)
            return (hash_val % 22) + 1
        
        # Default: return 1 if category unknown
        return 1
    
    async def close(self):
        """Close the HTTP client"""
        await self.client.aclose()


# Singleton instance
foodish_service = FoodishService()

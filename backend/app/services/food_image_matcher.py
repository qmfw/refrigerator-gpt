"""
Food image matcher using AI-generated descriptions.
Matches recipes to the best image from all 364 available images.
"""
import re
from typing import Optional, List, Tuple


class FoodImageMatcher:
    """Matches recipes to food images using description-based semantic matching"""
    
    def __init__(self):
        self.descriptions = self._load_descriptions()
        self.image_cache = {}  # Cache parsed descriptions for faster matching
    
    def _load_descriptions(self) -> dict:
        """Load food descriptions from Python module"""
        try:
            from app.services.food_descriptions import FOOD_DESCRIPTIONS
            
            print(f"✅ Loaded {len(FOOD_DESCRIPTIONS)} image descriptions")
            return FOOD_DESCRIPTIONS
        except ImportError as e:
            print(f"⚠️  Could not load food descriptions: {e}")
            return {}
    
    def _parse_description(self, description: str) -> dict:
        """Parse a description into structured components"""
        if description in self.image_cache:
            return self.image_cache[description]
        
        # Format: "food name with ingredient1, ingredient2, ingredient3"
        desc_lower = description.lower()
        
        # Extract food name (before "with")
        if " with " in desc_lower:
            parts = desc_lower.split(" with ", 1)
            food_name = parts[0].strip()
            ingredients_str = parts[1].strip()
        else:
            food_name = desc_lower
            ingredients_str = ""
        
        # Extract ingredients (comma-separated)
        ingredients = [ing.strip() for ing in ingredients_str.split(",") if ing.strip()]
        
        # Extract all keywords
        all_keywords = set()
        all_keywords.add(food_name)
        all_keywords.update(ingredients)
        
        # Also add individual words
        for word in description.lower().split():
            # Remove punctuation
            word = re.sub(r'[^\w\s]', '', word)
            if len(word) > 2:  # Ignore very short words
                all_keywords.add(word)
        
        result = {
            'food_name': food_name,
            'ingredients': ingredients,
            'all_keywords': all_keywords,
            'full_text': desc_lower
        }
        
        self.image_cache[description] = result
        return result
    
    def _calculate_match_score(self, recipe_text: str, description_data: dict) -> float:
        """
        Calculate match score between recipe and image description.
        Returns score from 0.0 to 1.0 (higher = better match)
        """
        recipe_lower = recipe_text.lower()
        recipe_words = set(re.findall(r'\b\w+\b', recipe_lower))
        
        desc_keywords = description_data['all_keywords']
        food_name = description_data['food_name']
        ingredients = description_data['ingredients']
        
        score = 0.0
        
        # Strategy 1: Exact food name match (highest weight)
        if food_name in recipe_lower:
            score += 0.4
        
        # Strategy 2: Food name word overlap
        food_name_words = set(re.findall(r'\b\w+\b', food_name))
        food_name_overlap = len(recipe_words & food_name_words)
        if food_name_words:
            score += 0.2 * (food_name_overlap / len(food_name_words))
        
        # Strategy 3: Ingredient matches (high weight)
        ingredient_matches = 0
        for ingredient in ingredients:
            # Check if ingredient or its words appear in recipe
            ing_words = set(re.findall(r'\b\w+\b', ingredient))
            if any(word in recipe_lower for word in ing_words if len(word) > 2):
                ingredient_matches += 1
        
        if ingredients:
            score += 0.3 * (ingredient_matches / len(ingredients))
        
        # Strategy 4: General keyword overlap
        keyword_overlap = len(recipe_words & desc_keywords)
        total_keywords = len(desc_keywords)
        if total_keywords > 0:
            score += 0.1 * (keyword_overlap / total_keywords)
        
        return min(score, 1.0)  # Cap at 1.0
    
    def find_best_match(self, recipe_title: str, ingredients: List[str] = None, language: str = "en") -> Optional[Tuple[str, float]]:
        """
        Find the best matching image for a recipe.
        
        Args:
            recipe_title: Recipe title
            ingredients: List of ingredient names
            language: Language code (default: "en") - uses matching language description
            
        Returns:
            Tuple of (image_path, score) or None if no match found
            image_path format: "category/filename.jpg"
        """
        if not self.descriptions:
            return None
        
        # Build recipe text for matching
        recipe_parts = [recipe_title]
        if ingredients:
            recipe_parts.extend(ingredients)
        recipe_text = " ".join(recipe_parts).lower()
        
        # Score all images
        matches = []
        for image_path, descriptions in self.descriptions.items():
            # Get description in the requested language, fallback to English
            if isinstance(descriptions, dict):
                description = descriptions.get(language, descriptions.get("en", ""))
            else:
                # Backward compatibility: if it's a string, use it directly
                description = descriptions
            
            if not description:
                continue
                
            desc_data = self._parse_description(description)
            score = self._calculate_match_score(recipe_text, desc_data)
            
            if score > 0:  # Only consider matches with some score
                matches.append((image_path, score, description))
        
        if not matches:
            return None
        
        # Sort by score (highest first)
        matches.sort(key=lambda x: x[1], reverse=True)
        
        best_match = matches[0]
        image_path, score, description = best_match
        
        print(f"🎯 Best match: {image_path} (score: {score:.2f}, lang: {language}) - {description}")
        
        # Return top match
        return (image_path, score)
    
    def get_image_url(self, image_path: str) -> str:
        """
        Convert image path to Foodish API URL.
        
        Args:
            image_path: Path like "dessert/dessert24.jpg"
            
        Returns:
            Full URL to the image
        """
        # Format: category/filename.jpg -> https://foodish-api.com/images/category/filename.jpg
        return f"https://foodish-api.com/images/{image_path}"


# Singleton instance
food_image_matcher = FoodImageMatcher()


#!/usr/bin/env python3
"""
Analyze food images using OpenAI Vision API and generate descriptions.
Output format: "<food name> with <ingredient>, <ingredient>, <ingredient>"
"""
import os
import json
import base64
import sys
from pathlib import Path
from openai import OpenAI

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False
    def tqdm(iterable, desc=""):
        return iterable

from app.config import settings

# Initialize OpenAI client
client = OpenAI(api_key=settings.openai_api_key)

# Image directory (relative to script location)
SCRIPT_DIR = Path(__file__).parent
IMAGE_DIR = SCRIPT_DIR.parent / "images"
OUTPUT_PY = SCRIPT_DIR / "food_descriptions.py"

# Hard constraints to prevent garbage
SYSTEM_PROMPT = """
You are a food ingredient extractor.

RULES (MANDATORY):
- Describe ONLY edible ingredients
- NO containers, plates, bowls, boards, spoons, forks, napkins
- NO background, lighting, people, hands
- NO words like: photo, image, picture, dish, plate, bowl
- NO repetition
- Use proper English
- Be specific (e.g. onion, tomato, spinach — NOT "veges")
- If unsure, omit the ingredient
- Max 12 words total
- Output format EXACTLY:
  "<food name> with <ingredient>, <ingredient>, <ingredient>"
  
Examples:
- "ice cream with vanilla, chocolate chips"
- "fried rice with egg, vegetables, soy sauce"
- "pasta with tomato sauce, basil, parmesan"
"""


def encode_image(path):
    """Encode image to base64"""
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")


def clean_text(text):
    """Clean and normalize the description text"""
    if not text:
        return "food with visible ingredients"
    
    text = text.lower().strip()

    banned_words = [
        "photo", "image", "picture", "plate", "bowl", "board",
        "spoon", "fork", "napkin", "background", "table",
        "hand", "person", "stock", "recipe", "dish"
    ]

    for w in banned_words:
        text = text.replace(w, "")

    # Remove repetition artifacts
    words = []
    for w in text.split():
        if len(words) == 0 or words[-1] != w:
            words.append(w)

    cleaned = " ".join(words).strip()
    
    # Final safety fallback
    if " with " not in cleaned:
        # Try to extract food name from path
        return "food with visible ingredients"
    
    return cleaned


def get_all_images():
    """Get all image files organized by category"""
    images = {}
    
    if not IMAGE_DIR.exists():
        print(f"❌ Image directory not found: {IMAGE_DIR}")
        return images
    
    # Walk through all subdirectories
    for category_dir in sorted(IMAGE_DIR.iterdir()):
        if not category_dir.is_dir():
            continue
        
        category = category_dir.name
        images[category] = []
        
        # Get all image files in this category
        for img_file in sorted(category_dir.glob("*.jpg")):
            images[category].append(img_file)
        
        # Also check for PNG files
        for img_file in sorted(category_dir.glob("*.png")):
            images[category].append(img_file)
        
        print(f"📁 {category}: {len(images[category])} images")
    
    return images


def analyze_image(image_path, category):
    """Analyze a single image using OpenAI Vision API"""
    try:
        image_b64 = encode_image(image_path)
        
        # Determine image format
        ext = image_path.suffix.lower()
        mime_type = "image/jpeg" if ext in [".jpg", ".jpeg"] else "image/png"
        
        response = client.chat.completions.create(
            model="gpt-4o",  # Use gpt-4o for vision
            temperature=0.2,
            max_tokens=40,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Extract the food ingredients."
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:{mime_type};base64,{image_b64}"
                            }
                        }
                    ]
                }
            ]
        )

        text = response.choices[0].message.content
        text = clean_text(text)
        
        return text
    except Exception as e:
        print(f"\n⚠️  Error processing {image_path}: {e}")
        return f"{category} with visible ingredients"


def main():
    """Main function to process all images"""
    print("🍽️  Food Image Analyzer")
    print("=" * 70)
    
    # Get all images
    all_images = get_all_images()
    
    if not all_images:
        print("❌ No images found!")
        return
    
    total_images = sum(len(imgs) for imgs in all_images.values())
    print(f"\n📊 Total images to process: {total_images}")
    print("=" * 70)
    
    results = {}
    
    # Process each category
    for category, image_files in all_images.items():
        print(f"\n🔍 Processing {category} ({len(image_files)} images)...")
        
        iterator = tqdm(image_files, desc=f"{category}") if HAS_TQDM else image_files
        for image_path in iterator:
            # Create key: "category/filename"
            relative_path = image_path.relative_to(IMAGE_DIR)
            key = str(relative_path).replace("\\", "/")  # Normalize path separators
            
            # Analyze image
            description = analyze_image(image_path, category)
            results[key] = description
    
    # Save results as Python file
    print(f"\n💾 Saving results to {OUTPUT_PY}...")
    
    # Group by category for better organization
    categories = {}
    for key, desc in results.items():
        category = key.split('/')[0]
        if category not in categories:
            categories[category] = []
        categories[category].append((key, desc))
    
    # Generate Python file
    with open(OUTPUT_PY, "w", encoding="utf-8") as f:
        f.write('"""\n')
        f.write('Food image descriptions generated by AI analysis.\n')
        f.write('Contains descriptions for all 364 food images in the format:\n')
        f.write('"food name with ingredient1, ingredient2, ingredient3"\n\n')
        f.write('Generated by: analyze_food_images.py\n')
        f.write(f'Total images: {len(results)} across {len(categories)} categories\n')
        f.write('"""\n\n')
        f.write('FOOD_DESCRIPTIONS = {\n')
        
        # Write by category for better readability
        for category in sorted(categories.keys()):
            f.write(f'    # ========================================\n')
            f.write(f'    # {category.upper()} ({len(categories[category])} images)\n')
            f.write(f'    # ========================================\n')
            
            for key, desc in sorted(categories[category]):
                # Clean description (remove quotes if present)
                clean_desc = desc.strip('"').strip()
                f.write(f'    "{key}": "{clean_desc}",\n')
            
            f.write('\n')
        
        f.write('}\n')
    
    print(f"✅ Saved {len(results)} descriptions to {OUTPUT_PY}")
    print("\n📋 Sample results:")
    for i, (key, desc) in enumerate(list(results.items())[:5]):
        clean_desc = desc.strip('"').strip()
        print(f"  {key}: {clean_desc}")
    
    if len(results) > 5:
        print(f"  ... and {len(results) - 5} more")


if __name__ == "__main__":
    main()


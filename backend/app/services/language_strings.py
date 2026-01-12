"""
Language-specific strings for OpenAI service.
Supports all 27 languages: en, ar, bn, zh, da, nl, fi, fr, de, el, he, hi, id, it, ja, ko, no, pl, pt, ro, ru, es, sv, th, tr, uk, vi
"""

# Import language-specific strings
from app.services.languages.arabic import (
    INGREDIENT_DETECTION_PROMPT_AR,
    NON_FOOD_KEYWORDS_AR,
    ERROR_MESSAGES_AR,
)
from app.services.languages.bengali import (
    INGREDIENT_DETECTION_PROMPT_BN,
    NON_FOOD_KEYWORDS_BN,
    ERROR_MESSAGES_BN,
)
from app.services.languages.danish import (
    INGREDIENT_DETECTION_PROMPT_DA,
    NON_FOOD_KEYWORDS_DA,
    ERROR_MESSAGES_DA,
)
from app.services.languages.german import (
    INGREDIENT_DETECTION_PROMPT_DE,
    NON_FOOD_KEYWORDS_DE,
    ERROR_MESSAGES_DE,
)
from app.services.languages.greek import (
    INGREDIENT_DETECTION_PROMPT_EL,
    NON_FOOD_KEYWORDS_EL,
    ERROR_MESSAGES_EL,
)
from app.services.languages.english import (
    INGREDIENT_DETECTION_PROMPT_EN,
    NON_FOOD_KEYWORDS_EN,
    ERROR_MESSAGES_EN,
)
from app.services.languages.spanish import (
    INGREDIENT_DETECTION_PROMPT_ES,
    NON_FOOD_KEYWORDS_ES,
    ERROR_MESSAGES_ES,
)
from app.services.languages.finnish import (
    INGREDIENT_DETECTION_PROMPT_FI,
    NON_FOOD_KEYWORDS_FI,
    ERROR_MESSAGES_FI,
)
from app.services.languages.french import (
    INGREDIENT_DETECTION_PROMPT_FR,
    NON_FOOD_KEYWORDS_FR,
    ERROR_MESSAGES_FR,
)
from app.services.languages.hebrew import (
    INGREDIENT_DETECTION_PROMPT_HE,
    NON_FOOD_KEYWORDS_HE,
    ERROR_MESSAGES_HE,
)
from app.services.languages.hindi import (
    INGREDIENT_DETECTION_PROMPT_HI,
    NON_FOOD_KEYWORDS_HI,
    ERROR_MESSAGES_HI,
)
from app.services.languages.indonesian import (
    INGREDIENT_DETECTION_PROMPT_ID,
    NON_FOOD_KEYWORDS_ID,
    ERROR_MESSAGES_ID,
)
from app.services.languages.italian import (
    INGREDIENT_DETECTION_PROMPT_IT,
    NON_FOOD_KEYWORDS_IT,
    ERROR_MESSAGES_IT,
)
from app.services.languages.japanese import (
    INGREDIENT_DETECTION_PROMPT_JA,
    NON_FOOD_KEYWORDS_JA,
    ERROR_MESSAGES_JA,
)
from app.services.languages.korean import (
    INGREDIENT_DETECTION_PROMPT_KO,
    NON_FOOD_KEYWORDS_KO,
    ERROR_MESSAGES_KO,
)
from app.services.languages.dutch import (
    INGREDIENT_DETECTION_PROMPT_NL,
    NON_FOOD_KEYWORDS_NL,
    ERROR_MESSAGES_NL,
)
from app.services.languages.norwegian import (
    INGREDIENT_DETECTION_PROMPT_NO,
    NON_FOOD_KEYWORDS_NO,
    ERROR_MESSAGES_NO,
)
from app.services.languages.polish import (
    INGREDIENT_DETECTION_PROMPT_PL,
    NON_FOOD_KEYWORDS_PL,
    ERROR_MESSAGES_PL,
)
from app.services.languages.portuguese import (
    INGREDIENT_DETECTION_PROMPT_PT,
    NON_FOOD_KEYWORDS_PT,
    ERROR_MESSAGES_PT,
)
from app.services.languages.romanian import (
    INGREDIENT_DETECTION_PROMPT_RO,
    NON_FOOD_KEYWORDS_RO,
    ERROR_MESSAGES_RO,
)
from app.services.languages.russian import (
    INGREDIENT_DETECTION_PROMPT_RU,
    NON_FOOD_KEYWORDS_RU,
    ERROR_MESSAGES_RU,
)
from app.services.languages.swedish import (
    INGREDIENT_DETECTION_PROMPT_SV,
    NON_FOOD_KEYWORDS_SV,
    ERROR_MESSAGES_SV,
)
from app.services.languages.thai import (
    INGREDIENT_DETECTION_PROMPT_TH,
    NON_FOOD_KEYWORDS_TH,
    ERROR_MESSAGES_TH,
)
from app.services.languages.turkish import (
    INGREDIENT_DETECTION_PROMPT_TR,
    NON_FOOD_KEYWORDS_TR,
    ERROR_MESSAGES_TR,
)
from app.services.languages.ukrainian import (
    INGREDIENT_DETECTION_PROMPT_UK,
    NON_FOOD_KEYWORDS_UK,
    ERROR_MESSAGES_UK,
)
from app.services.languages.vietnamese import (
    INGREDIENT_DETECTION_PROMPT_VI,
    NON_FOOD_KEYWORDS_VI,
    ERROR_MESSAGES_VI,
)
from app.services.languages.chinese import (
    INGREDIENT_DETECTION_PROMPT_ZH,
    NON_FOOD_KEYWORDS_ZH,
    ERROR_MESSAGES_ZH,
)

# Combine all languages into unified dictionaries
INGREDIENT_DETECTION_PROMPTS = {
    "ar": INGREDIENT_DETECTION_PROMPT_AR,
    "bn": INGREDIENT_DETECTION_PROMPT_BN,
    "da": INGREDIENT_DETECTION_PROMPT_DA,
    "de": INGREDIENT_DETECTION_PROMPT_DE,
    "el": INGREDIENT_DETECTION_PROMPT_EL,
    "en": INGREDIENT_DETECTION_PROMPT_EN,
    "es": INGREDIENT_DETECTION_PROMPT_ES,
    "fi": INGREDIENT_DETECTION_PROMPT_FI,
    "fr": INGREDIENT_DETECTION_PROMPT_FR,
    "he": INGREDIENT_DETECTION_PROMPT_HE,
    "hi": INGREDIENT_DETECTION_PROMPT_HI,
    "id": INGREDIENT_DETECTION_PROMPT_ID,
    "it": INGREDIENT_DETECTION_PROMPT_IT,
    "ja": INGREDIENT_DETECTION_PROMPT_JA,
    "ko": INGREDIENT_DETECTION_PROMPT_KO,
    "nl": INGREDIENT_DETECTION_PROMPT_NL,
    "no": INGREDIENT_DETECTION_PROMPT_NO,
    "pl": INGREDIENT_DETECTION_PROMPT_PL,
    "pt": INGREDIENT_DETECTION_PROMPT_PT,
    "ro": INGREDIENT_DETECTION_PROMPT_RO,
    "ru": INGREDIENT_DETECTION_PROMPT_RU,
    "sv": INGREDIENT_DETECTION_PROMPT_SV,
    "th": INGREDIENT_DETECTION_PROMPT_TH,
    "tr": INGREDIENT_DETECTION_PROMPT_TR,
    "uk": INGREDIENT_DETECTION_PROMPT_UK,
    "vi": INGREDIENT_DETECTION_PROMPT_VI,
    "zh": INGREDIENT_DETECTION_PROMPT_ZH,
}

NON_FOOD_KEYWORDS = {
    "ar": NON_FOOD_KEYWORDS_AR,
    "bn": NON_FOOD_KEYWORDS_BN,
    "da": NON_FOOD_KEYWORDS_DA,
    "de": NON_FOOD_KEYWORDS_DE,
    "el": NON_FOOD_KEYWORDS_EL,
    "en": NON_FOOD_KEYWORDS_EN,
    "es": NON_FOOD_KEYWORDS_ES,
    "fi": NON_FOOD_KEYWORDS_FI,
    "fr": NON_FOOD_KEYWORDS_FR,
    "he": NON_FOOD_KEYWORDS_HE,
    "hi": NON_FOOD_KEYWORDS_HI,
    "id": NON_FOOD_KEYWORDS_ID,
    "it": NON_FOOD_KEYWORDS_IT,
    "ja": NON_FOOD_KEYWORDS_JA,
    "ko": NON_FOOD_KEYWORDS_KO,
    "nl": NON_FOOD_KEYWORDS_NL,
    "no": NON_FOOD_KEYWORDS_NO,
    "pl": NON_FOOD_KEYWORDS_PL,
    "pt": NON_FOOD_KEYWORDS_PT,
    "ro": NON_FOOD_KEYWORDS_RO,
    "ru": NON_FOOD_KEYWORDS_RU,
    "sv": NON_FOOD_KEYWORDS_SV,
    "th": NON_FOOD_KEYWORDS_TH,
    "tr": NON_FOOD_KEYWORDS_TR,
    "uk": NON_FOOD_KEYWORDS_UK,
    "vi": NON_FOOD_KEYWORDS_VI,
    "zh": NON_FOOD_KEYWORDS_ZH,
}

ERROR_MESSAGES = {
    "ar": ERROR_MESSAGES_AR,
    "bn": ERROR_MESSAGES_BN,
    "da": ERROR_MESSAGES_DA,
    "de": ERROR_MESSAGES_DE,
    "el": ERROR_MESSAGES_EL,
    "en": ERROR_MESSAGES_EN,
    "es": ERROR_MESSAGES_ES,
    "fi": ERROR_MESSAGES_FI,
    "fr": ERROR_MESSAGES_FR,
    "he": ERROR_MESSAGES_HE,
    "hi": ERROR_MESSAGES_HI,
    "id": ERROR_MESSAGES_ID,
    "it": ERROR_MESSAGES_IT,
    "ja": ERROR_MESSAGES_JA,
    "ko": ERROR_MESSAGES_KO,
    "nl": ERROR_MESSAGES_NL,
    "no": ERROR_MESSAGES_NO,
    "pl": ERROR_MESSAGES_PL,
    "pt": ERROR_MESSAGES_PT,
    "ro": ERROR_MESSAGES_RO,
    "ru": ERROR_MESSAGES_RU,
    "sv": ERROR_MESSAGES_SV,
    "th": ERROR_MESSAGES_TH,
    "tr": ERROR_MESSAGES_TR,
    "uk": ERROR_MESSAGES_UK,
    "vi": ERROR_MESSAGES_VI,
    "zh": ERROR_MESSAGES_ZH,
}

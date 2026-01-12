"""
Language-specific strings for OpenAI service.
Supports all 27 languages: en, ar, bn, zh, da, nl, fi, fr, de, el, he, hi, id, it, ja, ko, no, pl, pt, ro, ru, es, sv, th, tr, uk, vi
"""

# Prompts for ingredient detection
# COST REDUCTION: Return ONLY comma-separated list, no JSON, no descriptions, max 10 items
# IMPORTANT: Only food ingredients, ignore hands, backgrounds, surfaces, containers
INGREDIENT_DETECTION_PROMPTS = {
    # English (first)
    "en": "Return ONLY food ingredients separated by commas. Ignore hands, backgrounds, surfaces, containers. No explanations. Max 10 items.",
    # Arabic
    "ar": "أعد فقط مكونات الطعام مفصولة بفواصل. تجاهل الأيدي والخلفيات والأسطح والحاويات. لا تفسيرات. حد أقصى 10 عناصر.",
    # Bengali
    "bn": "শুধুমাত্র খাদ্য উপাদান কমা দ্বারা পৃথক করে ফেরত দিন। হাত, পটভূমি, পৃষ্ঠতল, পাত্র উপেক্ষা করুন। কোন ব্যাখ্যা নেই। সর্বোচ্চ 10টি আইটেম।",
    # Chinese
    "zh": "只返回用逗号分隔的食物成分。忽略手、背景、表面、容器。无解释。最多10项。",
    # Danish
    "da": "Returner kun madingredienser adskilt af kommaer. Ignorer hænder, baggrunde, overflader, beholdere. Ingen forklaringer. Max 10 emner.",
    # Dutch
    "nl": "Geef alleen voedselingrediënten gescheiden door komma's. Negeer handen, achtergronden, oppervlakken, containers. Geen uitleg. Max 10 items.",
    # Finnish
    "fi": "Palauta vain ruoka-aineet pilkuilla erotettuina. Ohita kädet, taustat, pinnat, astiat. Ei selityksiä. Max 10 kohdetta.",
    # French
    "fr": "Retournez uniquement des ingrédients alimentaires séparés par des virgules. Ignorez les mains, arrière-plans, surfaces, contenants. Pas d'explications. Max 10 éléments.",
    # German
    "de": "Geben Sie nur Lebensmittelzutaten durch Kommas getrennt zurück. Ignorieren Sie Hände, Hintergründe, Oberflächen, Behälter. Keine Erklärungen. Max 10 Artikel.",
    # Greek
    "el": "Επιστρέψτε μόνο συστατικά φαγητού διαχωρισμένα με κόμματα. Αγνοήστε χέρια, φόντα, επιφάνειες, δοχεία. Χωρίς εξηγήσεις. Μέγιστο 10 στοιχεία.",
    # Hebrew
    "he": "החזר רק מרכיבי מזון מופרדים בפסיקים. התעלם מידיים, רקעים, משטחים, מיכלים. ללא הסברים. מקסימום 10 פריטים.",
    # Hindi
    "hi": "केवल खाद्य सामग्री अल्पविराम से अलग करके लौटाएं। हाथ, पृष्ठभूमि, सतह, कंटेनर को नजरअंदाज करें। कोई स्पष्टीकरण नहीं। अधिकतम 10 आइटम।",
    # Indonesian
    "id": "Kembalikan hanya bahan makanan yang dipisahkan koma. Abaikan tangan, latar belakang, permukaan, wadah. Tanpa penjelasan. Maks 10 item.",
    # Italian
    "it": "Restituisci solo ingredienti alimentari separati da virgole. Ignora mani, sfondi, superfici, contenitori. Nessuna spiegazione. Max 10 elementi.",
    # Japanese
    "ja": "食品材料のみをカンマ区切りで返す。手、背景、床、光、表面、容器は無視。説明なし。最大10項目。",
    # Korean
    "ko": "음식 재료만 쉼표로 구분하여 반환. 손, 배경, 바닥, 표면, 용기는 무시. 설명 없음. 최대 10개 항목.",
    # Norwegian
    "no": "Returner kun matingredienser adskilt med kommaer. Ignorer hender, bakgrunner, overflater, beholdere. Ingen forklaringer. Maks 10 elementer.",
    # Polish
    "pl": "Zwróć tylko składniki żywności oddzielone przecinkami. Ignoruj dłonie, tła, powierzchnie, pojemniki. Bez wyjaśnień. Max 10 pozycji.",
    # Portuguese
    "pt": "Retorne apenas ingredientes alimentares separados por vírgulas. Ignore mãos, fundos, superfícies, recipientes. Sem explicações. Máx 10 itens.",
    # Romanian
    "ro": "Returnează doar ingrediente alimentare separate prin virgulă. Ignoră mâinile, fundalurile, suprafețele, containerele. Fără explicații. Max 10 elemente.",
    # Russian
    "ru": "Верните только пищевые ингредиенты через запятую. Игнорируйте руки, фоны, поверхности, контейнеры. Без объяснений. Макс 10 элементов.",
    # Spanish
    "es": "Devuelve solo ingredientes alimentarios separados por comas. Ignora manos, fondos, superficies, contenedores. Sin explicaciones. Máx 10 elementos.",
    # Swedish
    "sv": "Returnera endast livsmedelsingredienser separerade med kommatecken. Ignorera händer, bakgrunder, ytor, behållare. Inga förklaringar. Max 10 objekt.",
    # Thai
    "th": "คืนเฉพาะส่วนผสมอาหารที่คั่นด้วยจุลภาค ไม่สนใจมือ พื้นหลัง พื้นผิว ภาชนะ ไม่มีคำอธิบาย สูงสุด 10 รายการ",
    # Turkish
    "tr": "Sadece virgülle ayrılmış gıda malzemeleri döndür. Elleri, arka planları, yüzeyleri, kapları yoksay. Açıklama yok. Maks 10 öğe.",
    # Ukrainian
    "uk": "Поверніть лише харчові інгредієнти через кому. Ігноруйте руки, фони, поверхні, контейнери. Без пояснень. Макс 10 елементів.",
    # Vietnamese
    "vi": "Chỉ trả về nguyên liệu thực phẩm cách nhau bằng dấu phẩy. Bỏ qua tay, nền, bề mặt, hộp đựng. Không giải thích. Tối đa 10 mục.",
}

# Non-food keywords to filter out (hands, backgrounds, surfaces, containers, etc.)
# Supports all 27 languages
NON_FOOD_KEYWORDS = {
    'en': ['hand', 'hands', 'background', 'floor', 'surface', 'light', 'container', 'table', 'counter'],
    'ar': ['يد', 'أيدي', 'خلفية', 'أرضية', 'سطح', 'ضوء', 'حاوية', 'طاولة', 'عداد'],
    'bn': ['হাত', 'হাত', 'পটভূমি', 'মেঝে', 'পৃষ্ঠ', 'আলো', 'ধারক', 'টেবিল', 'কাউন্টার'],
    'zh': ['手', '手', '背景', '地板', '表面', '光', '容器', '桌子', '柜台'],
    'da': ['hånd', 'hænder', 'baggrund', 'gulv', 'overflade', 'lys', 'beholder', 'bord', 'disk'],
    'nl': ['hand', 'handen', 'achtergrond', 'vloer', 'oppervlak', 'licht', 'container', 'tafel', 'balie'],
    'fi': ['käsi', 'kädet', 'tausta', 'lattia', 'pinta', 'valo', 'astia', 'pöytä', 'tiskipöytä'],
    'fr': ['main', 'mains', 'arrière-plan', 'sol', 'surface', 'lumière', 'conteneur', 'table', 'comptoir'],
    'de': ['hand', 'hände', 'hintergrund', 'boden', 'oberfläche', 'licht', 'behälter', 'tisch', 'theke'],
    'el': ['χέρι', 'χέρια', 'φόντο', 'πάτωμα', 'επιφάνεια', 'φως', 'δοχείο', 'τραπέζι', 'πάγκος'],
    'he': ['יד', 'ידיים', 'רקע', 'רצפה', 'משטח', 'אור', 'מיכל', 'שולחן', 'דלפק'],
    'hi': ['हाथ', 'हाथ', 'पृष्ठभूमि', 'फर्श', 'सतह', 'प्रकाश', 'कंटेनर', 'मेज', 'काउंटर'],
    'id': ['tangan', 'tangan', 'latar belakang', 'lantai', 'permukaan', 'cahaya', 'wadah', 'meja', 'konter'],
    'it': ['mano', 'mani', 'sfondo', 'pavimento', 'superficie', 'luce', 'contenitore', 'tavolo', 'bancone'],
    'ja': ['手', '手', '背景', '床', '表面', '光', '容器', 'テーブル', 'カウンター'],
    'ko': ['손', '손', '배경', '바닥', '표면', '빛', '용기', '테이블', '카운터'],
    'no': ['hånd', 'hender', 'bakgrunn', 'gulv', 'overflate', 'lys', 'beholder', 'bord', 'disk'],
    'pl': ['ręka', 'ręce', 'tło', 'podłoga', 'powierzchnia', 'światło', 'pojemnik', 'stół', 'lada'],
    'pt': ['mão', 'mãos', 'fundo', 'chão', 'superfície', 'luz', 'recipiente', 'mesa', 'balcão'],
    'ro': ['mână', 'mâini', 'fundal', 'podea', 'suprafață', 'lumină', 'recipient', 'masă', 'tejghea'],
    'ru': ['рука', 'руки', 'фон', 'пол', 'поверхность', 'свет', 'контейнер', 'стол', 'прилавок'],
    'es': ['mano', 'manos', 'fondo', 'suelo', 'superficie', 'luz', 'recipiente', 'mesa', 'mostrador'],
    'sv': ['hand', 'händer', 'bakgrund', 'golv', 'yta', 'ljus', 'behållare', 'bord', 'disk'],
    'th': ['มือ', 'มือ', 'พื้นหลัง', 'พื้น', 'พื้นผิว', 'แสง', 'ภาชนะ', 'โต๊ะ', 'เคาน์เตอร์'],
    'tr': ['el', 'eller', 'arka plan', 'zemin', 'yüzey', 'ışık', 'kap', 'masa', 'tezgah'],
    'uk': ['рука', 'руки', 'фон', 'підлога', 'поверхня', 'світло', 'контейнер', 'стіл', 'прилавок'],
    'vi': ['tay', 'tay', 'nền', 'sàn', 'bề mặt', 'ánh sáng', 'hộp đựng', 'bàn', 'quầy'],
}

# Error messages to filter out (apologies, can't identify, etc.)
# Supports all 27 languages
ERROR_MESSAGES = {
    'en': ['sorry', "i'm sorry", "i can't", "can't identify", "cannot identify", "unable to identify", "no ingredients", "no food"],
    'ar': ['آسف', 'عذراً', 'لا يمكن', 'لا أستطيع', 'لم أتمكن', 'لا يمكن تحديد', 'لا يمكن التعرف', 'لا مكونات', 'لا طعام'],
    'bn': ['দুঃখিত', 'আমি দুঃখিত', 'আমি পারি না', 'শনাক্ত করতে পারি না', 'শনাক্ত করা যায় না', 'শনাক্ত করতে অক্ষম', 'কোন উপাদান নেই', 'কোন খাবার নেই'],
    'zh': ['抱歉', '对不起', '我不能', '无法识别', '无法确定', '不能识别', '没有成分', '没有食物'],
    'da': ['undskyld', 'jeg beklager', 'jeg kan ikke', 'kan ikke identificere', 'kan ikke genkende', 'ikke i stand til at identificere', 'ingen ingredienser', 'ingen mad'],
    'nl': ['sorry', 'het spijt me', 'ik kan niet', 'kan niet identificeren', 'kan niet herkennen', 'niet in staat om te identificeren', 'geen ingrediënten', 'geen voedsel'],
    'fi': ['anteeksi', 'olen pahoillani', 'en voi', 'en voi tunnistaa', 'ei voida tunnistaa', 'kykenemätön tunnistamaan', 'ei aineksia', 'ei ruokaa'],
    'fr': ['désolé', 'je suis désolé', 'je ne peux pas', 'ne peut pas identifier', 'impossible d\'identifier', 'incapable d\'identifier', 'pas d\'ingrédients', 'pas de nourriture'],
    'de': ['entschuldigung', 'es tut mir leid', 'ich kann nicht', 'kann nicht identifizieren', 'kann nicht erkennen', 'nicht in der lage zu identifizieren', 'keine zutaten', 'kein essen'],
    'el': ['συγγνώμη', 'λυπάμαι', 'δεν μπορώ', 'δεν μπορώ να αναγνωρίσω', 'αδυναμία αναγνώρισης', 'ανίκανος να αναγνωρίσει', 'χωρίς συστατικά', 'χωρίς φαγητό'],
    'he': ['סליחה', 'אני מצטער', 'אני לא יכול', 'לא יכול לזהות', 'לא ניתן לזהות', 'לא מסוגל לזהות', 'אין מרכיבים', 'אין אוכל'],
    'hi': ['क्षमा करें', 'मुझे खेद है', 'मैं नहीं कर सकता', 'पहचान नहीं कर सकता', 'पहचान नहीं की जा सकती', 'पहचान करने में असमर्थ', 'कोई सामग्री नहीं', 'कोई भोजन नहीं'],
    'id': ['maaf', 'saya minta maaf', 'saya tidak bisa', 'tidak dapat mengidentifikasi', 'tidak dapat mengenali', 'tidak mampu mengidentifikasi', 'tidak ada bahan', 'tidak ada makanan'],
    'it': ['scusa', 'mi dispiace', 'non posso', 'non posso identificare', 'impossibile identificare', 'incapace di identificare', 'nessun ingrediente', 'nessun cibo'],
    'ja': ['申し訳', 'ごめん', 'できません', '特定できません', '特定することはできません', '特定することができません', '材料が見つかりません', '食品が見つかりません'],
    'ko': ['죄송', '미안', '할 수 없', '식별할 수 없', '식별할 수 없음', '식별할 수 없습니다', '재료를 찾을 수 없', '음식을 찾을 수 없'],
    'no': ['beklager', 'jeg beklager', 'jeg kan ikke', 'kan ikke identifisere', 'kan ikke gjenkjenne', 'ikke i stand til å identifisere', 'ingen ingredienser', 'ingen mat'],
    'pl': ['przepraszam', 'przepraszam', 'nie mogę', 'nie mogę zidentyfikować', 'nie można zidentyfikować', 'niezdolny do zidentyfikowania', 'brak składników', 'brak jedzenia'],
    'pt': ['desculpe', 'me desculpe', 'não posso', 'não consigo identificar', 'não é possível identificar', 'incapaz de identificar', 'sem ingredientes', 'sem comida'],
    'ro': ['scuze', 'îmi pare rău', 'nu pot', 'nu pot identifica', 'nu se poate identifica', 'incapabil să identifice', 'fără ingrediente', 'fără mâncare'],
    'ru': ['извините', 'мне жаль', 'я не могу', 'не могу определить', 'невозможно определить', 'не в состоянии определить', 'нет ингредиентов', 'нет еды'],
    'es': ['lo siento', 'disculpe', 'no puedo', 'no puedo identificar', 'no se puede identificar', 'incapaz de identificar', 'sin ingredientes', 'sin comida'],
    'sv': ['förlåt', 'jag är ledsen', 'jag kan inte', 'kan inte identifiera', 'kan inte känna igen', 'oförmögen att identifiera', 'inga ingredienser', 'ingen mat'],
    'th': ['ขอโทษ', 'ฉันขอโทษ', 'ฉันทำไม่ได้', 'ไม่สามารถระบุได้', 'ไม่สามารถระบุ', 'ไม่สามารถระบุได้', 'ไม่มีส่วนผสม', 'ไม่มีอาหาร'],
    'tr': ['üzgünüm', 'özür dilerim', 'yapamam', 'tanımlayamıyorum', 'tanımlanamıyor', 'tanımlayamıyor', 'malzeme yok', 'yiyecek yok'],
    'uk': ['вибачте', 'мені шкода', 'я не можу', 'не можу визначити', 'неможливо визначити', 'не в змозі визначити', 'немає інгредієнтів', 'немає їжі'],
    'vi': ['xin lỗi', 'tôi xin lỗi', 'tôi không thể', 'không thể xác định', 'không thể nhận diện', 'không thể xác định', 'không có nguyên liệu', 'không có thức ăn'],
}

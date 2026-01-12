import 'app_strings.dart';
import 'languages/index.dart';

/// Supported languages
/// English first, then alphabetical by English name
enum AppLanguage {
  english,
  arabic,
  bengali,
  chinese,
  danish,
  dutch,
  finnish,
  french,
  german,
  greek,
  hebrew,
  hindi,
  indonesian,
  italian,
  japanese,
  korean,
  norwegian,
  polish,
  portuguese,
  romanian,
  russian,
  spanish,
  swedish,
  thai,
  turkish,
  ukrainian,
  vietnamese,
  // Add more languages here as needed
}

/// Localization manager for the app
/// Handles all text translations
class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  /// Get localized string by key
  String translate(String key) {
    switch (language) {
      case AppLanguage.english:
        return englishStrings[key] ?? key;
      case AppLanguage.arabic:
        return arabicStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.bengali:
        return bengaliStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.chinese:
        return chineseStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.danish:
        return danishStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.dutch:
        return dutchStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.finnish:
        return finnishStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.french:
        return frenchStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.german:
        return germanStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.greek:
        return greekStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.hebrew:
        return hebrewStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.hindi:
        return hindiStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.indonesian:
        return indonesianStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.italian:
        return italianStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.japanese:
        return japaneseStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.korean:
        return koreanStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.norwegian:
        return norwegianStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.polish:
        return polishStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.portuguese:
        return portugueseStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.romanian:
        return romanianStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.russian:
        return russianStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.spanish:
        return spanishStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.swedish:
        return swedishStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.thai:
        return thaiStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.turkish:
        return turkishStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.ukrainian:
        return ukrainianStrings[key] ?? englishStrings[key] ?? key;
      case AppLanguage.vietnamese:
        return vietnameseStrings[key] ?? englishStrings[key] ?? key;
      // Add more language cases here
    }
  }

  /// Convenience getters for common strings
  String get appName => translate(AppStrings.appName);
  String get navHome => translate(AppStrings.navHome);
  String get navScan => translate(AppStrings.navScan);
  String get navHistory => translate(AppStrings.navHistory);
  String get scanMyFridge => translate(AppStrings.scanMyFridge);
  String get lastResult => translate(AppStrings.lastResult);
  String get takePhotosHelper => translate(AppStrings.takePhotosHelper);
  String get uploadFromGallery => translate(AppStrings.uploadFromGallery);
  String get reviewPhotos => translate(AppStrings.reviewPhotos);
  String get tapThumbnailToPreview =>
      translate(AppStrings.tapThumbnailToPreview);
  String get thisIsEnough => translate(AppStrings.thisIsEnough);
  String get addAnotherPhoto => translate(AppStrings.addAnotherPhoto);
  String get addPhoto => translate(AppStrings.addPhoto);
  String get takePhoto => translate(AppStrings.takePhoto);
  String get chooseFromGallery => translate(AppStrings.chooseFromGallery);
  String get confirmIngredients => translate(AppStrings.confirmIngredients);
  String get heresWhatIThink => translate(AppStrings.heresWhatIThink);
  String get mightBeWrong => translate(AppStrings.mightBeWrong);
  String get addSomethingElse => translate(AppStrings.addSomethingElse);
  String get cookWithThis => translate(AppStrings.cookWithThis);
  String get noIngredientsFound => translate(AppStrings.noIngredientsFound);
  String get lookingClosely => translate(AppStrings.lookingClosely);
  String get fridgeHasPotential => translate(AppStrings.fridgeHasPotential);
  String get heresWhatYouCanMake => translate(AppStrings.heresWhatYouCanMake);
  String get editIngredients => translate(AppStrings.editIngredients);
  String get scanAgain => translate(AppStrings.scanAgain);
  String get settings => translate(AppStrings.settings);
  String get languageLabel => translate(AppStrings.languageLabel);
  String get selectLanguage => translate(AppStrings.selectLanguage);
  String get useDeviceLanguage => translate(AppStrings.useDeviceLanguage);
  String get defaultLabel => translate(AppStrings.defaultLabel);
  String get clearHistory => translate(AppStrings.clearHistory);
  String get historyCleared => translate(AppStrings.historyCleared);
  String get clearHistoryTitle => translate(AppStrings.clearHistoryTitle);
  String get clearHistoryBody => translate(AppStrings.clearHistoryBody);
  String get about => translate(AppStrings.about);
  String get aboutTitle => translate(AppStrings.aboutTitle);
  String get aboutContent => translate(AppStrings.aboutContent);
  String get aboutDescription => translate(AppStrings.aboutDescription);
  String get version => translate(AppStrings.version);
  String get privacy => translate(AppStrings.privacy);
  String get privacyTitle => translate(AppStrings.privacyTitle);
  String get privacyContent => translate(AppStrings.privacyContent);
  String get privacyParagraph1 => translate(AppStrings.privacyParagraph1);
  String get privacyParagraph2 => translate(AppStrings.privacyParagraph2);
  String get privacyParagraph3 => translate(AppStrings.privacyParagraph3);
  String get privacyParagraph4 => translate(AppStrings.privacyParagraph4);
  String get privacyParagraph5 => translate(AppStrings.privacyParagraph5);
  String get ok => translate(AppStrings.ok);
  String get cancel => translate(AppStrings.cancel);
  String get history => translate(AppStrings.history);
  String get emptyHistory => translate(AppStrings.emptyHistory);
  String get share => translate(AppStrings.share);
  String get recipeBadgeFastLazy => translate(AppStrings.recipeBadgeFastLazy);
  String get recipeBadgeActuallyGood =>
      translate(AppStrings.recipeBadgeActuallyGood);
  String get recipeBadgeShouldntWork =>
      translate(AppStrings.recipeBadgeShouldntWork);
  String get dietPreferences => translate(AppStrings.dietPreferences);
  String get dietPreferencesHelper =>
      translate(AppStrings.dietPreferencesHelper);

  // Diet Preference Sections
  String get avoidIngredients => translate(AppStrings.avoidIngredients);
  String get dietStyle => translate(AppStrings.dietStyle);
  String get cookingPreferences => translate(AppStrings.cookingPreferences);
  String get religious => translate(AppStrings.religious);

  // Avoid Ingredients
  String get nuts => translate(AppStrings.nuts);
  String get shellfish => translate(AppStrings.shellfish);
  String get dairy => translate(AppStrings.dairy);
  String get eggs => translate(AppStrings.eggs);
  String get gluten => translate(AppStrings.gluten);
  String get soy => translate(AppStrings.soy);

  // Diet Style
  String get vegan => translate(AppStrings.vegan);
  String get vegetarian => translate(AppStrings.vegetarian);
  String get pescatarian => translate(AppStrings.pescatarian);

  // Cooking Preferences
  String get lowCarb => translate(AppStrings.lowCarb);
  String get lowFat => translate(AppStrings.lowFat);

  // Religious
  String get halal => translate(AppStrings.halal);
  String get kosher => translate(AppStrings.kosher);

  /// Format plural strings
  String recipesFound(int count) {
    final template = translate(AppStrings.recipesFound);
    return template.replaceAll('{count}', count.toString());
  }

  String photoCount(int count) {
    final isPlural = count != 1;
    final template =
        isPlural ? translate(AppStrings.photos) : translate(AppStrings.photo);
    return '$count $template';
  }

  String minutesAgo(int minutes) {
    final template = translate(AppStrings.minutesAgo);
    return template.replaceAll('{minutes}', minutes.toString());
  }

  String hoursAgo(int hours) {
    final template = translate(AppStrings.hoursAgo);
    return template.replaceAll('{hours}', hours.toString());
  }

  String daysAgo(int days) {
    final template = translate(AppStrings.daysAgo);
    return template.replaceAll('{days}', days.toString());
  }

  String weeksAgo(int weeks) {
    final template = translate(AppStrings.weeksAgo);
    return template.replaceAll('{weeks}', weeks.toString());
  }

  /// Format time ago string based on time difference
  /// Returns localized "X minutes ago", "X hours ago", "Yesterday", etc.
  String formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return minutesAgo(difference.inMinutes);
      }
      return hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return translate(AppStrings.yesterday);
    } else if (difference.inDays < 7) {
      return daysAgo(difference.inDays);
    } else if (difference.inDays < 14) {
      return translate(AppStrings.weekAgo);
    } else {
      final weeks = (difference.inDays / 7).floor();
      return weeksAgo(weeks);
    }
  }
}

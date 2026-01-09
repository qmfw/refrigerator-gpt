import '../app_strings.dart';

/// Russian translations
const Map<String, String> russianStrings = {
  AppStrings.appName: 'FridgeGPT',
  AppStrings.navHome: 'Главная',
  AppStrings.navScan: 'Сканировать',
  AppStrings.navHistory: 'История',
  AppStrings.scanMyFridge: 'Сканировать мой холодильник',
  AppStrings.lastResult: 'ПОСЛЕДНИЙ РЕЗУЛЬТАТ',
  AppStrings.recipesFound: 'Найдено {count} рецептов',
  AppStrings.takePhotosHelper:
      'Сделайте 1–3 фотографии. Беспорядок — это нормально.',
  AppStrings.uploadFromGallery: 'Загрузить из галереи',
  AppStrings.reviewPhotos: 'Просмотр фотографий',
  AppStrings.tapThumbnailToPreview: 'Нажмите на миниатюру для предпросмотра',
  AppStrings.photo: 'фото',
  AppStrings.photos: 'фотографии',
  AppStrings.thisIsEnough: 'Этого достаточно',
  AppStrings.addAnotherPhoto: 'Добавить еще одну фотографию',
  AppStrings.confirmIngredients: 'Подтвердить ингредиенты',
  AppStrings.heresWhatIThink: 'Вот что, я думаю, у вас есть.',
  AppStrings.mightBeWrong: 'Я могу ошибаться. Исправьте что угодно.',
  AppStrings.addSomethingElse: 'Добавить что-то еще…',
  AppStrings.cookWithThis: '🍳 Готовить с этим',
  AppStrings.lookingClosely: 'Присматриваюсь…',
  AppStrings.fridgeHasPotential: 'У этого холодильника есть потенциал.',
  AppStrings.heresWhatYouCanMake: 'Вот что вы можете приготовить',
  AppStrings.editIngredients: 'Редактировать ингредиенты',
  AppStrings.scanAgain: 'Сканировать снова',
  AppStrings.recipeBadgeFastLazy: 'Быстро и Просто',
  AppStrings.recipeBadgeActuallyGood: 'Действительно Хорошо',
  AppStrings.recipeBadgeShouldntWork: 'Это не должно работать',
  AppStrings.share: 'Поделиться',
  AppStrings.settings: 'Настройки',
  AppStrings.languageLabel: 'Язык',
  AppStrings.selectLanguage: 'Выбрать язык',
  AppStrings.useDeviceLanguage: 'Использовать язык устройства',
  AppStrings.defaultLabel: 'По умолчанию',
  AppStrings.clearHistory: 'Очистить историю',
  AppStrings.historyCleared: 'История очищена',
  AppStrings.clearHistoryTitle: 'Очистить историю?',
  AppStrings.clearHistoryBody:
      'Это удалит все прошлые сканирования с этого устройства.\n\nЭто нельзя отменить.',
  AppStrings.about: 'О приложении',
  AppStrings.aboutTitle: 'О FridgeGPT',
  AppStrings.aboutContent:
      'FridgeGPT v1\n\nДружелюбное приложение, которое поможет вам готовить из того, что у вас есть.',
  AppStrings.aboutDescription:
      'FridgeGPT помогает превратить всё, что есть в вашем холодильнике, в простые рецепты.',
  AppStrings.version: 'Версия 1.0',
  AppStrings.privacy: 'Конфиденциальность',
  AppStrings.privacyTitle: 'Конфиденциальность',
  AppStrings.privacyContent:
      'Ваши фотографии обрабатываются безопасно и не хранятся постоянно.',
  AppStrings.privacyParagraph1:
      'FridgeGPT не требует аккаунта. Ваши сканирования хранятся только на этом устройстве.',
  AppStrings.privacyParagraph2:
      'Фотографии не хранятся на наших серверах. Когда вы сканируете холодильник, изображения кратко обрабатываются для определения ингредиентов, а затем сразу удаляются.',
  AppStrings.privacyParagraph3:
      'Мы не отслеживаем, что вы готовите или как часто используете приложение. Никакой аналитики, никаких поведенческих данных, никаких рекламных профилей.',
  AppStrings.privacyParagraph4:
      'Ваша история остается приватной. Удалите её в любое время из Настроек, и она исчезнет навсегда.',
  AppStrings.privacyParagraph5:
      'Мы не продаем ваши данные. Мы не делимся ими. Мы не хотим их.',
  AppStrings.ok: 'ОК',
  AppStrings.cancel: 'Отмена',
  AppStrings.history: 'История',
  AppStrings.emptyHistory: 'Истории пока нет',
  AppStrings.minutesAgo: '{minutes} минут назад',
  AppStrings.hoursAgo: '{hours} часов назад',
  AppStrings.yesterday: 'Вчера',
  AppStrings.daysAgo: '{days} дней назад',
  AppStrings.weekAgo: '1 неделю назад',
  AppStrings.weeksAgo: '{weeks} недель назад',
  AppStrings.dietPreferences: 'Диетические Предпочтения',
  AppStrings.dietPreferencesHelper:
      'Мы постараемся избегать их при предложении рецептов.',

  // Diet Preference Sections
  AppStrings.avoidIngredients: 'Избегать Ингредиентов',
  AppStrings.dietStyle: 'Стиль Питания',
  AppStrings.cookingPreferences: 'Кулинарные Предпочтения',
  AppStrings.religious: 'Религиозные',

  // Avoid Ingredients
  AppStrings.nuts: 'Орехи',
  AppStrings.shellfish: 'Морепродукты',
  AppStrings.dairy: 'Молочные Продукты',
  AppStrings.eggs: 'Яйца',
  AppStrings.gluten: 'Глютен',
  AppStrings.soy: 'Соя',

  // Diet Style
  AppStrings.vegan: 'Веган',
  AppStrings.vegetarian: 'Вегетарианец',
  AppStrings.pescatarian: 'Пескетарианец',

  // Cooking Preferences
  AppStrings.lowCarb: 'Низкоуглеводная',
  AppStrings.lowFat: 'Низкожировая',

  // Religious
  AppStrings.halal: 'Халяль',
  AppStrings.kosher: 'Кошер',
};

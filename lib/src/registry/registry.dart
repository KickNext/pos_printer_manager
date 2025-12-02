import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Функция десериализации настроек принтера из JSON.
typedef SettingsDeserializer =
    PrinterSettings Function(Map<String, dynamic> json);

/// Фабрика для создания обработчика протокола принтера.
typedef HandlerFactory =
    PrinterProtocolHandler Function(PrinterSettings settings);

/// Реестр плагинов принтеров.
///
/// Позволяет регистрировать и получать обработчики протоколов
/// для разных типов принтеров.
///
/// ## Пример использования:
///
/// ```dart
/// // Регистрация плагина
/// PrinterPluginRegistry.register<ReceiptPrinterSettings>(
///   printerType: PrinterPOSType.receiptPrinter,
///   deserializeSettings: (json) => ReceiptPrinterSettings.fromJson(json),
///   createHandler: (settings) => ReceiptPrinterHandler(settings: settings),
/// );
///
/// // Создание обработчика
/// final handler = PrinterPluginRegistry.buildHandler(config);
/// ```
class PrinterPluginRegistry {
  // Приватный конструктор для предотвращения создания экземпляров
  PrinterPluginRegistry._();

  /// Зарегистрированные десериализаторы по типу принтера.
  static final Map<PrinterPOSType, SettingsDeserializer> _deserializers = {};

  /// Зарегистрированные фабрики обработчиков по типу принтера.
  static final Map<PrinterPOSType, HandlerFactory> _factories = {};

  /// Проверяет, зарегистрирован ли плагин для указанного типа.
  static bool isRegistered(PrinterPOSType printerType) {
    return _deserializers.containsKey(printerType) &&
        _factories.containsKey(printerType);
  }

  /// Регистрирует плагин принтера.
  ///
  /// [printerType] — тип принтера для регистрации.
  /// [deserializeSettings] — функция десериализации настроек из JSON.
  /// [createHandler] — фабрика создания обработчика протокола.
  /// [allowOverwrite] — разрешить перезапись существующей регистрации.
  ///
  /// Выбрасывает [PluginAlreadyRegisteredException] если плагин
  /// уже зарегистрирован и [allowOverwrite] = false.
  static void register<T extends PrinterSettings>({
    required PrinterPOSType printerType,
    required SettingsDeserializer deserializeSettings,
    required HandlerFactory createHandler,
    bool allowOverwrite = false,
  }) {
    // Проверка на повторную регистрацию
    if (!allowOverwrite && isRegistered(printerType)) {
      throw PluginAlreadyRegisteredException(printerType);
    }

    _deserializers[printerType] = deserializeSettings;
    _factories[printerType] = createHandler;
  }

  /// Упрощённая регистрация плагина с конструктором настроек.
  ///
  /// [printerPosType] — тип принтера для регистрации.
  /// [ctor] — конструктор настроек принтера.
  /// [createHandler] — фабрика создания обработчика протокола.
  /// [allowOverwrite] — разрешить перезапись существующей регистрации.
  static void registerWithCtor<T extends PrinterSettings>({
    required PrinterPOSType printerPosType,
    required T Function(
      PrinterConnectionParamsDTO? params,
      Map<String, dynamic> json,
    )
    ctor,
    required HandlerFactory createHandler,
    bool allowOverwrite = false,
  }) {
    register<T>(
      printerType: printerPosType,
      deserializeSettings: (json) => PrinterSettings.fromJson(json, ctor),
      createHandler: createHandler,
      allowOverwrite: allowOverwrite,
    );
  }

  /// Строит обработчик протокола принтера по конфигурации.
  ///
  /// [config] — конфигурация принтера.
  ///
  /// Возвращает сконфигурированный [PrinterProtocolHandler].
  ///
  /// Выбрасывает [PluginNotRegisteredException] если плагин
  /// для типа принтера не зарегистрирован.
  static PrinterProtocolHandler buildHandler(PrinterConfig config) {
    final printerPosType = config.printerPosType;
    final deser = _deserializers[printerPosType];
    final factory = _factories[printerPosType];

    if (deser == null || factory == null) {
      throw PluginNotRegisteredException(printerPosType);
    }

    final settings = deser(config.rawSettings);
    return factory(settings);
  }

  /// Очищает все зарегистрированные плагины.
  ///
  /// Используется для тестирования.
  static void clearAll() {
    _deserializers.clear();
    _factories.clear();
  }

  /// Возвращает список зарегистрированных типов принтеров.
  static List<PrinterPOSType> get registeredTypes =>
      _deserializers.keys.toList();
}

import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/src/models/printer_config.dart';

/// Функция десериализации настроек принтера из JSON
typedef SettingsDeserializer =
    PrinterSettings Function(Map<String, dynamic> json);

/// Фабрика для создания обработчика протокола принтера
typedef HandlerFactory =
    PrinterProtocolHandler Function(PrinterSettings settings);

class PrinterPluginRegistry {
  // Изменено: ключи теперь строки
  static final Map<PrinterPOSType, SettingsDeserializer> _deserializers = {};
  static final Map<PrinterPOSType, HandlerFactory> _factories = {};

  /// Регистрирует плагин по строковому типу настроек
  static void register<T extends PrinterSettings>({
    // Добавлено: строковый идентификатор типа
    required PrinterPOSType printerType,
    required SettingsDeserializer deserializeSettings,
    required HandlerFactory createHandler,
  }) {
    _deserializers[printerType] = deserializeSettings;
    _factories[printerType] = createHandler;
  }

  /// Упрощённая регистрация плагина
  static void registerWithCtor<T extends PrinterSettings>({
    // Добавлено: строковый идентификатор типа
    required PrinterPOSType printerPosType,
    required T Function(
      PrinterConnectionParamsDTO? params,
      Map<String, dynamic> json,
    )
    ctor,
    required HandlerFactory createHandler,
  }) {
    register<T>(
      // Передаем typeName
      printerType: printerPosType,
      deserializeSettings: (json) => PrinterSettings.fromJson(json, ctor),
      createHandler: createHandler,
    );
  }

  /// Строит обработчик протокола принтера по конфигурации
  static PrinterProtocolHandler buildHandler(PrinterConfig config) {
    // Используем строковый тип из конфига
    final printerPosType = config.printerPosType;
    final deser = _deserializers[printerPosType];
    final factory = _factories[printerPosType];
    if (deser == null || factory == null) {
      throw StateError(
        'Handler for type \'$printerPosType\' is not registered',
      );
    }
    final settings = deser(config.rawSettings);
    return factory(settings);
  }
}

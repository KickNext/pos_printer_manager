import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printers/pos_printers.dart';

/// Функция десериализации настроек принтера из JSON
typedef SettingsDeserializer =
    PrinterSettings Function(Map<String, dynamic> json);

/// Фабрика для создания обработчика протокола принтера
typedef HandlerFactory =
    PrinterProtocolHandler Function(PrinterSettings settings);

class PrinterPluginRegistry {
  // Изменено: ключи теперь строки
  static final Map<String, SettingsDeserializer> _deserializers = {};
  static final Map<String, HandlerFactory> _factories = {};

  /// Регистрирует плагин по строковому типу настроек
  static void register<T extends PrinterSettings>({
    // Добавлено: строковый идентификатор типа
    required String typeName,
    required SettingsDeserializer deserializeSettings,
    required HandlerFactory createHandler,
  }) {
    _deserializers[typeName] = deserializeSettings;
    _factories[typeName] = createHandler;
  }

  /// Упрощённая регистрация плагина
  static void registerWithCtor<T extends PrinterSettings>({
    // Добавлено: строковый идентификатор типа
    required String typeName,
    required T Function(
      PrinterConnectionParams params,
      Map<String, dynamic> json,
    )
    ctor,
    required HandlerFactory createHandler,
  }) {
    register<T>(
      // Передаем typeName
      typeName: typeName,
      deserializeSettings: (json) => PrinterSettings.fromJson(json, ctor),
      createHandler: createHandler,
    );
  }

  /// Строит обработчик протокола принтера по конфигурации
  static PrinterProtocolHandler buildHandler(PrinterConfig config) {
    // Используем строковый тип из конфига
    final typeName = config.settingsType;
    final deser = _deserializers[typeName];
    final factory = _factories[typeName];
    if (deser == null || factory == null) {
      throw StateError(
        'Handler for type \'$typeName\' is not registered',
      );
    }
    final settings = deser(config.rawSettings);
    return factory(settings);
  }
}

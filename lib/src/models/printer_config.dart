import 'package:flutter/foundation.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Конфигурация POS-принтера.
///
/// Immutable класс, содержащий все настройки принтера.
/// Для изменения настроек используйте метод [copyWith].
///
/// ## Пример использования:
///
/// ```dart
/// final config = PrinterConfig(
///   id: '123',
///   name: 'Kitchen Printer',
///   printerPosType: PrinterPOSType.kitchenPrinter,
///   rawSettings: {'paperSize': 80},
/// );
///
/// // Создание копии с изменённым именем
/// final updated = config.copyWith(name: 'New Name');
/// ```
@immutable
class PrinterConfig {
  /// Уникальный идентификатор принтера.
  final String id;

  /// Отображаемое имя принтера.
  final String name;

  /// Тип принтера (чековый, кухонный, этикеточный и т.д.).
  final PrinterPOSType printerPosType;

  /// Дополнительные настройки принтера в формате JSON.
  ///
  /// Содержит специфичные для типа принтера параметры,
  /// такие как параметры подключения, категории блюд и т.д.
  final Map<String, dynamic> rawSettings;

  /// Создает конфигурацию принтера.
  ///
  /// [id] — уникальный идентификатор.
  /// [name] — отображаемое имя.
  /// [printerPosType] — тип принтера.
  /// [rawSettings] — дополнительные настройки.
  const PrinterConfig({
    required this.id,
    required this.name,
    required this.printerPosType,
    required this.rawSettings,
  });

  /// Создает конфигурацию из JSON.
  ///
  /// Выбрасывает [FormatException], если JSON некорректен.
  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    final typeName = json['printerPosType'] as String?;
    if (typeName == null) {
      throw const FormatException(
        'Printer type is not specified in the config',
      );
    }

    // Безопасный парсинг типа принтера
    PrinterPOSType type;
    try {
      type = PrinterPOSType.values.byName(typeName);
    } on ArgumentError {
      throw FormatException('Unknown printer type: $typeName');
    }

    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Invalid or missing printer ID');
    }

    final name = json['name'];
    if (name is! String) {
      throw const FormatException('Invalid or missing printer name');
    }

    return PrinterConfig(
      id: id,
      name: name,
      printerPosType: type,
      rawSettings: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(json['rawSettings'] ?? {}),
      ),
    );
  }

  /// Преобразует конфигурацию в JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'printerPosType': printerPosType.name,
      'rawSettings': rawSettings,
    };
  }

  /// Создает копию конфигурации с изменёнными полями.
  ///
  /// Все неуказанные параметры сохраняют текущие значения.
  PrinterConfig copyWith({
    String? id,
    String? name,
    PrinterPOSType? printerPosType,
    Map<String, dynamic>? rawSettings,
  }) {
    return PrinterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      printerPosType: printerPosType ?? this.printerPosType,
      rawSettings: rawSettings ?? this.rawSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterConfig &&
        other.id == id &&
        other.name == name &&
        other.printerPosType == printerPosType &&
        mapEquals(other.rawSettings, rawSettings);
  }

  @override
  int get hashCode => Object.hash(id, name, printerPosType, rawSettings);

  @override
  String toString() {
    return 'PrinterConfig(id: $id, name: $name, type: ${printerPosType.name})';
  }
}

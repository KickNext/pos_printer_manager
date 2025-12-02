/// Модуль типизированных исключений для системы управления принтерами.
///
/// Предоставляет иерархию исключений для разных типов ошибок,
/// что позволяет точно обрабатывать конкретные ситуации.
///
/// ## Пример использования:
///
/// ```dart
/// try {
///   final handler = PrinterPluginRegistry.buildHandler(config);
/// } on PluginNotRegisteredException catch (e) {
///   print('Plugin not found: ${e.printerType}');
/// } on PrinterException catch (e) {
///   print('Printer error: ${e.message}');
/// }
/// ```
library;

import 'package:pos_printer_manager/src/plugins/printer_type.dart';

/// Базовое исключение для всех ошибок принтера.
///
/// Служит основой для иерархии исключений и может использоваться
/// для перехвата всех ошибок, связанных с принтерами.
sealed class PrinterException implements Exception {
  /// Сообщение об ошибке.
  final String message;

  /// Дополнительные детали ошибки.
  final String? details;

  /// Создает исключение принтера.
  const PrinterException(this.message, {this.details});

  @override
  String toString() {
    if (details != null) {
      return '$runtimeType: $message\nDetails: $details';
    }
    return '$runtimeType: $message';
  }
}

/// Исключение: плагин принтера не зарегистрирован.
///
/// Выбрасывается когда запрашивается обработчик для типа принтера,
/// который не был зарегистрирован в [PrinterPluginRegistry].
///
/// ## Пример:
///
/// ```dart
/// try {
///   final handler = PrinterPluginRegistry.buildHandler(config);
/// } on PluginNotRegisteredException catch (e) {
///   // Зарегистрировать плагин или показать ошибку пользователю
///   print('Unknown printer type: ${e.printerType}');
/// }
/// ```
final class PluginNotRegisteredException extends PrinterException {
  /// Тип принтера, для которого плагин не найден.
  final PrinterPOSType printerType;

  /// Создает исключение о незарегистрированном плагине.
  const PluginNotRegisteredException(this.printerType)
    : super('Printer plugin is not registered');

  @override
  String toString() =>
      'PluginNotRegisteredException: Handler for type "$printerType" is not registered. '
      'Make sure to call PrinterPOSType.registerPrinterTypes() during initialization.';
}

/// Исключение: ошибка конфигурации принтера.
///
/// Выбрасывается когда конфигурация принтера содержит
/// некорректные или несовместимые данные.
final class PrinterConfigurationException extends PrinterException {
  /// ID принтера с некорректной конфигурацией.
  final String? printerId;

  /// Создает исключение о некорректной конфигурации.
  const PrinterConfigurationException(
    super.message, {
    this.printerId,
    super.details,
  });

  @override
  String toString() {
    final idPart = printerId != null ? ' (printer: $printerId)' : '';
    return 'PrinterConfigurationException$idPart: $message';
  }
}

/// Исключение: ошибка подключения к принтеру.
///
/// Выбрасывается когда не удаётся установить или поддерживать
/// соединение с принтером.
final class PrinterConnectionException extends PrinterException {
  /// ID принтера, к которому не удалось подключиться.
  final String? printerId;

  /// Код ошибки (если есть).
  final int? errorCode;

  /// Создает исключение о проблеме с подключением.
  const PrinterConnectionException(
    super.message, {
    this.printerId,
    this.errorCode,
    super.details,
  });

  @override
  String toString() {
    final parts = <String>['PrinterConnectionException'];
    if (printerId != null) parts.add('printer: $printerId');
    if (errorCode != null) parts.add('code: $errorCode');
    return '${parts.join(', ')}: $message';
  }
}

/// Исключение: ошибка печати.
///
/// Выбрасывается когда операция печати не может быть выполнена.
final class PrintingException extends PrinterException {
  /// ID принтера, на котором произошла ошибка.
  final String? printerId;

  /// Тип задания печати (если известен).
  final String? jobType;

  /// Создает исключение об ошибке печати.
  const PrintingException(
    super.message, {
    this.printerId,
    this.jobType,
    super.details,
  });

  @override
  String toString() {
    final parts = <String>['PrintingException'];
    if (printerId != null) parts.add('printer: $printerId');
    if (jobType != null) parts.add('job: $jobType');
    return '${parts.join(', ')}: $message';
  }
}

// ПРИМЕЧАНИЕ: UsbPermissionDeniedException определён в пакете pos_printers
// и экспортируется оттуда. Здесь дубликат не нужен.

/// Исключение: принтер не найден.
///
/// Выбрасывается когда принтер с указанным ID не найден в системе.
final class PrinterNotFoundException extends PrinterException {
  /// ID искомого принтера.
  final String printerId;

  /// Создает исключение о ненайденном принтере.
  const PrinterNotFoundException(this.printerId) : super('Printer not found');

  @override
  String toString() =>
      'PrinterNotFoundException: Printer with ID "$printerId" not found';
}

/// Исключение: попытка повторной регистрации плагина.
///
/// Выбрасывается когда плагин для определённого типа принтера
/// уже зарегистрирован.
final class PluginAlreadyRegisteredException extends PrinterException {
  /// Тип принтера, плагин которого уже зарегистрирован.
  final PrinterPOSType printerType;

  /// Создает исключение о повторной регистрации.
  const PluginAlreadyRegisteredException(this.printerType)
    : super('Plugin is already registered');

  @override
  String toString() =>
      'PluginAlreadyRegisteredException: Plugin for type "$printerType" is already registered';
}

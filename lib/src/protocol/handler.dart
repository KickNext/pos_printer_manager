import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Абстрактный обработчик протокола принтера.
///
/// Определяет интерфейс для работы с различными типами принтеров
/// (чековые, этикеточные, кухонные и т.д.).
abstract class PrinterProtocolHandler<T extends PrinterSettings> {
  /// Менеджер принтеров для доступа к API.
  final PrintersManager manager;

  /// Настройки принтера.
  final T settings;

  /// Конструктор обработчика протокола.
  PrinterProtocolHandler({required this.settings, required this.manager});

  /// Получить статус принтера.
  ///
  /// Возвращает true если принтер готов к работе.
  Future<bool> getStatus();

  /// Отправить задание на печать.
  ///
  /// [job] - задание для печати.
  /// Возвращает результат печати.
  Future<PrintResult> print(PrintJob job);

  /// Выполнить тестовую печать.
  ///
  /// Используется для проверки подключения и работоспособности принтера.
  Future<void> testPrint();

  /// Пользовательские виджеты для настройки принтера.
  ///
  /// Позволяет добавлять специфичные для типа принтера элементы управления
  /// в UI настроек принтера.
  List<Widget> get customWidgets;

  // === USB Permission Helpers ===

  /// Проверяет, является ли принтер USB-принтером.
  bool get isUsbPrinter =>
      settings.connectionParams?.connectionType == PosPrinterConnectionType.usb;

  /// Выполняет операцию с автоматическим запросом USB разрешения.
  ///
  /// Если принтер USB и разрешение не получено, запрашивает его.
  /// Для сетевых принтеров просто выполняет операцию.
  ///
  /// [operation] - операция для выполнения.
  /// Выбрасывает [UsbPermissionDeniedException] если пользователь отказал.
  Future<T2> withUsbPermission<T2>(Future<T2> Function() operation) async {
    if (!isUsbPrinter || settings.connectionParams == null) {
      return operation();
    }
    return manager.withUsbPermission(settings.connectionParams!, operation);
  }
}

/// Результат печати.
class PrintResult {
  /// Успешно ли выполнена печать.
  final bool success;

  /// Сообщение о результате (ошибка или информация).
  final String? message;

  PrintResult({required this.success, this.message});
}

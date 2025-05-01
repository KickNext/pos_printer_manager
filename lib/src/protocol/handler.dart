import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Абстрактный обработчик протокола принтера
abstract class PrinterProtocolHandler<T extends PrinterSettings> {
  final PrintersManager manager;

  /// Поле для хранения настроек
  final T settings;

  /// Конструктор для приема настроек
  PrinterProtocolHandler({required this.settings, required this.manager});

  Future<bool> getStatus(); //TODO:(kicknext) более точный статус

  /// Отправить задание на печать
  Future<PrintResult> print(PrintJob job);

  Future<void> testPrint();
}

/// Результат печати
class PrintResult {
  final bool success;
  final String? message;

  PrintResult({required this.success, this.message});
}

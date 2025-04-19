import '../plugins/printer_settings.dart';

/// Абстрактный обработчик протокола принтера
abstract class PrinterProtocolHandler<T extends PrinterSettings> {
  /// Поле для хранения настроек
  final T settings;

  /// Конструктор для приема настроек
  PrinterProtocolHandler(this.settings);

  /// Установить соединение с принтером
  Future<void> connect();

  /// Отправить задание на печать
  Future<PrintResult> print(PrintJob job);

  /// Разорвать соединение
  Future<void> disconnect();
}

/// Результат печати
class PrintResult {
  final bool success;
  final String? message;

  PrintResult({required this.success, this.message});
}

/// Базовый класс задания на печать
abstract class PrintJob {}

/// Простое задание, отправляющее сырые байты
class RawPrintJob extends PrintJob {
  final List<int> data;

  RawPrintJob(this.data);
}

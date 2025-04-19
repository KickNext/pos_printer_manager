import 'package:pos_printer_manager/src/config/config.dart';

/// Абстрактный репозиторий для CRUD операций с конфигурациями принтеров
abstract class PrinterConfigRepository {
  Future<List<PrinterConfig>> loadConfigs();
  Future<void> saveConfigs(List<PrinterConfig> configs);
}
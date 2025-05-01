import 'package:pos_printer_manager/src/models/printer_config.dart';

abstract class PrinterConfigRepository {
  Future<List<PrinterConfig>> loadConfigs();
  Future<void> saveConfigs(List<PrinterConfig> configs);
}
/// Use Case для добавления нового принтера.
///
/// Создает новую конфигурацию принтера с указанным именем и типом,
/// сохраняет её в репозитории и возвращает созданный объект [PosPrinter].
///
/// ## Пример использования:
///
/// ```dart
/// final useCase = AddPrinterUseCase(
///   repository: repository,
///   printerFactory: printerFactory,
/// );
///
/// final result = await useCase(AddPrinterParams(
///   name: 'Kitchen Printer 1',
///   type: PrinterPOSType.kitchenPrinter,
/// ));
///
/// result.when(
///   success: (printer) => print('Created: ${printer.config.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/core.dart';
import 'package:pos_printer_manager/src/domain/use_cases/use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';
import 'package:pos_printer_manager/src/models/printer_config.dart';
import 'package:pos_printer_manager/src/plugins/printer_type.dart';

/// Параметры для добавления принтера.
class AddPrinterParams {
  /// Имя нового принтера.
  final String name;

  /// Тип принтера.
  final PrinterPOSType type;

  /// Создает параметры для добавления принтера.
  const AddPrinterParams({required this.name, required this.type});
}

/// Фабрика для создания экземпляров [PosPrinter].
///
/// Абстрагирует создание принтера для облегчения тестирования.
abstract interface class PrinterFactory {
  /// Создает экземпляр [PosPrinter] из конфигурации.
  PosPrinter create(PrinterConfig config);
}

/// Use Case для добавления нового принтера.
class AddPrinterUseCase
    with LoggerMixin
    implements UseCase<AddPrinterParams, PosPrinter> {
  /// Фабрика для создания принтеров.
  final PrinterFactory _printerFactory;

  /// Callback для сохранения всех конфигураций.
  final Future<void> Function(List<PrinterConfig>) _saveConfigs;

  /// Текущий список принтеров (для добавления нового).
  final List<PosPrinter> Function() _getPrinters;

  /// Создает Use Case для добавления принтера.
  AddPrinterUseCase({
    required PrinterFactory printerFactory,
    required Future<void> Function(List<PrinterConfig>) saveConfigs,
    required List<PosPrinter> Function() getPrinters,
  }) : _printerFactory = printerFactory,
       _saveConfigs = saveConfigs,
       _getPrinters = getPrinters;

  @override
  String get loggerName => 'AddPrinterUseCase';

  @override
  Future<Result<PosPrinter>> call(AddPrinterParams params) async {
    logger.info(
      'Adding new printer',
      data: {'name': params.name, 'type': params.type.name},
    );

    // Валидация имени
    if (params.name.trim().isEmpty) {
      logger.warning('Validation failed: empty name');
      return const Result.failure(
        AppError.validation('Printer name cannot be empty'),
      );
    }

    try {
      // Генерируем уникальный ID (UUID v4)
      final id = IdGenerator.generate();

      // Создаем конфигурацию
      final config = PrinterConfig(
        id: id,
        name: params.name.trim(),
        printerPosType: params.type,
        rawSettings: {},
      );

      // Создаем принтер через фабрику
      final printer = _printerFactory.create(config);

      // Сохраняем в репозиторий
      final allConfigs = [..._getPrinters().map((p) => p.config), config];
      await _saveConfigs(allConfigs);

      logger.info(
        'Printer added successfully',
        data: {'id': id, 'name': params.name},
      );

      return Result.success(printer);
    } catch (e, st) {
      logger.error('Failed to add printer', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }
}

/// Use Case для получения принтера по ID.
///
/// Возвращает принтер из списка по указанному идентификатору.
///
/// ## Пример использования:
///
/// ```dart
/// final useCase = GetPrinterUseCase(getPrinters: () => printersList);
///
/// final result = useCase('printer-123');
///
/// result.when(
///   success: (printer) => print('Found: ${printer.config.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/core.dart';
import 'package:pos_printer_manager/src/domain/use_cases/use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';

/// Use Case для получения принтера по ID.
class GetPrinterUseCase
    with LoggerMixin
    implements SyncUseCase<String, PosPrinter> {
  /// Callback для получения текущего списка принтеров.
  final List<PosPrinter> Function() _getPrinters;

  /// Создает Use Case для получения принтера.
  GetPrinterUseCase({required List<PosPrinter> Function() getPrinters})
    : _getPrinters = getPrinters;

  @override
  String get loggerName => 'GetPrinterUseCase';

  @override
  Result<PosPrinter> call(String printerId) {
    logger.debug('Getting printer', data: {'printerId': printerId});

    // Валидация
    if (printerId.trim().isEmpty) {
      logger.warning('Validation failed: empty printer ID');
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    // Поиск принтера
    final printers = _getPrinters();
    final printer = printers.where((p) => p.id == printerId).firstOrNull;

    if (printer == null) {
      logger.warning('Printer not found', data: {'printerId': printerId});
      return Result.failure(
        AppError.notFound('Printer with ID $printerId not found'),
      );
    }

    logger.debug(
      'Printer found',
      data: {'printerId': printerId, 'name': printer.config.name},
    );

    return Result.success(printer);
  }
}

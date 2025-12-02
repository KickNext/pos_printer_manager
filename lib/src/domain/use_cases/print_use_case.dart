/// Use Case для печати на принтере.
///
/// Отправляет задание на печать на указанный принтер,
/// автоматически обрабатывает USB-разрешения и обновляет статус.
///
/// ## Пример использования:
///
/// ```dart
/// final useCase = PrintUseCase(getPrinters: () => printersList);
///
/// final result = await useCase(PrintParams(
///   printerId: 'printer-123',
///   job: ReceiptPrintJob(receiptHTML: '<h1>Receipt</h1>'),
/// ));
///
/// result.when(
///   success: (printResult) => print('Printed: ${printResult.success}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/core.dart';
import 'package:pos_printer_manager/src/domain/use_cases/use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';
import 'package:pos_printer_manager/src/protocol/handler.dart';
import 'package:pos_printer_manager/src/protocol/print_job.dart';

/// Параметры для печати.
class PrintParams {
  /// ID принтера для печати.
  final String printerId;

  /// Задание на печать.
  final PrintJob job;

  /// Создает параметры для печати.
  const PrintParams({required this.printerId, required this.job});
}

/// Use Case для печати на принтере.
class PrintUseCase
    with LoggerMixin
    implements UseCase<PrintParams, PrintResult> {
  /// Callback для получения текущего списка принтеров.
  final List<PosPrinter> Function() _getPrinters;

  /// Создает Use Case для печати.
  PrintUseCase({required List<PosPrinter> Function() getPrinters})
    : _getPrinters = getPrinters;

  @override
  String get loggerName => 'PrintUseCase';

  @override
  Future<Result<PrintResult>> call(PrintParams params) async {
    final stopwatch = logger.startOperation('Print job');

    logger.info(
      'Starting print job',
      data: {
        'printerId': params.printerId,
        'jobType': params.job.runtimeType.toString(),
      },
    );

    // Валидация
    if (params.printerId.trim().isEmpty) {
      logger.warning('Validation failed: empty printer ID');
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    try {
      // Поиск принтера
      final printers = _getPrinters();
      final printer = printers
          .where((p) => p.id == params.printerId)
          .firstOrNull;

      if (printer == null) {
        logger.warning(
          'Printer not found',
          data: {'printerId': params.printerId},
        );
        return Result.failure(
          AppError.notFound('Printer with ID ${params.printerId} not found'),
        );
      }

      // Проверка подключения
      if (!printer.isConnected &&
          printer.status != PrinterConnectionStatus.unknown) {
        logger.warning(
          'Printer not connected',
          data: {'printerId': params.printerId, 'status': printer.status.name},
        );
        return Result.failure(AppError.connection('Printer is not connected'));
      }

      // Выполнение печати через tryPrint (обрабатывает USB permissions)
      final printResult = await printer.tryPrint(params.job);

      if (printResult.success) {
        logger.endOperation('Print job', stopwatch);
        logger.info(
          'Print job completed successfully',
          data: {'printerId': params.printerId},
        );
      } else {
        logger.warning(
          'Print job failed',
          data: {'printerId': params.printerId, 'message': printResult.message},
        );
      }

      return Result.success(printResult);
    } catch (e, st) {
      logger.error('Print job failed with exception', error: e, stackTrace: st);
      return Result.failure(
        AppError.printing(e.toString(), cause: e, stackTrace: st),
      );
    }
  }
}

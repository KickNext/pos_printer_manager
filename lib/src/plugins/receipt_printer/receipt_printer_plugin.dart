import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Логгер для операций с чековым принтером.
final _logger = PrinterLogger.getLogger('ReceiptPrinter');

/// Настройки чекового принтера.
///
/// Определяет параметры подключения и формат печати
/// для ESC/POS чековых принтеров.
class ReceiptPrinterSettings extends PrinterSettings {
  /// Создает настройки чекового принтера.
  ReceiptPrinterSettings({
    required super.initConnectionParams,
    required super.onSettingsChanged,
    required bool upsideDown,
  }) : _upsideDown = upsideDown;

  bool _upsideDown;

  bool get upsideDown => _upsideDown;

  Future<void> updateUpsideDown(bool newValue) async {
    if (_upsideDown == newValue) {
      return;
    }
    _upsideDown = newValue;
    await onSettingsChanged();
  }

  /// Размер бумаги (по умолчанию 80мм).
  final PaperSize paperSize = PaperSize.mm80;

  @override
  final IconData icon = Icons.receipt_long_rounded;

  @override
  PrinterDiscoveryFilter get discoveryFilter => PrinterDiscoveryFilter(
    connectionTypes: const [
      DiscoveryConnectionType.usb,
      DiscoveryConnectionType.tcp,
      DiscoveryConnectionType.sdk,
    ],
  );

  @override
  Map<String, dynamic> get extraSettingsToJson => {'upsideDown': _upsideDown};
}

/// Обработчик протокола для чекового принтера.
///
/// Реализует печать HTML-контента через ESC/POS команды.
class ReceiptPrinterHandler
    extends PrinterProtocolHandler<ReceiptPrinterSettings> {
  /// Создает обработчик чекового принтера.
  ReceiptPrinterHandler({required super.settings, required super.manager});

  @override
  Future<bool> getStatus() async {
    if (settings.connectionParams == null) {
      _logger.debug('Cannot get status: no connection params');
      return false;
    }
    final status = await manager.api.getPrinterStatus(
      settings.connectionParams!,
    );
    _logger.debug('Printer status', data: {'success': status.success});
    return status.success;
  }

  @override
  Future<void> testPrint() async {
    _logger.info('Starting test print');
    final result = await print(
      ReceiptPrintJob(receiptHTML: '<h1>Test print</h1>'),
    );
    if (!result.success) {
      _logger.warning('Test print failed', data: {'message': result.message});
      throw Exception(result.message ?? 'Test print failed');
    }
    _logger.info('Test print completed');
  }

  /// Открывает денежный ящик, подключенный к принтеру.
  Future<void> openCashDrawer() async {
    if (settings.connectionParams == null) {
      _logger.warning('Cannot open cash drawer: no connection params');
      return;
    }
    try {
      _logger.info('Opening cash drawer');
      await manager.api.openCashBox(settings.connectionParams!);
      _logger.info('Cash drawer opened');
    } catch (e, st) {
      _logger.error('Error opening cash drawer', error: e, stackTrace: st);
    }
  }

  @override
  Future<PrintResult> print(PrintJob job) async {
    if (settings.connectionParams == null) {
      _logger.warning('Print failed: no connection params');
      return PrintResult(
        success: false,
        message: 'Connection parameters are null',
      );
    }
    if (job is! ReceiptPrintJob) {
      _logger.warning(
        'Print failed: invalid job type',
        data: {'type': job.runtimeType.toString()},
      );
      return PrintResult(success: false, message: 'Invalid job type');
    }

    final receiptHTML = job.receiptHTML;
    _logger.debug('Printing receipt', data: {'htmlLength': receiptHTML.length});

    try {
      await manager.api.printEscHTML(
        settings.connectionParams!,
        receiptHTML,
        settings.paperSize.value,
        upsideDown: settings.upsideDown,
      );
      _logger.info('Receipt printed successfully');
      return PrintResult(success: true);
    } catch (e, st) {
      _logger.error('Error printing receipt', error: e, stackTrace: st);
      return PrintResult(success: false, message: e.toString());
    }
  }

  @override
  List<Widget> get customWidgets => [];
}

// Примечание: ReceiptPrintJob теперь определён в protocol/print_job.dart
// и экспортируется через pos_printer_manager.dart

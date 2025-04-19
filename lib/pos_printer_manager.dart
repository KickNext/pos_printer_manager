library;

export 'src/manager.dart';
export 'src/protocol/handler.dart';
// Добавлено: экспорт protocol.dart для PrinterState
export 'src/protocol/protocol.dart';
// Добавлено: экспорт config.dart для PrinterConfig
export 'src/config/config.dart';
// Добавлено: экспорт констант типов принтеров
export 'src/plugins/receipt_printer/receipt_printer_plugin.dart'
    show receiptPrinterType, ReceiptPrinterSettings, registerReceiptPrinter;
export 'src/plugins/kitchen_printer/kitchen_printer_plugin.dart'
    show kitchenPrinterType, KitchenPrinterSettings, registerKitchenPrinter;
export 'src/plugins/label_printer/label_printer_plugin.dart'
    show labelPrinterType, LabelPrinterSettings, registerLabelPrinter;
// Добавлено: экспорт базовых настроек
export 'src/plugins/printer_settings.dart';

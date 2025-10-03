import 'package:pos_printer_manager/pos_printer_manager.dart';

enum PrinterPOSType {
  receiptPrinter,
  kitchenPrinter,
  androBar,
  labelPrinter;

  String get displayName {
    switch (this) {
      case PrinterPOSType.receiptPrinter:
        return 'Receipt printer';
      case PrinterPOSType.kitchenPrinter:
        return 'Kitchen printer';
      case PrinterPOSType.labelPrinter:
        return 'Label printer';
      case PrinterPOSType.androBar:
        return 'AndroBar';
    }
  }

  static void registerPrinterTypes(PrintersManager posPrintersManager) {
    for (var type in PrinterPOSType.values) {
      type._register(posPrintersManager);
    }
  }

  void _register(PrintersManager manager) {
    switch (this) {
      case PrinterPOSType.receiptPrinter:
        PrinterPluginRegistry.registerWithCtor<ReceiptPrinterSettings>(
          printerPosType: PrinterPOSType.receiptPrinter,
          ctor:
              (params, json) => ReceiptPrinterSettings(
                initConnectionParams: params,
                onSettingsChanged: () async => await manager.saveConfigs(),
              ),
          createHandler:
              (settings) => ReceiptPrinterHandler(
                settings: settings as ReceiptPrinterSettings,
                manager: manager,
              ),
        );
        break;
      case PrinterPOSType.kitchenPrinter:
        PrinterPluginRegistry.registerWithCtor<KitchenPrinterSettings>(
          printerPosType: PrinterPOSType.kitchenPrinter,
          ctor: (params, json) {
            final categoriesJson = json['categories'];
            final categories =
                categoriesJson is List
                    ? categoriesJson.map((e) => CategoryForPrinter.fromJson(e)).toList()
                    : <CategoryForPrinter>[];

            return KitchenPrinterSettings(
              initConnectionParams: params,
              onSettingsChanged: () async => await manager.saveConfigs(),
              categories: categories,
            );
          },
          createHandler:
              (settings) => KitchenPrinterHandler(
                settings: settings as KitchenPrinterSettings,
                manager: manager,
              ),
        );
        break;
      case PrinterPOSType.labelPrinter:
        PrinterPluginRegistry.registerWithCtor<LabelPrinterSettings>(
          printerPosType: PrinterPOSType.labelPrinter,
          ctor:
              (params, json) => LabelPrinterSettings.fromJsonData(
                params,
                json,
                () async => await manager.saveConfigs(),
              ),
          createHandler:
              (settings) => LabelPrinterHandler(
                settings: settings as LabelPrinterSettings,
                manager: manager,
              ),
        );
        break;
      case PrinterPOSType.androBar:
        PrinterPluginRegistry.registerWithCtor<AndroBarPrinterSettings>(
          printerPosType: PrinterPOSType.androBar,
          ctor: (params, json) {
            final categoriesJson = json['categories'];
            final categories =
                categoriesJson is List
                    ? categoriesJson.map((e) => CategoryForPrinter.fromJson(e)).toList()
                    : <CategoryForPrinter>[];

            return AndroBarPrinterSettings(
              initConnectionParams: params,
              onSettingsChanged: () async => await manager.saveConfigs(),
              categories: categories,
            );
          },
          createHandler:
              (settings) => AndroBarPrinterHandler(
                settings: settings as AndroBarPrinterSettings,
                manager: manager,
              ),
        );
        break;
    }
  }
}

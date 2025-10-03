## 0.3.11+2025100302

* Added support for TSPL (TSC Printer Language) for label printers
* Added `LabelPrinterLanguage` enum to select between ZPL and TSPL
* Added language selection UI in label printer settings
* Added `printTsplHtml`, `printTsplRawData`, and `getTSPLPrinterStatus` methods to PrintersManager
* Updated `LabelPrinterHandler` to use appropriate print method based on selected language
* Added `buildTsplLabel` function to build TSPL labels from LabelData
* **Breaking change**: `LabelPrintJob` now accepts `LabelData` instead of raw string
* Handler automatically builds label commands using `buildZplLabel` or `buildTsplLabel` based on language setting
* Added TSPL examples in pos_printers_api_example.dart

## 0.0.1

* TODO: Describe initial release.

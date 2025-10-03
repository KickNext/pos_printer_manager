/// Supported label printer languages
enum LabelPrinterLanguage {
  /// ZPL (Zebra Programming Language) - used by Zebra and compatible printers
  zpl,

  /// TSPL (TSC Printer Language) - used by TSC and compatible printers
  tspl;

  /// Get language name for display
  String get displayName {
    switch (this) {
      case LabelPrinterLanguage.zpl:
        return 'ZPL';
      case LabelPrinterLanguage.tspl:
        return 'TSPL';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Централизованная система иконок для принтеров.
///
/// Обеспечивает консистентное отображение иконок на всех экранах приложения.
/// Все иконки должны использоваться ТОЛЬКО через этот класс для избежания
/// несогласованности между разными частями UI.
///
/// Пример использования:
/// ```dart
/// Icon(PrinterIcons.forType(PrinterPOSType.kitchenPrinter))
/// Icon(PrinterIcons.receiptPrinter)
/// ```
abstract final class PrinterIcons {
  // ============================================================
  // ИКОНКИ ТИПОВ ПРИНТЕРОВ
  // ============================================================

  /// Иконка для чекового принтера (Receipt Printer).
  /// Используется на всех экранах для обозначения чековых принтеров.
  static const IconData receiptPrinter = Icons.receipt_long_rounded;

  /// Иконка для кухонного принтера (Kitchen Printer).
  /// Используется на всех экранах для обозначения кухонных принтеров.
  static const IconData kitchenPrinter = Icons.soup_kitchen_rounded;

  /// Иконка для этикеточного принтера (Label Printer).
  /// Используется на всех экранах для обозначения этикеточных принтеров.
  static const IconData labelPrinter = Icons.sell_rounded;

  /// Иконка для системы AndroBar.
  /// Используется на всех экранах для обозначения AndroBar устройств.
  static const IconData androBar = Icons.local_bar_rounded;

  /// Иконка для неизвестного типа принтера.
  static const IconData unknown = Icons.print_rounded;

  // ============================================================
  // ИКОНКИ ТИПОВ ПОДКЛЮЧЕНИЯ
  // ============================================================

  /// Иконка для USB подключения.
  static const IconData connectionUsb = Icons.usb_rounded;

  /// Иконка для сетевого подключения (WiFi/Ethernet).
  static const IconData connectionNetwork = Icons.wifi_rounded;

  /// Иконка для Bluetooth подключения.
  static const IconData connectionBluetooth = Icons.bluetooth_rounded;

  /// Иконка для неизвестного типа подключения.
  static const IconData connectionUnknown = Icons.device_unknown_rounded;

  /// Иконка отсутствия подключения.
  static const IconData noConnection = Icons.link_off_rounded;

  // ============================================================
  // ИКОНКИ ДЕЙСТВИЙ
  // ============================================================

  /// Тестовая печать.
  static const IconData testPrint = Icons.print_rounded;

  /// Поиск принтеров.
  static const IconData search = Icons.search_rounded;

  /// Добавить принтер.
  static const IconData add = Icons.add_rounded;

  /// Удалить/убрать принтер.
  static const IconData remove = Icons.delete_outline_rounded;

  /// Настройки.
  static const IconData settings = Icons.settings_rounded;

  /// Редактировать.
  static const IconData edit = Icons.edit_rounded;

  /// Переименовать.
  static const IconData rename = Icons.drive_file_rename_outline_rounded;

  /// Отключить соединение.
  static const IconData disconnect = Icons.link_off_rounded;

  /// Обновить/перезагрузить.
  static const IconData refresh = Icons.refresh_rounded;

  /// Повторить попытку.
  static const IconData retry = Icons.replay_rounded;

  /// Сетевые настройки.
  static const IconData networkSettings = Icons.settings_ethernet_rounded;

  // ============================================================
  // ИКОНКИ СОСТОЯНИЙ
  // ============================================================

  /// Успешное состояние / подключено.
  static const IconData statusSuccess = Icons.check_circle_rounded;

  /// Состояние ошибки.
  static const IconData statusError = Icons.error_rounded;

  /// Состояние предупреждения.
  static const IconData statusWarning = Icons.warning_amber_rounded;

  /// Неизвестное состояние.
  static const IconData statusUnknown = Icons.help_outline_rounded;

  /// Загрузка / в процессе.
  static const IconData statusLoading = Icons.sync_rounded;

  /// Информация.
  static const IconData statusInfo = Icons.info_outline_rounded;

  /// Неактивно / отключено.
  static const IconData statusInactive = Icons.power_off_rounded;

  // ============================================================
  // ИКОНКИ РАЗРЕШЕНИЙ
  // ============================================================

  /// USB разрешение.
  static const IconData permissionUsb = Icons.usb_rounded;

  /// Разрешение получено.
  static const IconData permissionGranted = Icons.check_circle_rounded;

  /// Разрешение отклонено.
  static const IconData permissionDenied = Icons.cancel_rounded;

  /// Требуется разрешение.
  static const IconData permissionRequired = Icons.security_rounded;

  /// Запросить разрешение.
  static const IconData permissionRequest = Icons.lock_open_rounded;

  // ============================================================
  // ИКОНКИ СЕКЦИЙ
  // ============================================================

  /// Диагностика.
  static const IconData sectionDiagnostics = Icons.monitor_heart_rounded;

  /// Опасная зона (удаление и т.д.).
  static const IconData sectionDanger = Icons.warning_amber_rounded;

  /// Дополнительные настройки.
  static const IconData sectionAdditional = Icons.tune_rounded;

  /// Подключение.
  static const IconData sectionConnection = Icons.cable_rounded;

  // ============================================================
  // ИКОНКИ МАСТЕРА НАСТРОЙКИ
  // ============================================================

  /// Назад.
  static const IconData wizardBack = Icons.arrow_back_rounded;

  /// Далее.
  static const IconData wizardNext = Icons.arrow_forward_rounded;

  /// Завершить / Создать.
  static const IconData wizardComplete = Icons.check_rounded;

  /// Закрыть / Отмена.
  static const IconData wizardClose = Icons.close_rounded;

  // ============================================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ============================================================

  /// Возвращает иконку для указанного типа принтера.
  ///
  /// Это основной метод для получения иконки принтера.
  /// Гарантирует консистентность на всех экранах.
  ///
  /// Пример:
  /// ```dart
  /// Icon(PrinterIcons.forType(printer.type))
  /// ```
  static IconData forType(PrinterPOSType type) {
    switch (type) {
      case PrinterPOSType.receiptPrinter:
        return receiptPrinter;
      case PrinterPOSType.kitchenPrinter:
        return kitchenPrinter;
      case PrinterPOSType.labelPrinter:
        return labelPrinter;
      case PrinterPOSType.androBar:
        return androBar;
    }
  }

  /// Возвращает иконку для указанного типа подключения.
  ///
  /// Пример:
  /// ```dart
  /// Icon(PrinterIcons.forConnectionType(PosPrinterConnectionType.usb))
  /// ```
  static IconData forConnectionType(PosPrinterConnectionType? type) {
    switch (type) {
      case PosPrinterConnectionType.usb:
        return connectionUsb;
      case PosPrinterConnectionType.network:
        return connectionNetwork;
      case null:
        return connectionUnknown;
    }
  }

  /// Возвращает иконку для указанного типа подключения (для UI enum).
  static IconData forConnectionTypeUI(ConnectionType type) {
    switch (type) {
      case ConnectionType.usb:
        return connectionUsb;
      case ConnectionType.network:
        return connectionNetwork;
      case ConnectionType.bluetooth:
        return connectionBluetooth;
      case ConnectionType.unknown:
        return connectionUnknown;
    }
  }
}

/// Расширение для PrinterPOSType с доступом к иконке.
extension PrinterPOSTypeIconExtension on PrinterPOSType {
  /// Возвращает иконку для данного типа принтера.
  ///
  /// Удобный accessor для использования в виджетах:
  /// ```dart
  /// Icon(printer.type.icon)
  /// ```
  IconData get icon => PrinterIcons.forType(this);
}

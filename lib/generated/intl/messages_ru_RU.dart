// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru_RU locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru_RU';

  static String m0(connectionType) =>
      "Параметры подключения настроены (${connectionType}).";

  static String m1(error) => "Не удалось проверить USB разрешение: ${error}";

  static String m2(error) => "Не удалось создать принтер: ${error}";

  static String m3(count) => "Найдено принтеров: ${count}";

  static String m4(ipAddress) =>
      "Настроен статический IP (${ipAddress}). После перезагрузки принтер будет использовать этот адрес.";

  static String m5(number) => "Принтер ${number}";

  static String m6(error) => "Тест принтера не пройден: ${error}";

  static String m7(deviceInfo) => "USB разрешение получено: ${deviceInfo}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addPrinter": MessageLookupByLibrary.simpleMessage("Добавить принтер"),
    "addPrinterToStart": MessageLookupByLibrary.simpleMessage(
      "Добавьте принтер для начала работы.",
    ),
    "additionalSettings": MessageLookupByLibrary.simpleMessage(
      "Дополнительные настройки",
    ),
    "androBar": MessageLookupByLibrary.simpleMessage("AndroBar"),
    "androBarDescription": MessageLookupByLibrary.simpleMessage(
      "Система отображения бара",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "bluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "change": MessageLookupByLibrary.simpleMessage("Изменить"),
    "clearError": MessageLookupByLibrary.simpleMessage("Очистить ошибку"),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "configureConnectionLater": MessageLookupByLibrary.simpleMessage(
      "Вы сможете настроить подключение после создания",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "connect": MessageLookupByLibrary.simpleMessage("Подключить"),
    "connectionConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройка подключения",
    ),
    "connectionError": MessageLookupByLibrary.simpleMessage(
      "Ошибка подключения",
    ),
    "connectionParamsConfigured": m0,
    "couldNotCheckUsbPermission": m1,
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Опасная зона"),
    "dangerZoneDescription": MessageLookupByLibrary.simpleMessage(
      "Удаление этого принтера удалит все его настройки. Вы сможете добавить его снова позже, но вам потребуется заново настроить его.",
    ),
    "dhcp": MessageLookupByLibrary.simpleMessage("DHCP"),
    "dhcpEnabled": MessageLookupByLibrary.simpleMessage(
      "DHCP включен. Принтер автоматически получит сетевые настройки от вашего роутера.",
    ),
    "dhcpRequiresMac": MessageLookupByLibrary.simpleMessage(
      "MAC-адрес требуется для настройки DHCP через сеть",
    ),
    "diagnosing": MessageLookupByLibrary.simpleMessage("Диагностика..."),
    "diagnostics": MessageLookupByLibrary.simpleMessage("Диагностика"),
    "diagnosticsAllPassed": MessageLookupByLibrary.simpleMessage(
      "Все проверки пройдены",
    ),
    "diagnosticsAllPassedDescription": MessageLookupByLibrary.simpleMessage(
      "Все диагностические проверки пройдены успешно. Принтер настроен правильно.",
    ),
    "diagnosticsBlockedPendingReboot": MessageLookupByLibrary.simpleMessage(
      "Диагностика недоступна, пока принтер не будет перезагружен и переподключён.",
    ),
    "diagnosticsProblemsDescription": MessageLookupByLibrary.simpleMessage(
      "Некоторые диагностические проверки не пройдены. Изучите проблемы ниже и следуйте рекомендациям для их устранения.",
    ),
    "diagnosticsProblemsFound": MessageLookupByLibrary.simpleMessage(
      "Обнаружены проблемы",
    ),
    "diagnosticsSomeFailed": MessageLookupByLibrary.simpleMessage(
      "Некоторые диагностические проверки не пройдены. Изучите проблемы ниже и следуйте рекомендациям для их устранения.",
    ),
    "diagnosticsSuccessDescription": MessageLookupByLibrary.simpleMessage(
      "Все диагностические проверки пройдены успешно. Принтер настроен правильно.",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Отключено"),
    "disconnect": MessageLookupByLibrary.simpleMessage("Отключить"),
    "disconnectPrinterConfirmation": MessageLookupByLibrary.simpleMessage(
      "Это удалит текущие настройки подключения. Вы сможете подключиться снова позже.",
    ),
    "disconnectPrinterQuestion": MessageLookupByLibrary.simpleMessage(
      "Отключить принтер?",
    ),
    "enableDhcp": MessageLookupByLibrary.simpleMessage("Включить DHCP"),
    "enableDhcpDescription": MessageLookupByLibrary.simpleMessage(
      "Автоматически получать IP-адрес из сети",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Включено"),
    "failedToCreatePrinter": m2,
    "findPrinters": MessageLookupByLibrary.simpleMessage("Найти принтеры"),
    "foundPrinters": m3,
    "gateway": MessageLookupByLibrary.simpleMessage("Шлюз"),
    "gatewayHint": MessageLookupByLibrary.simpleMessage("192.168.1.1"),
    "grantUsbPermission": MessageLookupByLibrary.simpleMessage(
      "Предоставить USB разрешение",
    ),
    "grantUsbPermissionSuggestion": MessageLookupByLibrary.simpleMessage(
      "Предоставьте USB разрешение, нажав кнопку \"Предоставить USB разрешение\".",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP-адрес"),
    "ipAddressHint": MessageLookupByLibrary.simpleMessage("192.168.1.100"),
    "ipAddressRequired": MessageLookupByLibrary.simpleMessage(
      "IP-адрес обязателен",
    ),
    "kitchenPrinter": MessageLookupByLibrary.simpleMessage("Кухонный принтер"),
    "kitchenPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Для кухонных заказов",
    ),
    "labelPrinter": MessageLookupByLibrary.simpleMessage("Принтер этикеток"),
    "labelPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Для этикеток товаров",
    ),
    "macAddress": MessageLookupByLibrary.simpleMessage("MAC-адрес"),
    "macAddressRequired": MessageLookupByLibrary.simpleMessage(
      "MAC-адрес требуется для сетевой настройки",
    ),
    "manufacturer": MessageLookupByLibrary.simpleMessage("Производитель"),
    "maxPrintersReached": MessageLookupByLibrary.simpleMessage(
      "Достигнуто максимальное количество принтеров.",
    ),
    "nameYourPrinter": MessageLookupByLibrary.simpleMessage("Назовите принтер"),
    "nameYourPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Дайте принтеру понятное название для лёгкой идентификации.",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkConnection": MessageLookupByLibrary.simpleMessage(
      "Сетевое подключение",
    ),
    "networkSettings": MessageLookupByLibrary.simpleMessage(
      "Сетевые настройки",
    ),
    "networkSettingsAppliedMessage": MessageLookupByLibrary.simpleMessage(
      "Сетевые настройки отправлены на принтер. Перезагрузите принтер для применения изменений.",
    ),
    "networkSettingsAppliedTitle": MessageLookupByLibrary.simpleMessage(
      "Сетевые настройки отправлены",
    ),
    "networkSettingsDhcpAppliedMessage": MessageLookupByLibrary.simpleMessage(
      "DHCP включен. После перезагрузки принтер получит новый IP-адрес от вашего роутера.",
    ),
    "networkSettingsStaticIpAppliedMessage": m4,
    "networkSettingsTooltip": MessageLookupByLibrary.simpleMessage(
      "Настроить IP, маску подсети, шлюз",
    ),
    "networkSettingsUpdated": MessageLookupByLibrary.simpleMessage(
      "Сетевые настройки успешно обновлены",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Далее"),
    "noConnection": MessageLookupByLibrary.simpleMessage("Нет подключения"),
    "noConnectionConfigured": MessageLookupByLibrary.simpleMessage(
      "Подключение не настроено. Сначала настройте USB или сетевое подключение.",
    ),
    "noConnectionDescription": MessageLookupByLibrary.simpleMessage(
      "Принтер не подключен. Найдите доступные принтеры для настройки подключения.",
    ),
    "noPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "Разрешение не требуется",
    ),
    "noPrintersAvailable": MessageLookupByLibrary.simpleMessage(
      "Нет доступных принтеров",
    ),
    "noPrintersConfigured": MessageLookupByLibrary.simpleMessage(
      "Принтеры не настроены",
    ),
    "noPrintersFound": MessageLookupByLibrary.simpleMessage(
      "Принтеры не найдены",
    ),
    "noPrintersFoundDescription": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что принтер включен и подключен к той же сети или через USB.",
    ),
    "noUsbPermissionNeededMessage": MessageLookupByLibrary.simpleMessage(
      "USB разрешение не требуется для сетевых принтеров.",
    ),
    "notConnected": MessageLookupByLibrary.simpleMessage("Не подключен"),
    "notRequiredForNetworkPrinters": MessageLookupByLibrary.simpleMessage(
      "Не требуется для сетевых принтеров.",
    ),
    "pendingRebootWarning": MessageLookupByLibrary.simpleMessage(
      "Сетевые настройки были изменены. Принтер необходимо перезагрузить для применения изменений.",
    ),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Разрешение отклонено",
    ),
    "permissionGranted": MessageLookupByLibrary.simpleMessage(
      "Разрешение получено",
    ),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение",
    ),
    "pleaseEnterName": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите название",
    ),
    "pleaseSelectPrinterType": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, выберите тип принтера",
    ),
    "printerConnectivity": MessageLookupByLibrary.simpleMessage(
      "Связь с принтером",
    ),
    "printerDefaultName": m5,
    "printerDetails": MessageLookupByLibrary.simpleMessage(
      "Информация о принтере",
    ),
    "printerName": MessageLookupByLibrary.simpleMessage("Название принтера"),
    "printerNameHint": MessageLookupByLibrary.simpleMessage(
      "напр., Кухонный дисплей, Принтер бара",
    ),
    "printerRespondedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Принтер успешно ответил на тестовую команду.",
    ),
    "printerRestartInstructions": MessageLookupByLibrary.simpleMessage(
      "1. Выключите принтер\n2. Подождите 10 секунд\n3. Включите принтер\n4. Нажмите «Сбросить подключение» ниже\n5. Используйте «Найти принтеры» для переподключения",
    ),
    "printerTestFailed": m6,
    "printing": MessageLookupByLibrary.simpleMessage("Печать..."),
    "productId": MessageLookupByLibrary.simpleMessage("Product ID"),
    "productName": MessageLookupByLibrary.simpleMessage("Название продукта"),
    "readyToConnect": MessageLookupByLibrary.simpleMessage(
      "Готов к подключению",
    ),
    "readyToConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Принтер создан. Теперь вы можете настроить подключение.",
    ),
    "readyToPrint": MessageLookupByLibrary.simpleMessage(
      "Последний тест успешен",
    ),
    "receiptPrinter": MessageLookupByLibrary.simpleMessage("Чековый принтер"),
    "receiptPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Для чеков и счетов",
    ),
    "reconnectAfterRestart": MessageLookupByLibrary.simpleMessage(
      "После перезагрузки принтера используйте «Найти принтеры» для подключения с новыми настройками.",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "removePrinter": MessageLookupByLibrary.simpleMessage("Удалить принтер"),
    "removePrinterConfirmation": MessageLookupByLibrary.simpleMessage(
      "Это удалит принтер и все его настройки. Вы сможете добавить его снова позже.",
    ),
    "removePrinterQuestion": MessageLookupByLibrary.simpleMessage(
      "Удалить принтер?",
    ),
    "renamePrinter": MessageLookupByLibrary.simpleMessage(
      "Переименовать принтер",
    ),
    "requesting": MessageLookupByLibrary.simpleMessage("Запрос..."),
    "resetConnectionAndReconnect": MessageLookupByLibrary.simpleMessage(
      "Сбросить подключение",
    ),
    "resetConnectionConfirmation": MessageLookupByLibrary.simpleMessage(
      "Это удалит текущее подключение. После перезагрузки принтера найдите его снова через «Найти принтеры».",
    ),
    "restartPrinterRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется перезагрузка принтера",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "runDiagnosticsTooltip": MessageLookupByLibrary.simpleMessage(
      "Запустить полную диагностику и показать проблемы, если они есть",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveSettings": MessageLookupByLibrary.simpleMessage("Сохранить настройки"),
    "scanningNetworkAndUsb": MessageLookupByLibrary.simpleMessage(
      "Сканирование сети и USB...",
    ),
    "searchAgain": MessageLookupByLibrary.simpleMessage("Искать снова"),
    "searchingForPrinters": MessageLookupByLibrary.simpleMessage(
      "Поиск принтеров...",
    ),
    "selectPrinterType": MessageLookupByLibrary.simpleMessage(
      "Выберите тип принтера",
    ),
    "selectPrinterTypeDescription": MessageLookupByLibrary.simpleMessage(
      "Выберите тип принтера, который хотите добавить.",
    ),
    "serialNumber": MessageLookupByLibrary.simpleMessage("Серийный номер"),
    "staticIpSettings": MessageLookupByLibrary.simpleMessage(
      "Статический IP-адрес",
    ),
    "stepName": MessageLookupByLibrary.simpleMessage("Название"),
    "stepType": MessageLookupByLibrary.simpleMessage("Тип"),
    "subnetMask": MessageLookupByLibrary.simpleMessage("Маска подсети"),
    "subnetMaskHint": MessageLookupByLibrary.simpleMessage("255.255.255.0"),
    "suggestionCheckConnection": MessageLookupByLibrary.simpleMessage(
      "Проверьте подключение и настройки принтера.",
    ),
    "suggestionCheckNetworkAndIp": MessageLookupByLibrary.simpleMessage(
      "Проверьте сетевое подключение и IP-адрес принтера.",
    ),
    "suggestionCheckPowerAndConnection": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что принтер включен и подключен. Попробуйте переподключить.",
    ),
    "suggestionGrantPermission": MessageLookupByLibrary.simpleMessage(
      "Предоставьте USB разрешение и повторите попытку.",
    ),
    "suggestionGrantUsbPermission": MessageLookupByLibrary.simpleMessage(
      "Предоставьте USB разрешение и повторите попытку.",
    ),
    "suggestionLoadPaper": MessageLookupByLibrary.simpleMessage(
      "Загрузите бумагу в принтер.",
    ),
    "suggestionVerifyPrinterConnected": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что принтер подключен и виден устройству.",
    ),
    "testPrint": MessageLookupByLibrary.simpleMessage("Тестовая печать"),
    "testingBlockedPendingReboot": MessageLookupByLibrary.simpleMessage(
      "Тестирование недоступно, пока принтер не будет перезагружен и переподключён.",
    ),
    "tipCheckAndroBarNetwork": MessageLookupByLibrary.simpleMessage(
      "Проверьте сетевое подключение к устройству AndroBar",
    ),
    "tipCheckLabels": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что этикетки загружены правильно",
    ),
    "tipCheckPaper": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что бумага загружена правильно",
    ),
    "tipCheckPowerOn": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что принтер включен",
    ),
    "tipNetworkConnection": MessageLookupByLibrary.simpleMessage(
      "Для сети: Проверьте подключение WiFi/Ethernet",
    ),
    "tipUsbCable": MessageLookupByLibrary.simpleMessage(
      "Для USB: Убедитесь, что кабель надёжно подключен",
    ),
    "troubleshootingTips": MessageLookupByLibrary.simpleMessage(
      "Советы по устранению неполадок",
    ),
    "tryReconnectingUsb": MessageLookupByLibrary.simpleMessage(
      "Попробуйте переподключить USB устройство.",
    ),
    "understood": MessageLookupByLibrary.simpleMessage("Понятно"),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "upsideDownMode": MessageLookupByLibrary.simpleMessage(
      "Печать вверх ногами",
    ),
    "upsideDownModeDescription": MessageLookupByLibrary.simpleMessage(
      "Печатать в перевернутом режиме (180°)",
    ),
    "usb": MessageLookupByLibrary.simpleMessage("USB"),
    "usbConnection": MessageLookupByLibrary.simpleMessage("USB подключение"),
    "usbConnectionStillWorks": MessageLookupByLibrary.simpleMessage(
      "USB-подключение продолжит работать без изменений.",
    ),
    "usbPermission": MessageLookupByLibrary.simpleMessage("USB разрешение"),
    "usbPermissionCheck": MessageLookupByLibrary.simpleMessage(
      "USB разрешение",
    ),
    "usbPermissionDeniedError": MessageLookupByLibrary.simpleMessage(
      "USB разрешение отклонено",
    ),
    "usbPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "USB разрешение было отклонено. Предоставьте разрешение для использования принтера.",
    ),
    "usbPermissionGrantedDiag": MessageLookupByLibrary.simpleMessage(
      "USB разрешение получено.",
    ),
    "usbPermissionGrantedMessage": MessageLookupByLibrary.simpleMessage(
      "USB разрешение получено. Принтер готов к использованию.",
    ),
    "usbPermissionGrantedShort": MessageLookupByLibrary.simpleMessage(
      "USB разрешение получено.",
    ),
    "usbPermissionGrantedSuccess": MessageLookupByLibrary.simpleMessage(
      "USB разрешение получено",
    ),
    "usbPermissionGrantedWithDevice": m7,
    "usbPermissionNotGranted": MessageLookupByLibrary.simpleMessage(
      "USB разрешение не получено.",
    ),
    "usbPermissionNotRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "USB разрешение не требуется для сетевых принтеров.",
    ),
    "usbPermissionRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "USB разрешение требуется для связи с этим принтером.",
    ),
    "useFindPrintersButton": MessageLookupByLibrary.simpleMessage(
      "Используйте кнопку \"Найти принтеры\" для настройки подключения.",
    ),
    "useFinderToConnect": MessageLookupByLibrary.simpleMessage(
      "Используйте кнопку \"Найти принтеры\" для настройки подключения.",
    ),
    "vendorId": MessageLookupByLibrary.simpleMessage("Vendor ID"),
  };
}

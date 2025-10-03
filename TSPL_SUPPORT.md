# Поддержка TSPL для Label принтеров

## Обзор

В пакете `pos_printer_manager` теперь доступна поддержка языка TSPL (TSC Printer Language) для label принтеров, в дополнение к уже существующей поддержке ZPL (Zebra Programming Language).

## Основные изменения

### 1. Enum для выбора языка принтера

Добавлен `LabelPrinterLanguage` enum с двумя вариантами:
- `zpl` - Zebra Programming Language (принтеры Zebra)
- `tspl` - TSC Printer Language (принтеры TSC)

```dart
enum LabelPrinterLanguage {
  zpl,
  tspl;
}
```

### 2. Настройки принтера

`LabelPrinterSettings` теперь содержит поле `language` для хранения выбранного языка:

```dart
final settings = LabelPrinterSettings(
  initConnectionParams: params,
  onSettingsChanged: () async => await manager.saveConfigs(),
  language: LabelPrinterLanguage.tspl, // или .zpl
);
```

Настройка автоматически сохраняется в конфигурации принтера.

### 3. UI для выбора языка

В настройках label принтера появился виджет с radio buttons для выбора языка (ZPL/TSPL). 

Виджет автоматически отображается в детальной настройке принтера и позволяет переключаться между языками.

### 4. Новые методы API

В `PrintersManager` добавлены методы для работы с TSPL:

```dart
// Печать HTML на TSPL принтере
await manager.printTsplHtml(printer, html, PaperSize.mm58.value);

// Печать сырых TSPL команд
await manager.printTsplRawData(printer, data, PaperSize.mm58.value);

// Получение статуса TSPL принтера
final status = await manager.getTSPLPrinterStatus(printer);
```

### 5. Автоматическое переключение методов печати

`LabelPrinterHandler` автоматически использует правильный метод печати в зависимости от выбранного языка:
- Если выбран `ZPL` → использует `printZplRawData()` и `getZPLPrinterStatus()`
- Если выбран `TSPL` → использует `printTsplRawData()` и `getTSPLPrinterStatus()`

## Примеры использования

### Использование через LabelPrinterHandler (Рекомендуемый способ)

```dart
// Создаем данные для этикетки
final labelData = LabelData(
  itemName: 'Молоко 3.2%',
  unitAbr: 'л',
  oldPrice: '120.00',
  price: '99.00',
  storeName: 'Магазин "Продукты"',
  date: '03/10/2025',
  qrText: '1234567890123',
);

// Создаем задание на печать
final job = LabelPrintJob(labelData: labelData);

// Печатаем (автоматически выберет ZPL или TSPL в зависимости от настройки)
final result = await printer.handler.print(job);
```

Handler автоматически выберет правильный метод построения этикетки (`buildZplLabel` или `buildTsplLabel`) в зависимости от выбранного языка принтера.

### Прямое использование API (TSPL)

Для продвинутых случаев, когда нужен полный контроль:

```dart
// Печать HTML этикетки
const html = '''
  <html>
    <head>
      <style>
        body { font-family: Arial; padding: 10px; }
        h1 { font-size: 24px; text-align: center; }
      </style>
    </head>
    <body>
      <h1>Этикетка товара</h1>
      <p><b>Артикул:</b> 12345</p>
      <p><b>Цена:</b> 1999.00 руб</p>
    </body>
  </html>
''';

await manager.printTsplHtml(printer, html, PaperSize.mm58.value);
```

```dart
// Печать сырых TSPL команд
const tsplCommands = '''
SIZE 60 mm, 40 mm
GAP 2 mm, 0 mm
DIRECTION 0
CLS
TEXT 50,50,"3",0,1,1,"Тестовая этикетка"
TEXT 50,100,"2",0,1,1,"Артикул: 12345"
PRINT 1
''';

await manager.printTsplRawData(
  printer,
  Uint8List.fromList(utf8.encode(tsplCommands)),
  PaperSize.mm58.value,
);
```

### Построение этикеток программно

Пакет предоставляет функции для построения этикеток из структурированных данных:

```dart
import 'package:pos_printer_manager/pos_printer_manager.dart';

// Создаем данные
final labelData = LabelData(
  itemName: 'Сыр "Российский"',
  unitAbr: 'кг',
  oldPrice: '450.00',
  price: '399.00',
  storeName: 'Супермаркет',
  date: '03/10/2025',
  qrText: '9876543210987',
);

// Построение ZPL этикетки
final zplCommands = buildZplLabel(labelData);
await manager.printZplRawData(
  printer,
  Uint8List.fromList(zplCommands.codeUnits),
  457,
);

// Построение TSPL этикетки
final tsplCommands = buildTsplLabel(labelData);
await manager.printTsplRawData(
  printer,
  Uint8List.fromList(tsplCommands.codeUnits),
  457,
);
```

### Проверка статуса TSPL принтера

```dart
final status = await manager.getTSPLPrinterStatus(printer);
if (status.success) {
  print('TSPL статус код: ${status.code}');
  // Коды статуса:
  // 0x00 - Нормальный
  // 0x01 - Головка открыта
  // 0x04 - Нет бумаги
  // 0x08 - Нет ленты
}
```

## Конфигурация принтера

Язык принтера сохраняется в конфигурации и автоматически загружается при инициализации:

```json
{
  "id": "label_printer_001",
  "name": "TSC Label Printer",
  "printerPosType": "labelPrinter",
  "rawSettings": {
    "language": "tspl",
    "connectionParams": { ... }
  }
}
```

## Миграция существующих принтеров

Существующие label принтеры по умолчанию используют язык **ZPL**. Для переключения на TSPL:

1. Откройте настройки принтера в UI
2. Найдите секцию "Label Printer Language"
3. Выберите "TSPL (TSC Printer Language)"
4. Настройки автоматически сохранятся

## Тестирование

Для проверки работы TSPL принтера:

1. Настройте принтер и выберите язык TSPL
2. Нажмите кнопку "Test print" - будет напечатана тестовая этикетка с использованием TSPL команд
3. Используйте методы `printTsplHtml()` или `printTsplRawData()` для печати своих этикеток

## См. также

- Примеры в `example/lib/pos_printers_api_example.dart`
- Документация базового пакета `pos_printers` в файле `pos-printers.md`

# Обновления pos_printer_manager

## Добавленный функционал

### 1. Методы поиска и обнаружения принтеров

- `findPrinters({PrinterDiscoveryFilter? filter})` - поиск принтеров с фильтрацией
- `awaitDiscoveryComplete()` - ожидание завершения поиска
- `discoveryStream` - поток обнаруженных принтеров
- `connectionEvents` - поток событий подключения/отключения

### 2. Методы статуса и информации о принтере

- `getPrinterStatus(printer)` - получение статуса принтера
- `getPrinterSN(printer)` - получение серийного номера
- `getZPLPrinterStatus(printer)` - получение статуса ZPL принтера

### 3. Методы печати ESC/POS

- `printEscHTML(printer, html, width)` - печать HTML на чековом принтере
- `printEscRawData(printer, data, width)` - печать сырых ESC/POS команд

### 4. Методы печати ZPL (этикетки)

- `printZplHtml(printer, html, width)` - печать HTML на этикеточном принтере
- `printZplRawData(printer, data, width)` - печать сырых ZPL команд

### 5. Управление денежным ящиком

- `openCashBox(printer)` - открытие денежного ящика

### 6. Сетевая конфигурация

- `setNetSettings(printer, networkParams)` - настройка сети через USB
- `configureNetViaUDP(macAddress, networkParams)` - настройка сети через UDP

### 7. Методы совместимости с README

- `addPrinter({type, name})` - добавить принтер (алиас)
- `getPrinters()` - получить список конфигураций
- `updatePrinterConfig(config)` - обновить конфигурацию
- `removePrinter(id)` - удалить принтер (алиас)
- `print(printerId, job)` - печать задания
- `retryConnection(printerId)` - переподключение

## Исправления

1. Исправлено использование `context.mounted` для асинхронных операций
2. Убран лишний импорт `dart:typed_data` (уже есть в foundation.dart)
3. Добавлен правильный вызов `api.dispose()` в методе dispose

## Новые файлы

1. `example/lib/pos_printers_api_example.dart` - полный пример использования всех API
2. `example/lib/main_with_api_demo.dart` - демо с интерфейсом для тестирования
3. Обновлен `README.md` с информацией о новых методах

## Все методы из pos-printers.md README реализованы:

✅ findPrinters
✅ awaitDiscoveryComplete  
✅ getPrinterStatus
✅ getPrinterSN
✅ openCashBox
✅ printEscHTML
✅ printEscRawData
✅ printZplHtml
✅ printZplRawData
✅ getZPLPrinterStatus
✅ setNetSettings
✅ configureNetViaUDP
✅ discoveryStream
✅ connectionEvents

## Архитектура

- PrintersManager теперь предоставляет полный доступ к PosPrintersManager API
- Сохранена обратная совместимость с существующими методами
- Добавлены алиасы для методов, упомянутых в README
- Все методы правильно проксируют вызовы к базовому API

## Типы данных

Все типы из pos_printers плагина доступны через экспорт:

- PaperSize (mm58 = 416 dots, mm80 = 576 dots)
- PrinterDiscoveryFilter
- PrinterConnectionParamsDTO
- NetworkParams
- StatusResult, StringResult, ZPLStatusResult
- DiscoveryConnectionType
- PrinterConnectionEventType, PrinterConnectionEvent

Плагин теперь полностью соответствует описанию в pos-printers.md и предоставляет все заявленные возможности.

# Техническое задание: Flutter-пакет pos_printer_manager

## 1. Введение и цели

**pos_printer_manager** — это обёртка над существующим плагином взаимодействия с принтерами для Android POS-системы. Цель пакета:

- Управлять списком принтеров (создание, удаление, обновление).  
- Автоматически восстанавливать и поддерживать соединение с сохранёнными принтерами.  
- Обеспечить единый API для печати на разных типах принтеров.  
- Сделать архитектуру плагинной для лёгкого добавления новых типов принтеров.  
- Централизовать перехват и логирование ошибок.

## 2. Структура и компоненты

```
lib/
├── pos_printer_manager.dart       // главный экспорт
├── src/
│   ├── config.dart                // PrinterConfig, UsbIdentifier, NetworkEndpoint
│   ├── registry.dart              // PrinterPluginRegistry
│   ├── manager.dart               // PrinterManager (init, CRUD, streams, error‑interceptor)
│   └── protocol/
│       └── handler.dart           // интерфейс PrinterProtocolHandler
└── plugins/
    ├── receipt_printer_plugin.dart
    ├── kitchen_printer_plugin.dart
    └── label_printer_plugin.dart
```

### 2.1 Ядро (`src`)

- **config.dart**  
  - `PrinterConfig` с полем `rawSettings: Map<String, dynamic>`  
  - DTO для `UsbIdentifier` и `NetworkEndpoint`

- **registry.dart**  
  - `PrinterPluginRegistry.register(type, deserializeSettings, createHandler)`  
  - Мапы: `type → SettingsDeserializer` и `type → HandlerFactory`  
  - `buildHandler(PrinterConfig)`

- **handler.dart**  
  - `abstract class PrinterProtocolHandler { Future<void> connect(...); Future<PrintResult> print(...); Future<void> disconnect(); }`

- **manager.dart**  
  - `class PrinterManager { ... }`  
  - Методы: `init()`, `addPrinter()`, `removePrinter()`, `updatePrinterConfig()`, `print()`, `retryConnection()`  
  - Стримы: `printersConfigStream`, `printersStateStream`  
  - Ошло-коллбек: `ErrorInterceptor onError`  
  - Подписка на `usbStream` и автоконнект в `init()`

### 2.2 Плагины (`plugins`)

Для каждого типа принтера:

1. **Settings**  
   ```dart
   class ReceiptPrinterSettings implements PrinterSettings { ... }
   ```
2. **Handler**  
   ```dart
   class ReceiptPrinterHandler implements PrinterProtocolHandler { ... }
   ```
3. **Регистрация**  
   ```dart
   void registerReceiptPrinter() {
     PrinterPluginRegistry.register(
       PrinterType.Receipt,
       deserializeSettings: (json) => ReceiptPrinterSettings.fromJson(json),
       createHandler: (s) => ReceiptPrinterHandler(s as ReceiptPrinterSettings),
     );
   }
   ```

При добавлении нового типа: создать новый файл-плагин и вызвать `registerXxxPrinter()` в bootstrap.

## 3. Функциональные требования

1. **CRUD принтеров**  
   - `addPrinter(type, {name, usbId, endpoint, settings})`  
   - `removePrinter(id)`  
   - `updatePrinterConfig(config)`  
   - `getPrinters()`, `printersStream`

2. **Хранение**  
   - Сериализация списка `PrinterConfig` в JSON и сохранение в `SharedPreferences`.

3. **Инициализация и автоконнект**  
   - Загрузка конфигов в `init()`  
   - Автоподключение к USB (по `vid/pid/serial`) и сетевым принтерам (по IP).

4. **Печать**  
   - `print(printerId, PrintJob job)`  
   - `PrintJob` — базовый класс, конкретные подклассы для каждого типа.

5. **Обработка ошибок**  
   - Глобальный `ErrorInterceptor` в конструкторе `PrinterManager`.

## 4. Сценарии использования

- **Первый запуск**: список пуст, UI предлагает добавить принтер.
- **Сохранённые USB-принтеры**: автоматический connect при обнаружении.
- **Сохранённые сетевые принтеры**: единоразовая попытка connect, ошибки → Offline.
- **Attach/Detach USB**: динамическое переключение статуса принтера.
- **Обновление конфига**: мгновенный disconnect/connect при смене параметров.

## 5. Bootstrap и интеграция

```dart
void main() async {
  // 1. Регистрация плагинов
  registerReceiptPrinter();
  registerKitchenPrinter();
  registerLabelPrinter();

  // 2. Создание и инициализация менеджера
  final manager = PrinterManager(onError: myErrorHandler);
  await manager.init();

  runApp(MyApp(printerManager: manager));
}
```

## 6. Дальнейшие доработки (фичи)

- Очередь `PrintJob` с повторными попытками.
- Детализированные статусы принтера (нет бумаги, перегрев и т.п.).
- Экспоненциальный backoff для сетевых соединений.
- Миграции схемы настроек в SharedPreferences.
- Unit-тесты и примерное демо-приложение.

---

*Документ готов к передаче команде разработки — можно добавить подробности или расширить раздел тестирования по необходимости.*


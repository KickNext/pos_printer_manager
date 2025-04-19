# pos_printer_manager

**Flutter-пакет для управления POS-принтерами**

---

## Содержание
1. [Обзор](#обзор)
2. [Ключевые возможности](#ключевые-возможности)
3. [Структура](#структура)
4. [Установка](#установка)
5. [Использование](#использование)
6. [Дальнейшие доработки](#дальнейшие-доработки)

---

## 1. Обзор

**pos_printer_manager** — это Flutter-пакет, предоставляющий высокоуровневый API для управления списком POS-принтеров (чековых, кухонных, этикеточных и т.д.) в Android-приложениях. Он служит оберткой над низкоуровневыми плагинами или SDK для взаимодействия с конкретными моделями принтеров.

**Цели пакета:**

- Управлять списком логических принтеров (создание, удаление, обновление конфигурации).
- Сохранять конфигурацию принтеров между запусками приложения.
- Автоматически подключаться к настроенным физическим принтерам (USB, Network).
- Предоставлять единый интерфейс для печати на разных типах принтеров.
- Обеспечивать плагинную архитектуру для легкого добавления поддержки новых типов принтеров.
- Централизованно обрабатывать и логировать ошибки соединения и печати.

---

## 2. Ключевые возможности

- **Управление конфигурацией:** Добавление, удаление и обновление логических принтеров с их настройками.
- **Персистентность:** Сохранение конфигураций принтеров с использованием `SharedPreferences`.
- **Автоматическое подключение:** Попытка восстановить соединение с сохраненными принтерами при инициализации. Обработка подключения/отключения USB-устройств.
- **Плагинная архитектура:** Легкое добавление поддержки новых типов принтеров путем регистрации соответствующих обработчиков протоколов и настроек.
- **Единый API печати:** Абстрактный метод `print` в `PrinterManager`, который делегирует печать конкретному обработчику в зависимости от типа принтера.
- **Мониторинг состояния:** Потоки для отслеживания изменений в списке принтеров (`printersConfigStream`) и их статусе подключения (`printersStateStream`).
- **Обработка ошибок:** Глобальный перехватчик ошибок для централизованной обработки.

---

## 3. Структура (основные компоненты)

```
lib/
├── pos_printer_manager.dart       // Главный экспорт пакета
└── src/
    ├── manager.dart               // PrinterManager: ядро пакета (CRUD, потоки, печать, автоконнект)
    ├── config/
    │   └── config.dart            // PrinterConfig, PrinterSettings, UsbIdentifier, NetworkEndpoint
    ├── registry/
    │   └── registry.dart          // PrinterPluginRegistry: регистрация типов принтеров
    ├── protocol/
    │   ├── protocol.dart          // PrinterProtocolHandler (интерфейс), PrintJob, PrintResult
    │   └── handler.dart           // (Может быть объединено с protocol.dart)
    ├── repository/
    │   ├── repository.dart        // Абстракция репозитория
    │   └── shared_prefs_repo.dart // Реализация репозитория на SharedPreferences
    └── plugins/                   // Реализации для конкретных типов принтеров
        ├── printer_settings.dart  // Базовый интерфейс PrinterSettings
        ├── receipt_printer/
        │   └── receipt_printer_plugin.dart // Настройки, обработчик и регистрация для чекового принтера
        ├── kitchen_printer/
        │   └── kitchen_printer_plugin.dart // Для кухонного принтера
        └── label_printer/
            └── label_printer_plugin.dart   // Для принтера этикеток
```

---

## 4. Установка

Поскольку пакет еще не опубликован на pub.dev, добавьте его из Git в ваш `pubspec.yaml`:

```yaml
dependencies:
  pos_printer_manager:
    git:
      url: <URL_ВАШЕГО_РЕПОЗИТОРИЯ> # Замените на реальный URL
      ref: main # Или нужная ветка/тег
  shared_preferences: ^2.0.0 # Пример зависимости для репозитория
  # Другие зависимости, если нужны (например, для USB, сети)
```

Затем выполните `flutter pub get`.

---

## 5. Использование

### Инициализация

```dart
import 'package:pos_printer_manager/pos_printer_manager.dart';
// Импортируйте файлы регистрации ваших плагинов
import 'package:pos_printer_manager/src/plugins/receipt_printer/receipt_printer_plugin.dart';
import 'package:pos_printer_manager/src/plugins/kitchen_printer/kitchen_printer_plugin.dart';
import 'package:pos_printer_manager/src/plugins/label_printer/label_printer_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Создаем репозиторий (например, на SharedPreferences)
  final printerRepository = SharedPrefsPrinterRepository();
  await printerRepository.init(); // Важно для SharedPreferences

  // 2. Создаем реестр плагинов
  final registry = PrinterPluginRegistry();

  // 3. Регистрируем типы принтеров
  registerReceiptPrinter(registry);
  registerKitchenPrinter(registry);
  registerLabelPrinter(registry);

  // 4. Создаем и инициализируем менеджер
  final manager = PrinterManager(
    registry: registry,
    repository: printerRepository,
    onError: (error, stackTrace) {
      print('PrinterManager Error: $error');
      // Здесь ваша логика обработки ошибок
    },
  );
  await manager.init(); // Загрузка конфигов и попытка автоподключения

  runApp(MyApp(printerManager: manager));
}
```

### Основные операции

```dart
// Получить текущий список конфигураций
List<PrinterConfig> configs = manager.getPrinters();

// Подписаться на изменения конфигураций
manager.printersConfigStream.listen((configs) {
  // Обновить UI со списком принтеров
});

// Подписаться на изменения статусов подключения
manager.printersStateStream.listen((states) {
  // states - это Map<String, PrinterConnectivityState>
  // Обновить UI статусов принтеров
});

// Добавить новый принтер (пример для чекового)
final newConfig = await manager.addPrinter(
  type: PrinterType.Receipt, // Используйте Enum вашего типа
  name: 'Касса 1',
  // Начальные настройки можно не указывать или указать пустые
);

// Обновить конфигурацию (например, привязать физический принтер)
PrinterConfig updatedConfig = newConfig.copyWith(
  // Здесь указываются параметры для подключения:
  // usbId: UsbIdentifier(...),
  // endpoint: NetworkEndpoint(...),
  // rawSettings: {...} // Специфичные настройки типа
);
await manager.updatePrinterConfig(updatedConfig);

// Удалить принтер
await manager.removePrinter(newConfig.id);

// Напечатать задание (пример)
class MyReceiptJob implements PrintJob {
  final String content;
  MyReceiptJob(this.content);
}

try {
  PrintResult result = await manager.print(newConfig.id, MyReceiptJob('Тестовая печать'));
  if (result.isSuccess) {
    print('Печать успешна');
  } else {
    print('Ошибка печати: ${result.errorMessage}');
  }
} catch (e) {
  print('Исключение при печати: $e');
}

// Попробовать переподключиться к принтеру
await manager.retryConnection(newConfig.id);

// Не забудьте освободить ресурсы менеджера
// manager.dispose(); // В dispose вашего виджета/приложения
```

---

## 6. Дальнейшие доработки

- Реализация очереди печати (`PrintJob`) с повторными попытками.
- Получение детализированных статусов принтера (нет бумаги, крышка открыта и т.д.) от `PrinterProtocolHandler`.
- Использование экспоненциального backoff при переподключении к сетевым принтерам.
- Механизм миграции схемы настроек при обновлении версии пакета.
- Добавление Unit-тестов.
- Расширение и улучшение демо-приложения в `example/`.

---

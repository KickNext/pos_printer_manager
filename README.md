# POS Printer Manager

Библиотека управления POS-принтерами для Flutter.

Предоставляет комплексное решение для работы с различными типами POS-принтеров: чековые, кухонные, этикеточные и AndroBar.

## Возможности

- **Управление принтерами** — добавление, настройка, удаление принтеров
- **Поиск устройств** — автоматическое обнаружение принтеров в сети
- **Печать** — поддержка разных типов заданий (чеки, этикетки, кухонные талоны)
- **UI компоненты** — готовые виджеты для управления принтерами (Atomic Design)
- **Clean Architecture** — чистая архитектура с Use Cases и Repository
- **Type-safe** — строгая типизация с sealed classes и Result type

## Установка

Добавьте зависимость в `pubspec.yaml`:

```yaml
dependencies:
  pos_printer_manager:
    git:
      url: https://github.com/your-repo/pos_printer_manager.git
```

## Быстрый старт

### Инициализация

```dart
import 'package:pos_printer_manager/pos_printer_manager.dart';

// Создание репозитория для хранения конфигураций
final repository = SharedPrefsPrinterConfigRepository();

// Создание менеджера принтеров
final manager = PrinterManager(repository: repository);

// Инициализация
await manager.init();
```

### Добавление принтера

```dart
final result = await manager.addPrinter(
  AddPrinterParams(
    name: 'Kitchen Printer',
    type: PrinterType.kitchen,
    address: '192.168.1.100',
    port: 9100,
  ),
);

result.fold(
  onSuccess: (printer) => print('Принтер добавлен: ${printer.id}'),
  onFailure: (error) => print('Ошибка: ${error.message}'),
);
```

### Поиск принтеров

```dart
final finder = PrintersFinder();

// Подписка на обнаруженные принтеры
finder.foundPrinters.listen((printers) {
  for (final printer in printers) {
    print('Найден: ${printer.address}:${printer.port}');
  }
});

// Запуск поиска
await finder.findPrinters();

// Не забудьте освободить ресурсы
finder.dispose();
```

### Печать

```dart
// Чековый принтер
final receiptJob = ReceiptPrintJob(
  content: 'Содержимое чека',
  cut: true,
);
await handler.print(receiptJob);

// Этикеточный принтер
final labelJob = LabelPrintJob(
  label: LabelData(
    width: 40.0,
    height: 30.0,
    content: 'Этикетка',
  ),
);
await handler.print(labelJob);

// Кухонный принтер
final kitchenJob = KitchenPrintJob(
  orderNumber: '42',
  items: ['Пицца', 'Кола'],
);
await handler.print(kitchenJob);
```

## Архитектура

Библиотека построена на принципах Clean Architecture:

```
lib/
├── pos_printer_manager.dart  # Главный экспорт
└── src/
    ├── core/                 # Базовые утилиты
    │   ├── result.dart       # Result<T> для обработки ошибок
    │   ├── logger.dart       # LoggerMixin для логирования
    │   └── id_generator.dart # UUID генератор
    │
    ├── domain/               # Бизнес-логика
    │   └── use_cases/        # Use Cases (AddPrinter, UpdatePrinter, etc.)
    │
    ├── models/               # Модели данных
    │   ├── printer_config.dart
    │   ├── pos_printer.dart
    │   └── printer_type.dart
    │
    ├── plugins/              # Плагины принтеров
    │   ├── receipt_printer/
    │   ├── kitchen_printer/
    │   ├── label_printer/
    │   └── andro_bar_printer/
    │
    ├── protocol/             # Протокол печати
    │   ├── print_job.dart    # Sealed class заданий
    │   └── handler.dart      # Обработчик печати
    │
    ├── repository/           # Хранение данных
    │   ├── repository.dart   # Абстракция
    │   └── shared_prefs_repo.dart
    │
    ├── registry/             # Реестр плагинов
    │
    └── ui/                   # UI компоненты (Atomic Design)
        ├── atoms/
        ├── molecules/
        └── organisms/
```

## Типы принтеров  

| Тип        | Описание             | Класс задания      |
| ---------- | -------------------- | ------------------ |
| `receipt`  | Чековые принтеры     | `ReceiptPrintJob`  |    
| `kitchen`  | Кухонные принтеры    | `KitchenPrintJob`  |
| `label`    | Этикеточные принтеры | `LabelPrintJob`    |  
| `androBar` | Принтеры AndroBar    | `AndroBarPrintJob` |

## Result Type

Все асинхронные операции возвращают `Result<T>`:

```dart
final result = await manager.updatePrinter(params);

// Вариант 1: через fold
result.fold(
  onSuccess: (printer) => handleSuccess(printer),
  onFailure: (error) => handleError(error),
);

// Вариант 2: через свойства
if (result.isSuccess) {
  final printer = result.value;
} else {
  final error = result.error;
  // error имеет тип AppError с полями:
  // - message: String
  // - code: String
  // - originalError: Object?
  // - stackTrace: StackTrace?
}

// Вариант 3: получить значение или null
final printer = result.valueOrNull;
```

## UI Компоненты

Библиотека предоставляет готовые виджеты:

```dart
// Страница управления принтерами
PrintersPage(manager: manager)

// Детальный экран принтера
PrinterDetailScreen(printer: printer, manager: manager)
```

## Тестирование

```bash
flutter test
```

## Требования

- Flutter SDK: >=3.38.3
- Dart SDK: ^3.10.1

## Лицензия

MIT License

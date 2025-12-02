/// Система логирования enterprise-уровня для pos_printer_manager.
///
/// Предоставляет централизованное структурированное логирование
/// с поддержкой уровней, категорий и форматирования.
///
/// ## Использование:
///
/// ```dart
/// // Получение логгера для конкретного компонента
/// final logger = PrinterLogger.getLogger('PrinterManager');
///
/// // Логирование с разными уровнями
/// logger.debug('Initializing printer connection');
/// logger.info('Printer connected successfully');
/// logger.warning('Low paper detected');
/// logger.error('Print failed', error: exception, stackTrace: st);
///
/// // Структурированное логирование с контекстом
/// logger.info(
///   'Print job completed',
///   data: {'printerId': '123', 'jobId': 'abc', 'pages': 5},
/// );
///
/// // Настройка глобального уровня логирования
/// PrinterLogger.setGlobalLevel(LogLevel.warning); // Только warning и выше
///
/// // Добавление пользовательского обработчика логов
/// PrinterLogger.addHandler((entry) {
///   // Отправка в аналитику, файл и т.д.
///   analytics.logEvent(entry.toMap());
/// });
/// ```
library;

import 'package:flutter/foundation.dart';

/// Уровни логирования.
///
/// Определяют важность сообщения и используются для фильтрации.
enum LogLevel {
  /// Отладочная информация (только для разработки).
  debug,

  /// Информационные сообщения о работе системы.
  info,

  /// Предупреждения о потенциальных проблемах.
  warning,

  /// Ошибки, требующие внимания.
  error,

  /// Критические ошибки (падение системы).
  fatal,

  /// Логирование отключено.
  off,
}

/// Расширение для сравнения уровней логирования.
extension LogLevelComparison on LogLevel {
  /// Проверяет, является ли уровень достаточно важным.
  bool isAtLeast(LogLevel other) => index >= other.index;

  /// Возвращает символ эмодзи для уровня.
  String get emoji => switch (this) {
    LogLevel.debug => '🔍',
    LogLevel.info => 'ℹ️',
    LogLevel.warning => '⚠️',
    LogLevel.error => '❌',
    LogLevel.fatal => '💥',
    LogLevel.off => '',
  };

  /// Возвращает цветной ANSI-код для терминала.
  String get ansiColor => switch (this) {
    LogLevel.debug => '\x1B[37m', // Серый
    LogLevel.info => '\x1B[34m', // Синий
    LogLevel.warning => '\x1B[33m', // Желтый
    LogLevel.error => '\x1B[31m', // Красный
    LogLevel.fatal => '\x1B[35m', // Пурпурный
    LogLevel.off => '',
  };

  /// Сбрасывает ANSI-форматирование.
  static const String ansiReset = '\x1B[0m';
}

/// Запись лога с метаданными.
@immutable
class LogEntry {
  /// Уровень важности.
  final LogLevel level;

  /// Сообщение лога.
  final String message;

  /// Имя логгера (компонент).
  final String loggerName;

  /// Время записи.
  final DateTime timestamp;

  /// Исключение (если есть).
  final Object? error;

  /// Stack trace исключения.
  final StackTrace? stackTrace;

  /// Дополнительные данные для структурированного логирования.
  final Map<String, dynamic>? data;

  /// Создает запись лога.
  const LogEntry({
    required this.level,
    required this.message,
    required this.loggerName,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.data,
  });

  /// Форматирует запись для вывода в консоль.
  String format({bool useColors = true, bool useEmoji = true}) {
    final buffer = StringBuffer();

    // Временная метка
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';

    // Уровень с цветом
    final levelStr = level.name.toUpperCase().padRight(7);
    final coloredLevel = useColors
        ? '${level.ansiColor}$levelStr${LogLevelComparison.ansiReset}'
        : levelStr;

    // Эмодзи
    final emoji = useEmoji ? '${level.emoji} ' : '';

    // Основное сообщение
    buffer.write('$emoji[$time] [$coloredLevel] [$loggerName] $message');

    // Дополнительные данные
    if (data != null && data!.isNotEmpty) {
      buffer.write(' | ${_formatData(data!)}');
    }

    // Ошибка и stack trace
    if (error != null) {
      buffer.write('\n  Error: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n  StackTrace:\n${_indentStackTrace(stackTrace!)}');
    }

    return buffer.toString();
  }

  /// Форматирует данные в строку key=value.
  String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }

  /// Добавляет отступы к stack trace.
  String _indentStackTrace(StackTrace st) {
    return st
        .toString()
        .split('\n')
        .take(10) // Ограничиваем глубину
        .map((line) => '    $line')
        .join('\n');
  }

  /// Конвертирует в Map для сериализации.
  Map<String, dynamic> toMap() => {
    'level': level.name,
    'message': message,
    'logger': loggerName,
    'timestamp': timestamp.toIso8601String(),
    if (error != null) 'error': error.toString(),
    if (data != null) 'data': data,
  };
}

/// Тип callback-функции для обработки логов.
typedef LogHandler = void Function(LogEntry entry);

/// Централизованная система логирования.
///
/// Реализует паттерн Registry для получения именованных логгеров.
/// Поддерживает множество обработчиков для отправки логов
/// в разные места назначения.
class PrinterLogger {
  /// Кэш созданных логгеров.
  static final Map<String, PrinterLogger> _loggers = {};

  /// Обработчики логов.
  static final List<LogHandler> _handlers = [];

  /// Глобальный уровень логирования.
  static LogLevel _globalLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Использовать цвета в консоли.
  static bool useColors = true;

  /// Использовать эмодзи в консоли.
  static bool useEmoji = true;

  /// Имя этого логгера.
  final String name;

  /// Уровень логирования для этого логгера (переопределяет глобальный).
  LogLevel? _level;

  /// Приватный конструктор.
  PrinterLogger._(this.name);

  /// Получает или создает логгер с указанным именем.
  ///
  /// Логгеры кэшируются, повторные вызовы с тем же именем
  /// вернут тот же экземпляр.
  static PrinterLogger getLogger(String name) {
    return _loggers.putIfAbsent(name, () => PrinterLogger._(name));
  }

  /// Устанавливает глобальный уровень логирования.
  ///
  /// Сообщения ниже этого уровня будут игнорироваться.
  static void setGlobalLevel(LogLevel level) {
    _globalLevel = level;
  }

  /// Получает текущий глобальный уровень логирования.
  static LogLevel get globalLevel => _globalLevel;

  /// Добавляет обработчик логов.
  ///
  /// Все записи лога будут передаваться всем зарегистрированным
  /// обработчикам.
  static void addHandler(LogHandler handler) {
    _handlers.add(handler);
  }

  /// Удаляет обработчик логов.
  static void removeHandler(LogHandler handler) {
    _handlers.remove(handler);
  }

  /// Очищает все обработчики логов.
  static void clearHandlers() {
    _handlers.clear();
  }

  /// Сбрасывает все настройки и кэш логгеров.
  ///
  /// Полезно для тестирования.
  static void reset() {
    _loggers.clear();
    _handlers.clear();
    _globalLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
    useColors = true;
    useEmoji = true;
  }

  /// Устанавливает уровень логирования для этого логгера.
  set level(LogLevel? level) => _level = level;

  /// Получает эффективный уровень логирования.
  LogLevel get effectiveLevel => _level ?? _globalLevel;

  /// Проверяет, будет ли сообщение с указанным уровнем залогировано.
  bool isEnabled(LogLevel level) => level.isAtLeast(effectiveLevel);

  /// Логирует сообщение с указанным уровнем.
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Пропускаем если уровень недостаточен
    if (!isEnabled(level)) return;

    // Создаем запись
    final entry = LogEntry(
      level: level,
      message: message,
      loggerName: name,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    // Выводим в консоль
    _printToConsole(entry);

    // Передаем обработчикам
    for (final handler in _handlers) {
      try {
        handler(entry);
      } catch (e) {
        // Игнорируем ошибки в обработчиках чтобы не прервать логирование
        debugPrint('Error in log handler: $e');
      }
    }
  }

  /// Выводит запись в консоль.
  void _printToConsole(LogEntry entry) {
    final formatted = entry.format(useColors: useColors, useEmoji: useEmoji);

    // Используем debugPrint для правильного вывода в Flutter DevTools
    debugPrint(formatted);
  }

  /// Логирует отладочное сообщение.
  void debug(String message, {Map<String, dynamic>? data}) {
    log(LogLevel.debug, message, data: data);
  }

  /// Логирует информационное сообщение.
  void info(String message, {Map<String, dynamic>? data}) {
    log(LogLevel.info, message, data: data);
  }

  /// Логирует предупреждение.
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.warning,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Логирует ошибку.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Логирует критическую ошибку.
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.fatal,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Логирует начало операции (для измерения времени).
  Stopwatch startOperation(String operationName) {
    debug('Starting: $operationName');
    return Stopwatch()..start();
  }

  /// Логирует завершение операции с временем выполнения.
  void endOperation(String operationName, Stopwatch stopwatch) {
    stopwatch.stop();
    info(
      'Completed: $operationName',
      data: {'durationMs': stopwatch.elapsedMilliseconds},
    );
  }
}

/// Предопределенные логгеры для основных компонентов.
///
/// Использование предопределенных логгеров обеспечивает
/// консистентность именования в проекте.
class Loggers {
  Loggers._();

  /// Логгер для PrinterManager.
  static final PrinterLogger manager = PrinterLogger.getLogger(
    'PrinterManager',
  );

  /// Логгер для обнаружения принтеров.
  static final PrinterLogger discovery = PrinterLogger.getLogger(
    'PrinterDiscovery',
  );

  /// Логгер для печати.
  static final PrinterLogger printing = PrinterLogger.getLogger('Printing');

  /// Логгер для USB-операций.
  static final PrinterLogger usb = PrinterLogger.getLogger('USB');

  /// Логгер для сетевых операций.
  static final PrinterLogger network = PrinterLogger.getLogger('Network');

  /// Логгер для репозитория.
  static final PrinterLogger repository = PrinterLogger.getLogger('Repository');

  /// Логгер для UI.
  static final PrinterLogger ui = PrinterLogger.getLogger('UI');
}

/// Миксин для добавления логирования в класс.
///
/// Пример:
/// ```dart
/// class MyService with LoggerMixin {
///   @override
///   String get loggerName => 'MyService';
///
///   void doSomething() {
///     logger.info('Doing something');
///   }
/// }
/// ```
mixin LoggerMixin {
  /// Имя логгера для этого класса.
  String get loggerName;

  /// Логгер для этого класса.
  PrinterLogger get logger => PrinterLogger.getLogger(loggerName);
}

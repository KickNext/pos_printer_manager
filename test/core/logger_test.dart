import 'package:flutter_test/flutter_test.dart';
import 'package:pos_printer_manager/src/core/logger.dart';

void main() {
  setUp(() {
    // Сбрасываем настройки логгера перед каждым тестом
    PrinterLogger.reset();
  });

  group('PrinterLogger', () {
    test('getLogger возвращает логгер с указанным именем', () {
      final logger = PrinterLogger.getLogger('TestLogger');

      expect(logger.name, equals('TestLogger'));
    });

    test('getLogger кэширует логгеры', () {
      final logger1 = PrinterLogger.getLogger('Test');
      final logger2 = PrinterLogger.getLogger('Test');

      expect(identical(logger1, logger2), isTrue);
    });

    test('getLogger создает разные логгеры для разных имен', () {
      final logger1 = PrinterLogger.getLogger('Logger1');
      final logger2 = PrinterLogger.getLogger('Logger2');

      expect(identical(logger1, logger2), isFalse);
      expect(logger1.name, equals('Logger1'));
      expect(logger2.name, equals('Logger2'));
    });

    test('setGlobalLevel устанавливает глобальный уровень', () {
      PrinterLogger.setGlobalLevel(LogLevel.warning);

      expect(PrinterLogger.globalLevel, equals(LogLevel.warning));
    });

    test('effectiveLevel возвращает глобальный уровень по умолчанию', () {
      PrinterLogger.setGlobalLevel(LogLevel.info);
      final logger = PrinterLogger.getLogger('Test');

      expect(logger.effectiveLevel, equals(LogLevel.info));
    });

    test('effectiveLevel возвращает локальный уровень если задан', () {
      PrinterLogger.setGlobalLevel(LogLevel.info);
      final logger = PrinterLogger.getLogger('Test');
      logger.level = LogLevel.error;

      expect(logger.effectiveLevel, equals(LogLevel.error));
    });

    test('isEnabled проверяет уровень логирования', () {
      PrinterLogger.setGlobalLevel(LogLevel.warning);
      final logger = PrinterLogger.getLogger('Test');

      expect(logger.isEnabled(LogLevel.debug), isFalse);
      expect(logger.isEnabled(LogLevel.info), isFalse);
      expect(logger.isEnabled(LogLevel.warning), isTrue);
      expect(logger.isEnabled(LogLevel.error), isTrue);
      expect(logger.isEnabled(LogLevel.fatal), isTrue);
    });

    test('addHandler добавляет обработчик', () {
      final entries = <LogEntry>[];
      PrinterLogger.addHandler((entry) => entries.add(entry));

      final logger = PrinterLogger.getLogger('Test');
      logger.info('Test message');

      expect(entries.length, equals(1));
      expect(entries.first.message, equals('Test message'));
    });

    test('removeHandler удаляет обработчик', () {
      final entries = <LogEntry>[];
      void handler(LogEntry entry) => entries.add(entry);

      PrinterLogger.addHandler(handler);
      PrinterLogger.removeHandler(handler);

      final logger = PrinterLogger.getLogger('Test');
      logger.info('Test message');

      expect(entries, isEmpty);
    });

    test('clearHandlers удаляет все обработчики', () {
      final entries1 = <LogEntry>[];
      final entries2 = <LogEntry>[];

      PrinterLogger.addHandler((entry) => entries1.add(entry));
      PrinterLogger.addHandler((entry) => entries2.add(entry));
      PrinterLogger.clearHandlers();

      final logger = PrinterLogger.getLogger('Test');
      logger.info('Test message');

      expect(entries1, isEmpty);
      expect(entries2, isEmpty);
    });

    test('reset сбрасывает все настройки', () {
      PrinterLogger.setGlobalLevel(LogLevel.fatal);
      PrinterLogger.getLogger('Test');
      PrinterLogger.addHandler((_) {});

      PrinterLogger.reset();

      // После reset глобальный уровень сбрасывается
      // (debug в debug mode, info в release)
      expect(PrinterLogger.globalLevel, isNot(equals(LogLevel.fatal)));
    });
  });

  group('Log methods', () {
    late PrinterLogger logger;
    late List<LogEntry> entries;

    setUp(() {
      entries = [];
      PrinterLogger.addHandler((entry) => entries.add(entry));
      PrinterLogger.setGlobalLevel(LogLevel.debug);
      logger = PrinterLogger.getLogger('TestLogger');
    });

    test('debug создает запись с уровнем debug', () {
      logger.debug('Debug message');

      expect(entries.length, equals(1));
      expect(entries.first.level, equals(LogLevel.debug));
      expect(entries.first.message, equals('Debug message'));
      expect(entries.first.loggerName, equals('TestLogger'));
    });

    test('info создает запись с уровнем info', () {
      logger.info('Info message');

      expect(entries.length, equals(1));
      expect(entries.first.level, equals(LogLevel.info));
      expect(entries.first.message, equals('Info message'));
    });

    test('warning создает запись с уровнем warning', () {
      logger.warning('Warning message');

      expect(entries.length, equals(1));
      expect(entries.first.level, equals(LogLevel.warning));
      expect(entries.first.message, equals('Warning message'));
    });

    test('error создает запись с уровнем error', () {
      final exception = Exception('Test exception');
      logger.error('Error message', error: exception);

      expect(entries.length, equals(1));
      expect(entries.first.level, equals(LogLevel.error));
      expect(entries.first.message, equals('Error message'));
      expect(entries.first.error, equals(exception));
    });

    test('fatal создает запись с уровнем fatal', () {
      logger.fatal('Fatal message');

      expect(entries.length, equals(1));
      expect(entries.first.level, equals(LogLevel.fatal));
      expect(entries.first.message, equals('Fatal message'));
    });

    test('логирование с данными', () {
      logger.info('Message with data', data: {'key': 'value', 'count': 42});

      expect(entries.first.data, isNotNull);
      expect(entries.first.data!['key'], equals('value'));
      expect(entries.first.data!['count'], equals(42));
    });

    test('логирование с ошибкой и stack trace', () {
      final error = Exception('Test');
      final stackTrace = StackTrace.current;

      logger.error('Error with stack', error: error, stackTrace: stackTrace);

      expect(entries.first.error, equals(error));
      expect(entries.first.stackTrace, equals(stackTrace));
    });

    test('сообщения ниже уровня не логируются', () {
      PrinterLogger.setGlobalLevel(LogLevel.error);

      logger.debug('Debug');
      logger.info('Info');
      logger.warning('Warning');
      logger.error('Error');

      expect(entries.length, equals(1));
      expect(entries.first.level, equals(LogLevel.error));
    });
  });

  group('LogEntry', () {
    test('format создает читаемую строку', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        loggerName: 'TestLogger',
        timestamp: DateTime(2024, 1, 15, 10, 30, 45, 123),
      );

      final formatted = entry.format(useColors: false, useEmoji: false);

      expect(formatted, contains('10:30:45.123'));
      expect(formatted, contains('INFO'));
      expect(formatted, contains('TestLogger'));
      expect(formatted, contains('Test message'));
    });

    test('format включает данные', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test',
        loggerName: 'Logger',
        timestamp: DateTime.now(),
        data: {'key': 'value'},
      );

      final formatted = entry.format(useColors: false, useEmoji: false);

      expect(formatted, contains('key=value'));
    });

    test('format включает ошибку', () {
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'Error occurred',
        loggerName: 'Logger',
        timestamp: DateTime.now(),
        error: Exception('Test exception'),
      );

      final formatted = entry.format(useColors: false, useEmoji: false);

      expect(formatted, contains('Error:'));
      expect(formatted, contains('Test exception'));
    });

    test('toMap создает правильную структуру', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30, 45);
      final entry = LogEntry(
        level: LogLevel.warning,
        message: 'Warning message',
        loggerName: 'TestLogger',
        timestamp: timestamp,
        data: {'extra': 'data'},
      );

      final map = entry.toMap();

      expect(map['level'], equals('warning'));
      expect(map['message'], equals('Warning message'));
      expect(map['logger'], equals('TestLogger'));
      expect(map['timestamp'], equals(timestamp.toIso8601String()));
      expect(map['data'], equals({'extra': 'data'}));
    });
  });

  group('LogLevel', () {
    test('isAtLeast сравнивает уровни корректно', () {
      expect(LogLevel.debug.isAtLeast(LogLevel.debug), isTrue);
      expect(LogLevel.debug.isAtLeast(LogLevel.info), isFalse);
      expect(LogLevel.error.isAtLeast(LogLevel.warning), isTrue);
      expect(LogLevel.fatal.isAtLeast(LogLevel.debug), isTrue);
    });

    test('emoji возвращает соответствующий эмодзи', () {
      expect(LogLevel.debug.emoji, equals('🔍'));
      expect(LogLevel.info.emoji, equals('ℹ️'));
      expect(LogLevel.warning.emoji, equals('⚠️'));
      expect(LogLevel.error.emoji, equals('❌'));
      expect(LogLevel.fatal.emoji, equals('💥'));
    });
  });

  group('Loggers предопределенные', () {
    test('manager логгер имеет правильное имя', () {
      expect(Loggers.manager.name, equals('PrinterManager'));
    });

    test('discovery логгер имеет правильное имя', () {
      expect(Loggers.discovery.name, equals('PrinterDiscovery'));
    });

    test('printing логгер имеет правильное имя', () {
      expect(Loggers.printing.name, equals('Printing'));
    });

    test('usb логгер имеет правильное имя', () {
      expect(Loggers.usb.name, equals('USB'));
    });

    test('network логгер имеет правильное имя', () {
      expect(Loggers.network.name, equals('Network'));
    });

    test('repository логгер имеет правильное имя', () {
      expect(Loggers.repository.name, equals('Repository'));
    });

    test('ui логгер имеет правильное имя', () {
      expect(Loggers.ui.name, equals('UI'));
    });
  });

  group('LoggerMixin', () {
    test('предоставляет логгер с указанным именем', () {
      final service = _TestServiceWithLogger();

      expect(service.logger.name, equals('TestService'));
    });
  });

  group('Operation timing', () {
    late PrinterLogger logger;
    late List<LogEntry> entries;

    setUp(() {
      entries = [];
      PrinterLogger.addHandler((entry) => entries.add(entry));
      PrinterLogger.setGlobalLevel(LogLevel.debug);
      logger = PrinterLogger.getLogger('TestLogger');
    });

    test('startOperation создает debug запись и возвращает stopwatch', () {
      final stopwatch = logger.startOperation('TestOperation');

      expect(stopwatch.isRunning, isTrue);
      expect(entries.length, equals(1));
      expect(entries.first.message, contains('Starting: TestOperation'));
    });

    test('endOperation создает info запись с длительностью', () async {
      final stopwatch = logger.startOperation('TestOperation');
      await Future.delayed(const Duration(milliseconds: 10));
      logger.endOperation('TestOperation', stopwatch);

      expect(stopwatch.isRunning, isFalse);
      expect(entries.length, equals(2));
      expect(entries.last.message, contains('Completed: TestOperation'));
      expect(entries.last.data, containsPair('durationMs', isA<int>()));
    });
  });
}

/// Тестовый класс для проверки LoggerMixin.
class _TestServiceWithLogger with LoggerMixin {
  @override
  String get loggerName => 'TestService';
}

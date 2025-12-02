/// Обработчик событий подключения/отключения принтеров.
///
/// Синхронизирует статусы сохранённых принтеров с реальными
/// событиями USB подключения/отключения устройств.
///
/// ## Ответственность:
///
/// - Отслеживание событий attach/detach USB-устройств
/// - Обновление статуса подключения принтеров
/// - Синхронизация списка найденных принтеров
/// - Проверка USB-разрешений при переподключении
///
/// ## Пример использования:
///
/// ```dart
/// final handler = PrintersConnectionsHandler(manager: printersManager);
///
/// // При уничтожении приложения
/// handler.dispose();
/// ```
library;

import 'dart:async';

import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Обработчик событий подключения USB-принтеров.
///
/// Автоматически обновляет статусы принтеров при их
/// физическом подключении или отключении.
class PrintersConnectionsHandler with LoggerMixin {
  /// Создаёт обработчик событий подключения.
  ///
  /// [manager] — менеджер принтеров для получения списка
  /// сохранённых принтеров и finder'а.
  PrintersConnectionsHandler({required PrintersManager manager})
    : _manager = manager {
    _initSync();
  }

  /// Менеджер принтеров.
  final PrintersManager _manager;

  /// Подписка на события подключения/отключения.
  StreamSubscription<PrinterConnectionEvent>? _connectionEventsSub;

  /// Флаг, указывающий что объект был disposed.
  bool _isDisposed = false;

  @override
  String get loggerName => 'PrintersConnectionsHandler';

  /// API для работы с принтерами.
  PosPrintersManager get _api => _manager.api;

  /// Список сохранённых принтеров.
  List<PosPrinter> get _savedPrinters => _manager.printers;

  /// Инициализирует подписку на события подключения.
  void _initSync() {
    logger.info('Initializing connection events handler');

    _connectionEventsSub = _api.connectionEvents.listen(
      _handleConnectionEvent,
      onError: _handleError,
    );
  }

  /// Обрабатывает событие подключения/отключения принтера.
  void _handleConnectionEvent(PrinterConnectionEvent event) {
    if (_isDisposed) return;

    logger.debug('Connection event received', data: {
      'type': event.type.name,
      'printerId': event.id,
      'hasPrinter': event.printer != null,
    });

    switch (event.type) {
      case PrinterConnectionEventType.attached:
        _handleAttached(event);
      case PrinterConnectionEventType.detached:
        _handleDetached(event);
    }
  }

  /// Обрабатывает событие подключения принтера.
  void _handleAttached(PrinterConnectionEvent event) {
    if (event.printer == null) {
      logger.warning('Attached event without printer data');
      return;
    }

    final printer = event.printer!;

    // Проверяем, есть ли такой принтер среди сохранённых
    final savedPrinter = _findSavedPrinter(printer.id);

    if (savedPrinter != null) {
      logger.info('Saved printer attached', data: {
        'printerId': savedPrinter.id,
        'name': savedPrinter.config.name,
      });

      // Обновляем статус на "подключен"
      savedPrinter.updateStatus(true);

      // Проверяем USB-разрешение при переподключении
      _checkUsbPermissionAsync(savedPrinter);
    }

    // Добавляем в список найденных принтеров
    _manager.finder.addPrinter(printer);
  }

  /// Обрабатывает событие отключения принтера.
  void _handleDetached(PrinterConnectionEvent event) {
    if (event.printer == null) {
      logger.warning('Detached event without printer data');
      return;
    }

    final printer = event.printer!;

    // Проверяем, есть ли такой принтер среди сохранённых
    final savedPrinter = _findSavedPrinter(printer.id);

    if (savedPrinter != null) {
      logger.info('Saved printer detached', data: {
        'printerId': savedPrinter.id,
        'name': savedPrinter.config.name,
      });

      // Обновляем статус на "отключен" (ошибка)
      savedPrinter.updateStatus(false);
    }

    // Удаляем из списка найденных принтеров
    _manager.finder.removePrinter(printer);
  }

  /// Ищет сохранённый принтер по ID подключения.
  PosPrinter? _findSavedPrinter(String connectionId) {
    return _savedPrinters.where((printer) {
      return printer.handler.settings.connectionParams?.id == connectionId;
    }).firstOrNull;
  }

  /// Асинхронно проверяет USB-разрешение для принтера.
  void _checkUsbPermissionAsync(PosPrinter printer) {
    // Запускаем проверку асинхронно, не блокируя обработку событий
    Future.microtask(() async {
      try {
        await printer.checkUsbPermission();
        logger.debug('USB permission checked', data: {
          'printerId': printer.id,
          'status': printer.usbPermissionStatus.name,
        });
      } catch (e, st) {
        logger.warning(
          'Failed to check USB permission',
          error: e,
          stackTrace: st,
          data: {'printerId': printer.id},
        );
      }
    });
  }

  /// Обрабатывает ошибки из стрима событий.
  void _handleError(Object error, StackTrace stackTrace) {
    if (_isDisposed) return;

    logger.error(
      'Connection events stream error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Освобождает ресурсы обработчика.
  ///
  /// После вызова этого метода обработчик перестаёт
  /// отслеживать события подключения.
  void dispose() {
    if (_isDisposed) return;

    logger.info('Disposing PrintersConnectionsHandler');

    _isDisposed = true;
    _connectionEventsSub?.cancel();
    _connectionEventsSub = null;
  }
}

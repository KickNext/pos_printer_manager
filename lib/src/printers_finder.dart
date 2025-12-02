/// Компонент поиска POS-принтеров в сети и по USB.
///
/// Предоставляет реактивный интерфейс для обнаружения принтеров
/// с поддержкой фильтрации по типу подключения.
///
/// ## Пример использования:
///
/// ```dart
/// final finder = PrintersFinder(posPrintersManager: api);
///
/// // Подписка на изменения
/// finder.addListener(() {
///   print('Found: ${finder.foundPrinters.length} printers');
/// });
///
/// // Запуск поиска
/// await finder.findPrinters(printer: myPrinter);
///
/// // Остановка поиска
/// finder.stopSearch();
///
/// // Очистка ресурсов
/// finder.dispose();
/// ```
library;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Компонент поиска принтеров в сети и по USB.
///
/// Управляет процессом обнаружения принтеров и хранит список
/// найденных устройств. Уведомляет слушателей об изменениях
/// через [ChangeNotifier].
class PrintersFinder extends ChangeNotifier with LoggerMixin {
  /// Создаёт экземпляр [PrintersFinder].
  ///
  /// [posPrintersManager] — API для взаимодействия с принтерами.
  PrintersFinder({required PosPrintersManager posPrintersManager})
    : _api = posPrintersManager;

  /// API для поиска принтеров.
  final PosPrintersManager _api;

  /// Список найденных принтеров.
  final List<PrinterConnectionParamsDTO> _foundPrinters = [];

  /// Флаг активного поиска.
  bool _isSearching = false;

  /// Подписка на стрим обнаруженных принтеров.
  StreamSubscription<PrinterConnectionParamsDTO>? _searchSubscription;

  /// Флаг, указывающий что объект был disposed.
  bool _isDisposed = false;

  @override
  String get loggerName => 'PrintersFinder';

  /// Возвращает true, если поиск активен.
  bool get isSearching => _isSearching;

  /// Возвращает неизменяемый список найденных принтеров.
  List<PrinterConnectionParamsDTO> get foundPrinters =>
      List.unmodifiable(_foundPrinters);

  /// Запускает поиск принтеров с фильтрацией по типу.
  ///
  /// [printer] — принтер, определяющий фильтр поиска.
  /// Фильтр берётся из настроек обработчика принтера.
  ///
  /// Поиск автоматически останавливается при завершении или ошибке.
  /// Повторный вызов во время активного поиска игнорируется.
  Future<void> findPrinters({required PosPrinter printer}) async {
    if (_isDisposed) {
      logger.warning('Cannot start search: PrintersFinder is disposed');
      return;
    }

    if (_isSearching) {
      logger.debug('Search already in progress, ignoring');
      return;
    }

    logger.info(
      'Starting printer discovery',
      data: {'filter': printer.handler.settings.discoveryFilter.toString()},
    );

    _isSearching = true;
    _foundPrinters.clear();
    notifyListeners();

    // Отменяем предыдущую подписку, если есть
    await _searchSubscription?.cancel();
    _searchSubscription = null;

    try {
      final stream = _api.findPrinters(
        filter: printer.handler.settings.discoveryFilter,
      );

      _searchSubscription = stream.listen(
        _onPrinterDiscovered,
        onDone: _onSearchComplete,
        onError: _onSearchError,
        cancelOnError: true,
      );

      // Ожидаем завершения процесса обнаружения
      _api.awaitDiscoveryComplete().catchError((e, st) {
        if (_isSearching && !_isDisposed) {
          logger.warning(
            'Discovery completion error',
            error: e,
            stackTrace: st,
          );
          _isSearching = false;
          notifyListeners();
        }
      });
    } catch (e, st) {
      logger.error('Failed to start discovery', error: e, stackTrace: st);
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Обработчик обнаружения нового принтера.
  void _onPrinterDiscovered(PrinterConnectionParamsDTO discoveredPrinter) {
    if (_isDisposed) return;

    final exists = _foundPrinters.any((p) => samePrinter(p, discoveredPrinter));

    if (!exists) {
      _foundPrinters.add(discoveredPrinter);
      logger.debug(
        'Printer discovered',
        data: {
          'id': discoveredPrinter.id,
          'type': discoveredPrinter.connectionType.name,
          'total': _foundPrinters.length,
        },
      );
      notifyListeners();
    }
  }

  /// Обработчик завершения поиска.
  void _onSearchComplete() {
    if (_isDisposed) return;

    logger.info('Discovery completed', data: {'found': _foundPrinters.length});

    _isSearching = false;
    _searchSubscription = null;
    notifyListeners();
  }

  /// Обработчик ошибки поиска.
  void _onSearchError(Object error, StackTrace stackTrace) {
    if (_isDisposed) return;

    logger.error('Discovery error', error: error, stackTrace: stackTrace);

    _isSearching = false;
    _searchSubscription = null;
    notifyListeners();
  }

  /// Останавливает активный поиск принтеров.
  ///
  /// Безопасно вызывать, даже если поиск не активен.
  Future<void> stopSearch() async {
    if (!_isSearching) return;

    logger.info('Stopping printer discovery');

    await _searchSubscription?.cancel();
    _searchSubscription = null;
    _isSearching = false;
    notifyListeners();
  }

  /// Удаляет принтер из списка найденных.
  ///
  /// [printer] — принтер для удаления.
  void removePrinter(PrinterConnectionParamsDTO printer) {
    final initialLength = _foundPrinters.length;
    _foundPrinters.removeWhere((p) => samePrinter(p, printer));

    if (_foundPrinters.length < initialLength) {
      logger.debug('Removed printer from found list', data: {'id': printer.id});
      notifyListeners();
    }
  }

  /// Добавляет принтер в список найденных.
  ///
  /// [printer] — принтер для добавления.
  /// Дубликаты игнорируются.
  void addPrinter(PrinterConnectionParamsDTO printer) {
    final exists = _foundPrinters.any((p) => samePrinter(p, printer));

    if (!exists) {
      _foundPrinters.add(printer);
      logger.debug('Added printer to found list', data: {'id': printer.id});
      notifyListeners();
    }
  }

  /// Сравнивает два принтера по ID.
  ///
  /// ID может быть USB-путём или IP:port в зависимости от типа подключения.
  bool samePrinter(PrinterConnectionParamsDTO a, PrinterConnectionParamsDTO b) {
    return a.id == b.id;
  }

  /// Очищает список найденных принтеров.
  void clearFoundPrinters() {
    if (_foundPrinters.isEmpty) return;

    logger.debug('Clearing found printers list');
    _foundPrinters.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    logger.debug('Disposing PrintersFinder');
    _isDisposed = true;
    _searchSubscription?.cancel();
    _searchSubscription = null;
    _foundPrinters.clear();
    super.dispose();
  }
}

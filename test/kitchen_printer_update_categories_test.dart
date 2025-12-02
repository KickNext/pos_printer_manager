import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Тестовая реализация репозитория в памяти.
class _InMemoryRepo implements PrinterConfigRepository {
  final List<PrinterConfig> _configs = [];

  @override
  Future<List<PrinterConfig>> loadConfigs() async => List.from(_configs);

  @override
  Future<void> saveConfigs(List<PrinterConfig> configs) async {
    _configs
      ..clear()
      ..addAll(configs);
  }

  @override
  Future<PrinterConfig?> findById(String id) async {
    return _configs.where((c) => c.id == id).firstOrNull;
  }

  @override
  Future<void> upsert(PrinterConfig config) async {
    final index = _configs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      _configs[index] = config;
    } else {
      _configs.add(config);
    }
  }

  @override
  Future<bool> deleteById(String id) async {
    final initialLength = _configs.length;
    _configs.removeWhere((c) => c.id == id);
    return _configs.length < initialLength;
  }

  @override
  Future<bool> exists(String id) async {
    return _configs.any((c) => c.id == id);
  }

  @override
  Future<int> count() async => _configs.length;

  @override
  Future<void> clear() async => _configs.clear();
}

class _Harness extends StatefulWidget {
  final PrintersManager manager;
  final List<CategoryForPrinter> initial;
  final void Function(KitchenPrinterSettings settings)? onSettingsReady;
  final VoidCallback? onSettingsChanged;

  const _Harness({
    required this.manager,
    required this.initial,
    this.onSettingsReady,
    this.onSettingsChanged,
  });

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late KitchenPrinterSettings settings;

  @override
  void initState() {
    super.initState();
    settings = KitchenPrinterSettings(
      initConnectionParams: null,
      onSettingsChanged: () async {
        setState(() {});
        widget.onSettingsChanged?.call();
      },
      categories: List<CategoryForPrinter>.from(widget.initial),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSettingsReady?.call(settings);
    });
  }

  @override
  Widget build(BuildContext context) {
    final handler = KitchenPrinterHandler(
      settings: settings,
      manager: widget.manager,
    );
    return MaterialApp(
      home: Scaffold(body: Column(children: handler.customWidgets)),
    );
  }
}

CategoryForPrinter _cat(String id, String name, Color color) =>
    CategoryForPrinter(id: id, displayName: name, color: color);

void main() {
  group('KitchenPrinterHandler.customWidgets Update Categories', () {
    testWidgets('returns SAME list instance: should NOT clear existing items', (
      tester,
    ) async {
      // Arrange
      final manager = PrintersManager(repository: _InMemoryRepo());
      await manager.init(
        getCategoriesFunction: ({required currentCategories}) async {
          // emulate returning the same instance user passed in
          return currentCategories;
        },
      );

      final initial = <CategoryForPrinter>[
        _cat('1', 'Hot', Colors.red),
        _cat('2', 'Cold', Colors.blue),
      ];

      int settingsChanged = 0;
      late KitchenPrinterSettings settings;

      await tester.pumpWidget(
        _Harness(
          manager: manager,
          initial: initial,
          onSettingsReady: (s) => settings = s,
          onSettingsChanged: () => settingsChanged++,
        ),
      );

      await tester.pumpAndSettle();

      // Sanity
      expect(find.byType(Chip), findsNWidgets(2));
      expect(settings.categories.length, 2);

      // Act
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Update Categories'),
      );
      await tester.pumpAndSettle();

      // Assert: list should remain intact (bug repro would make it 0)
      expect(
        settings.categories.length,
        2,
        reason:
            'Categories must not be cleared if same list instance is returned',
      );
      expect(find.byType(Chip), findsNWidgets(2));
      expect(settingsChanged, 1);
    });

    testWidgets('returns NEW list instance: should replace categories', (
      tester,
    ) async {
      // Arrange
      final manager = PrintersManager(repository: _InMemoryRepo());
      final newList = <CategoryForPrinter>[_cat('3', 'Drinks', Colors.green)];
      await manager.init(
        getCategoriesFunction: ({required currentCategories}) async {
          // emulate returning a different list instance
          return List<CategoryForPrinter>.from(newList);
        },
      );

      final initial = <CategoryForPrinter>[
        _cat('1', 'Hot', Colors.red),
        _cat('2', 'Cold', Colors.blue),
      ];

      int settingsChanged = 0;
      late KitchenPrinterSettings settings;
      await tester.pumpWidget(
        _Harness(
          manager: manager,
          initial: initial,
          onSettingsReady: (s) => settings = s,
          onSettingsChanged: () => settingsChanged++,
        ),
      );
      await tester.pumpAndSettle();

      // Sanity
      expect(find.byType(Chip), findsNWidgets(2));
      expect(settings.categories.length, 2);

      // Act
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Update Categories'),
      );
      await tester.pumpAndSettle();

      // Assert: list replaced with newList
      expect(settings.categories.length, newList.length);
      expect(settings.categories.first.id, '3');
      expect(find.byType(Chip), findsNWidgets(1));
      expect(settingsChanged, 1);
    });
  });
}

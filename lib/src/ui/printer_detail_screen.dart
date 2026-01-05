import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Короткий алиас для доступа к локализации принтер-менеджера.
typedef _L = PrinterManagerL10n;

/// Screen for viewing and configuring a single printer.
///
/// Provides a comprehensive interface for:
/// - Viewing printer information and status
/// - Configuring connection (USB/Network)
/// - Managing USB permissions
/// - Running diagnostics and test prints
/// - Plugin-specific settings
/// - Removing the printer
class PrinterDetailsScreen extends StatefulWidget {
  /// Creates a printer details screen.
  const PrinterDetailsScreen({super.key, required this.printer});

  /// The printer to display and configure.
  final PosPrinter printer;

  @override
  State<PrinterDetailsScreen> createState() => _PrinterDetailsScreenState();
}

class _PrinterDetailsScreenState extends State<PrinterDetailsScreen> {
  @override
  void initState() {
    super.initState();
    widget.printer.handler.manager.addListener(_update);
  }

  /// Rebuilds UI when printer state changes.
  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.printer.handler.manager.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = _L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.printerDetails)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const gap = 16.0;
          final isThreeColumns = width >= 1200;
          final isTwoColumns = !isThreeColumns && width >= 900;

          // Build section widgets
          // PrinterHeaderOrganism теперь объединяет информацию и диагностику
          final infoSection = PrinterHeaderOrganism(
            printer: widget.printer,
            onRename: _showRenameDialog,
          );

          final connectionSection = ConnectionConfigOrganism(
            printer: widget.printer,
            onConnectionChanged: () => setState(() {}),
          );

          final hasPlugins = widget.printer.handler.customWidgets.isNotEmpty;
          final pluginsSection = _PluginSettingsCard(printer: widget.printer);

          final dangerSection = DangerZoneCard(onRemove: _confirmAndRemove);

          /// Helper to build a column of widgets with consistent spacing.
          Widget buildColumn(List<Widget> children) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: gap),
              ],
            ],
          );

          // Responsive layout - убрали diagnosticsSection, т.к. он объединён с header
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isThreeColumns
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Колонка 1: Информация о принтере
                      Expanded(child: buildColumn([infoSection])),
                      const SizedBox(width: gap),
                      // Колонка 2: Подключение
                      Expanded(child: buildColumn([connectionSection])),
                      const SizedBox(width: gap),
                      // Колонка 3: Плагины и удаление
                      Expanded(
                        child: buildColumn([
                          if (hasPlugins) pluginsSection,
                          dangerSection,
                        ]),
                      ),
                    ],
                  )
                : isTwoColumns
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Колонка 1: Информация
                      Expanded(child: buildColumn([infoSection])),
                      const SizedBox(width: gap),
                      // Колонка 2: Подключение, плагины, удаление
                      Expanded(
                        child: buildColumn([
                          connectionSection,
                          if (hasPlugins) pluginsSection,
                          dangerSection,
                        ]),
                      ),
                    ],
                  )
                // Одна колонка для мобильных устройств
                : buildColumn([
                    infoSection,
                    connectionSection,
                    if (hasPlugins) pluginsSection,
                    dangerSection,
                  ]),
          );
        },
      ),
    );
  }

  /// Shows the rename dialog.
  Future<void> _showRenameDialog() async {
    final l = _L.of(context);
    final controller = TextEditingController(text: widget.printer.config.name);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.renamePrinter),
        content: Form(
          key: formKey,
          child: ValidatedInputMolecule(
            label: l.printerName,
            controller: controller,
            required: true,
            maxLength: 50,
            prefixIcon: Icons.label,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l.pleaseEnterName;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: Text(l.save),
          ),
        ],
      ),
    );

    if (result != null &&
        result.isNotEmpty &&
        result != widget.printer.config.name) {
      widget.printer.updateName(result);
      setState(() {});
    }
  }

  /// Shows confirmation dialog and removes printer if confirmed.
  Future<void> _confirmAndRemove() async {
    final l = _L.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: ConfirmationDialogMolecule(
          icon: Icons.delete_forever,
          iconColor: Theme.of(context).colorScheme.error,
          title: l.removePrinterQuestion,
          message: l.removePrinterConfirmation,
          confirmLabel: l.remove,
          onConfirm: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
          isDestructive: true,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      unawaited(
        widget.printer.handler.manager.removePosPrinter(widget.printer.id),
      );
      Navigator.of(context).pop();
    }
  }
}

/// Card for plugin-specific settings.
/// Карточка дополнительных настроек, специфичных для типа принтера.
/// Отображается только если есть кастомные виджеты от плагина.
class _PluginSettingsCard extends StatelessWidget {
  final PosPrinter printer;

  const _PluginSettingsCard({required this.printer});

  @override
  Widget build(BuildContext context) {
    final l = _L.of(context);
    final pluginWidgets = printer.handler.customWidgets;
    if (pluginWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: PrinterIcons.sectionAdditional,
              title: l.additionalSettings,
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12, children: pluginWidgets),
          ],
        ),
      ),
    );
  }
}

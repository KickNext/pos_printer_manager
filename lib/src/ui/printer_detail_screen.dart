import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/src/ui/widgets/card_header.dart';

class PrinterDetailsScreen extends StatefulWidget {
  const PrinterDetailsScreen({super.key, required this.printer});

  final PosPrinter printer;

  @override
  State<PrinterDetailsScreen> createState() => _PrinterDetailsScreenState();
}

class _PrinterDetailsScreenState extends State<PrinterDetailsScreen> {
  @override
  void initState() {
    widget.printer.handler.manager.addListener(update);
    super.initState();
  }

  void update() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.printer.handler.manager.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          const gap = 16.0;
          final isThreeCols = w >= 1200;
          final isTwoCols = !isThreeCols && w >= 900;

          final info = PrinterInfoCard(
            printer: widget.printer,
            onRename: _showRenameDialog,
          );
          final diagnostics = DiagnosticsCard(printer: widget.printer);
          final connection = ConnectionParameters(
            printer: widget.printer,
            printerManager: widget.printer.handler.manager,
          );
          final hasPlugins = widget.printer.handler.customWidgets.isNotEmpty;
          final plugins = PluginWidgetsWrap(printer: widget.printer);
          final danger = DangerZoneCard(onRemove: _confirmAndRemove);

          Widget col(List<Widget> children) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: gap),
              ],
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                isThreeCols
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: col([info, diagnostics])),
                        const SizedBox(width: gap),
                        Expanded(child: col([connection])),
                        const SizedBox(width: gap),
                        Expanded(child: col([if (hasPlugins) plugins, danger])),
                      ],
                    )
                    : isTwoCols
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: col([info, diagnostics])),
                        const SizedBox(width: gap),
                        Expanded(
                          child: col([
                            connection,
                            if (hasPlugins) plugins,
                            danger,
                          ]),
                        ),
                      ],
                    )
                    : col([
                      info,
                      diagnostics,
                      connection,
                      if (hasPlugins) plugins,
                      danger,
                    ]),
          );
        },
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.printer.config.name);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename printer'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'New name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result != null &&
        result.isNotEmpty &&
        result != widget.printer.config.name) {
      // TODO: implement printer name change via manager/repository
      setState(() {
        // Temporary: only local, not persistent
        widget.printer.config.name = result;
      });
    }
  }

  Future<void> _confirmAndRemove() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove printer'),
            content: const Text(
              'This action will remove the printer from your list. You can add it again later. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[800],
                ),
                child: const Text('Remove'),
              ),
            ],
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

class PrinterInfoCard extends StatelessWidget {
  final PosPrinter printer;
  const PrinterInfoCard({
    super.key,
    required this.printer,
    required this.onRename,
  });

  final Function(BuildContext) onRename;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              leading: _buildStatusIcon(printer.status, size: 20),
              title: printer.config.name,
              trailing: IconButton(
                tooltip: 'Rename',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => onRename(context),
              ),
            ),
            const SizedBox(height: 8),
            Text('Type: ${printer.type.displayName}'),
            const Divider(height: 16),
            PrinterPrimaryActions(printer: printer),
          ],
        ),
      ),
    );
  }

  // Leading icon is neutral now to avoid status duplication; status is shown via StatusChip.
  Widget _buildStatusIcon(PrinterConnectionStatus status, {double size = 20}) {
    switch (status) {
      case PrinterConnectionStatus.connected:
        return Icon(Icons.check_circle, color: Colors.green, size: size);
      case PrinterConnectionStatus.error:
        return Icon(Icons.error, color: Colors.red, size: size);
      case PrinterConnectionStatus.unknown:
        return Icon(Icons.help_outline, color: Colors.grey[600], size: size);
    }
  }
}

class PrinterPrimaryActions extends StatefulWidget {
  final PosPrinter printer;
  const PrinterPrimaryActions({super.key, required this.printer});

  @override
  State<PrinterPrimaryActions> createState() => _PrinterPrimaryActionsState();
}

class _PrinterPrimaryActionsState extends State<PrinterPrimaryActions> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final printer = widget.printer;
    return OverflowBar(
      alignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed:
              _isPrinting
                  ? null
                  : () async {
                    setState(() => _isPrinting = true);
                    try {
                      // Use PosPrinter API to also capture lastError on failure
                      await printer.testConnection();
                    } finally {
                      if (mounted) setState(() => _isPrinting = false);
                    }
                  },
          icon:
              _isPrinting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.print),
          label: Text(_isPrinting ? 'Printing…' : 'Test print'),
        ),
        // No error-specific actions in the first card anymore
      ],
    );
  }
}

class DiagnosticsCard extends StatelessWidget {
  final PosPrinter printer;
  const DiagnosticsCard({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
            const CardHeader(
              leading: Icon(Icons.stacked_bar_chart, size: 20),
              title: 'Diagnostics',
            ),
            const SizedBox(height: 8),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final err = printer.lastError;
                    final status = printer.status;
                    if (!context.mounted) return;

                    String title;
                    Widget icon;
                    List<Widget> body;

                    if (err != null) {
                      title = 'Error';
                      icon = const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 24,
                      );
                      body = [
                        Text(err.message),
                        const SizedBox(height: 8),
                        Text(
                          'At: ${err.timestamp.day}/${err.timestamp.month}/${err.timestamp.year} ${err.timestamp.hour}:${err.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        if (err.details != null) ...[
                          const SizedBox(height: 8),
                          Text(err.details!),
                        ],
                        const SizedBox(height: 8),
                        const Text('What to check:'),
                        const SizedBox(height: 4),
                        const Text('• Power and cables / Wi‑Fi connectivity'),
                        const Text('• IP/MAC and port settings'),
                        const Text('• Try rebooting the printer'),
                      ];
                    } else {
                      switch (status) {
                        case PrinterConnectionStatus.connected:
                          title = 'Connected';
                          icon = const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          );
                          body = const [
                            Text(
                              'No errors recorded. The printer is considered connected.',
                            ),
                          ];
                          break;
                        case PrinterConnectionStatus.error:
                          // Should not happen when err == null, but handle gracefully
                          title = 'Error';
                          icon = const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 24,
                          );
                          body = const [Text('Printer reported error state.')];
                          break;
                        case PrinterConnectionStatus.unknown:
                          title = 'Unknown';
                          icon = Icon(
                            Icons.help_outline,
                            color: Colors.grey[700],
                            size: 24,
                          );
                          body = const [
                            Text('The printer status is not determined yet.'),
                            SizedBox(height: 8),
                            Text(
                              'Use Test print or configure connection to verify.',
                            ),
                          ];
                          break;
                      }
                    }

                    await showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: Row(
                              children: [
                                icon,
                                const SizedBox(width: 8),
                                Text(title),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: body,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Get status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DangerZoneCard extends StatelessWidget {
  final VoidCallback onRemove;
  const DangerZoneCard({super.key, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
            CardHeader(
              leading: Icon(
                Icons.warning_amber_rounded,
                color: scheme.error,
                size: 20,
              ),
              title: 'Danger zone',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Remove printer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PluginWidgetsWrap extends StatelessWidget {
  final PosPrinter printer;
  const PluginWidgetsWrap({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    final pluginWidgets = printer.handler.customWidgets;
    if (pluginWidgets.isEmpty) {
      return const SizedBox();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
            const CardHeader(
              leading: Icon(Icons.tune, size: 20),
              title: 'Additional settings',
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 12, children: pluginWidgets),
          ],
        ),
      ),
    );
  }
}

// ConnectionParameters is used directly to avoid double Cards and inconsistent margins.

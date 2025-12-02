import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// An organism component for printer discovery.
///
/// Provides a complete interface for finding and selecting printers
/// with clear progress indication and empty state handling.
///
/// Example usage:
/// ```dart
/// PrinterDiscoveryOrganism(
///   printer: _printer,
///   onPrinterSelected: (params) => _connectPrinter(params),
///   onCancel: () => Navigator.pop(context),
/// )
/// ```
class PrinterDiscoveryOrganism extends StatefulWidget {
  /// The printer to configure.
  final PosPrinter printer;

  /// Callback when a printer is selected.
  final ValueChanged<PrinterConnectionParamsDTO> onPrinterSelected;

  /// Callback when discovery is cancelled.
  final VoidCallback? onCancel;

  /// Creates a printer discovery organism widget.
  const PrinterDiscoveryOrganism({
    super.key,
    required this.printer,
    required this.onPrinterSelected,
    this.onCancel,
  });

  @override
  State<PrinterDiscoveryOrganism> createState() =>
      _PrinterDiscoveryOrganismState();
}

class _PrinterDiscoveryOrganismState extends State<PrinterDiscoveryOrganism> {
  PrintersFinder get _finder => widget.printer.handler.manager.finder;

  bool get _isSearching => _finder.isSearching;

  List<PrinterConnectionParamsDTO> get _foundPrinters => _finder.foundPrinters;

  @override
  void initState() {
    super.initState();
    _finder.addListener(_onPrintersChanged);
    _startSearch();
  }

  @override
  void dispose() {
    _finder.removeListener(_onPrintersChanged);
    super.dispose();
  }

  void _onPrintersChanged() {
    if (mounted) setState(() {});
  }

  void _startSearch() {
    _finder.findPrinters(printer: widget.printer);
  }

  ConnectionType _getConnectionType(PosPrinterConnectionType type) {
    switch (type) {
      case PosPrinterConnectionType.usb:
        return ConnectionType.usb;
      case PosPrinterConnectionType.network:
        return ConnectionType.network;
    }
  }

  String _getPrinterDetails(PrinterConnectionParamsDTO printer) {
    switch (printer.connectionType) {
      case PosPrinterConnectionType.usb:
        final parts = <String>[];
        if (printer.usbParams?.vendorId != null) {
          parts.add('VID: ${printer.usbParams?.vendorId}');
        }
        if (printer.usbParams?.productId != null) {
          parts.add('PID: ${printer.usbParams?.productId}');
        }
        if (printer.usbParams?.serialNumber != null) {
          parts.add('SN: ${printer.usbParams?.serialNumber}');
        }
        return parts.join(' • ');

      case PosPrinterConnectionType.network:
        final parts = <String>[];
        if (printer.networkParams?.ipAddress != null) {
          parts.add('IP: ${printer.networkParams?.ipAddress}');
        }
        if (printer.networkParams?.macAddress != null) {
          parts.add('MAC: ${printer.networkParams?.macAddress}');
        }
        return parts.join(' • ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: isSmallScreen ? mediaQuery.size.height * 0.9 : 700,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Printers',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isSearching
                              ? 'Searching for printers...'
                              : 'Found ${_foundPrinters.length} printer(s)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress indicator
              if (_isSearching)
                LinearProgressIndicator(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                )
              else
                const Divider(height: 4, thickness: 1),

              const SizedBox(height: 16),

              // Printers list
              Expanded(child: _buildPrintersList()),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSearching ? null : _startSearch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrintersList() {
    if (_foundPrinters.isEmpty) {
      if (_isSearching) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Text('Scanning network and USB...'),
            ],
          ),
        );
      }
      return EmptyState(
        icon: PrinterIcons.unknown,
        title: 'No Printers Found',
        message:
            'Make sure your printer is powered on and connected to the same network or via USB.',
        action: ActionButton(
          label: 'Search Again',
          icon: PrinterIcons.refresh,
          onPressed: _startSearch,
          variant: ActionButtonVariant.secondary,
        ),
      );
    }

    return ListView.separated(
      itemCount: _foundPrinters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final printer = _foundPrinters[index];
        return DiscoveredPrinterMolecule(
          name: printer.displayName,
          connectionType: _getConnectionType(printer.connectionType),
          details: _getPrinterDetails(printer),
          onConnect: () => widget.onPrinterSelected(printer),
        );
      },
    );
  }
}

/// An organism component for printer list display.
///
/// Displays a list of configured printers with add functionality.
///
/// Example usage:
/// ```dart
/// PrinterListOrganism(
///   printerManager: _printerManager,
///   onPrinterTap: (printer) => _navigateToDetails(printer),
///   onAddPrinter: () => _showAddPrinterDialog(),
/// )
/// ```
class PrinterListOrganism extends StatelessWidget {
  /// The printer manager.
  final PrintersManager printerManager;

  /// Callback when a printer is tapped.
  final ValueChanged<PosPrinter> onPrinterTap;

  /// Callback when add printer is pressed.
  final VoidCallback? onAddPrinter;

  /// Creates a printer list organism widget.
  const PrinterListOrganism({
    super.key,
    required this.printerManager,
    required this.onPrinterTap,
    this.onAddPrinter,
  });

  @override
  Widget build(BuildContext context) {
    final printers = printerManager.printers;

    if (printers.isEmpty && !printerManager.canAddPrinter) {
      return const EmptyState(
        icon: PrinterIcons.unknown,
        title: 'No Printers Available',
        message: 'Maximum number of printers reached.',
      );
    }

    if (printers.isEmpty) {
      return EmptyState(
        icon: PrinterIcons.unknown,
        title: 'No Printers Configured',
        message: 'Add a printer to get started.',
        action: onAddPrinter != null
            ? ActionButton(
                label: 'Add Printer',
                icon: PrinterIcons.add,
                onPressed: onAddPrinter,
                variant: ActionButtonVariant.primary,
              )
            : null,
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (printerManager.canAddPrinter && onAddPrinter != null)
          _AddPrinterButton(onPressed: onAddPrinter!),
        ...printers.map(
          (printer) => PrinterListItem(
            printer: printer,
            onTap: () => onPrinterTap(printer),
          ),
        ),
      ],
    );
  }
}

class _AddPrinterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddPrinterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add Printer',
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: const Icon(PrinterIcons.add),
        iconSize: 24,
      ),
    );
  }
}

/// A list item component for displaying a printer.
///
/// Shows printer name, type, status, and connection info.
class PrinterListItem extends StatelessWidget {
  /// The printer to display.
  final PosPrinter printer;

  /// Callback when item is tapped.
  final VoidCallback onTap;

  /// Creates a printer list item widget.
  const PrinterListItem({
    super.key,
    required this.printer,
    required this.onTap,
  });

  StatusType get _statusType {
    switch (printer.status) {
      case PrinterConnectionStatus.connected:
        return StatusType.success;
      case PrinterConnectionStatus.error:
        return StatusType.error;
      case PrinterConnectionStatus.unknown:
        return StatusType.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    printer.handler.settings.icon,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  StatusIndicator(
                    status: _statusType,
                    size: StatusIndicatorSize.small,
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Info column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    printer.config.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    printer.type.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    printer.handler.settings.connectionParams?.displayName ??
                        'Not connected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

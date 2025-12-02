import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// An organism component for printer connection configuration.
///
/// Provides a complete interface for configuring printer connection
/// including discovery, selection, USB permissions, and network settings.
///
/// Example usage:
/// ```dart
/// ConnectionConfigOrganism(
///   printer: _printer,
///   onConnectionChanged: () => setState(() {}),
/// )
/// ```
class ConnectionConfigOrganism extends StatefulWidget {
  /// The printer to configure.
  final PosPrinter printer;

  /// Callback when connection configuration changes.
  final VoidCallback? onConnectionChanged;

  /// Creates a connection config organism widget.
  const ConnectionConfigOrganism({
    super.key,
    required this.printer,
    this.onConnectionChanged,
  });

  @override
  State<ConnectionConfigOrganism> createState() =>
      _ConnectionConfigOrganismState();
}

class _ConnectionConfigOrganismState extends State<ConnectionConfigOrganism> {
  /// Флаг загрузки статуса USB прав.
  bool _isCheckingUsbPermission = false;

  /// Параметры подключения принтера.
  PrinterConnectionParamsDTO? get _params =>
      widget.printer.handler.settings.connectionParams;

  /// Проверяет, является ли текущее подключение USB.
  bool get _isUsbPrinter =>
      _params?.connectionType == PosPrinterConnectionType.usb;

  @override
  void initState() {
    super.initState();
    // Автоматически проверяем USB права при открытии экрана
    _checkUsbPermissionIfNeeded();
  }

  @override
  void didUpdateWidget(ConnectionConfigOrganism oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Перепроверяем права если изменился принтер или параметры подключения
    if (oldWidget.printer != widget.printer ||
        oldWidget.printer.handler.settings.connectionParams != _params) {
      _checkUsbPermissionIfNeeded();
    }
  }

  /// Проверяет USB права если это USB-принтер и статус unknown.
  Future<void> _checkUsbPermissionIfNeeded() async {
    if (!_isUsbPrinter) return;
    if (widget.printer.usbPermissionStatus != UsbPermissionStatus.unknown) {
      return;
    }
    if (_isCheckingUsbPermission) return;

    setState(() {
      _isCheckingUsbPermission = true;
    });

    try {
      await widget.printer.checkUsbPermission();
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUsbPermission = false;
        });
      }
    }
  }

  /// Converts PosPrinterConnectionType to ConnectionType for UI.
  ConnectionType get _connectionType {
    switch (_params?.connectionType) {
      case PosPrinterConnectionType.usb:
        return ConnectionType.usb;
      case PosPrinterConnectionType.network:
        return ConnectionType.network;
      case null:
        return ConnectionType.unknown;
    }
  }

  /// Converts UsbPermissionStatus to PermissionStatus for UI.
  PermissionStatus get _permissionStatus {
    switch (widget.printer.usbPermissionStatus) {
      case UsbPermissionStatus.granted:
        return PermissionStatus.granted;
      case UsbPermissionStatus.denied:
        return PermissionStatus.denied;
      case UsbPermissionStatus.unknown:
        return PermissionStatus.notRequested;
      case UsbPermissionStatus.notRequired:
        return PermissionStatus.notRequired;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_params == null) {
      return _NoConnectionCard(onFindPrinters: _showPrinterFinder);
    }

    final params = _params!;
    final fields = _buildConnectionFields(params);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConnectionInfoCard(
          connectionType: _connectionType,
          title: _connectionType == ConnectionType.usb
              ? 'USB Connection'
              : 'Network Connection',
          fields: fields,
          onEdit: _showPrinterFinder,
          onRemove: _disconnectPrinter,
          onNetworkSettings: _showNetworkSettings,
        ),
        // Показываем карточку USB прав только если:
        // - Это USB-принтер
        // - Права ещё не получены (denied или unknown/notRequested)
        // - Не идёт загрузка статуса
        if (_isUsbPrinter &&
            _permissionStatus != PermissionStatus.granted &&
            _permissionStatus != PermissionStatus.notRequired) ...[
          const SizedBox(height: 16),
          _UsbPermissionCard(
            status: _permissionStatus,
            onRequestPermission: _requestUsbPermission,
            deviceName: params.displayName,
            isLoading: _isCheckingUsbPermission,
          ),
        ],
      ],
    );
  }

  /// Builds connection field list based on connection type.
  List<(String, String?)> _buildConnectionFields(
    PrinterConnectionParamsDTO params,
  ) {
    List<(String, String?)> fields = [];
    switch (params.connectionType) {
      case PosPrinterConnectionType.usb:
        final usb = params.usbParams;
        fields = [
          ('Manufacturer', usb?.manufacturer),
          ('Product Name', usb?.productName),
          ('Serial Number', usb?.serialNumber),
          ('Vendor ID', usb?.vendorId.toString()),
          ('Product ID', usb?.productId.toString()),
        ];
        break;
      case PosPrinterConnectionType.network:
        final net = params.networkParams;
        fields = [
          ('IP Address', net?.ipAddress),
          ('Subnet Mask', net?.mask),
          ('Gateway', net?.gateway),
          ('MAC Address', net?.macAddress),
          ('DHCP', (net?.dhcp ?? false) ? 'Enabled' : 'Disabled'),
        ];
        break;
    }
    // Filter out null or empty values
    return fields
        .where((f) => f.$2 != null && f.$2!.trim().isNotEmpty)
        .toList();
  }

  Future<void> _showPrinterFinder() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => PrinterDiscoveryOrganism(
        printer: widget.printer,
        onPrinterSelected: (params) async {
          await widget.printer.handler.settings.updateConnectionParams(params);
          widget.printer.updateStatus(true);
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
    widget.onConnectionChanged?.call();
    if (mounted) setState(() {});
  }

  Future<void> _disconnectPrinter() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: ConfirmationDialogMolecule(
          icon: Icons.link_off,
          title: 'Disconnect Printer?',
          message:
              'This will remove the current connection settings. You can reconnect later.',
          confirmLabel: 'Disconnect',
          onConfirm: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
        ),
      ),
    );

    if (confirmed == true) {
      await widget.printer.handler.settings.updateConnectionParams(null);
      widget.printer.updateStatus(false);
      widget.onConnectionChanged?.call();
      if (mounted) setState(() {});
    }
  }

  Future<void> _showNetworkSettings() async {
    if (_params == null) return;

    await showDialog(
      context: context,
      builder: (_) => NetworkConfigDialog(
        printer: widget.printer,
        currentParams: _params!,
        printerManager: widget.printer.handler.manager,
        onConfigured: () {
          widget.onConnectionChanged?.call();
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Future<void> _requestUsbPermission() async {
    final result = await widget.printer.requestUsbPermission();

    if (!mounted) return;

    if (!result.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'USB permission denied'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'USB permission granted${result.deviceInfo != null ? ': ${result.deviceInfo}' : ''}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {});
  }
}

class _NoConnectionCard extends StatelessWidget {
  final VoidCallback onFindPrinters;

  const _NoConnectionCard({required this.onFindPrinters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PrinterIcons.noConnection,
                size: 32,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Connection',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No printer is connected. Search for available printers to configure the connection.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                label: 'Find Printers',
                icon: PrinterIcons.search,
                onPressed: onFindPrinters,
                variant: ActionButtonVariant.primary,
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionInfoCard extends StatelessWidget {
  final ConnectionType connectionType;
  final String title;
  final List<(String, String?)> fields;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onNetworkSettings;

  const _ConnectionInfoCard({
    required this.connectionType,
    required this.title,
    required this.fields,
    this.onEdit,
    this.onRemove,
    this.onNetworkSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConnectionInfoMolecule(
          connectionType: connectionType,
          title: title,
          fields: fields,
          onEdit: onEdit,
          onRemove: onRemove,
          onNetworkSettings: onNetworkSettings,
        ),
      ),
    );
  }
}

/// Карточка для отображения статуса USB прав и кнопки запроса.
///
/// Показывает текущий статус прав USB и позволяет запросить их.
class _UsbPermissionCard extends StatelessWidget {
  /// Текущий статус USB прав.
  final PermissionStatus status;

  /// Callback для запроса USB прав.
  final VoidCallback onRequestPermission;

  /// Имя устройства для контекста.
  final String? deviceName;

  /// Флаг загрузки (проверка прав в процессе).
  final bool isLoading;

  const _UsbPermissionCard({
    required this.status,
    required this.onRequestPermission,
    this.deviceName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Не показываем карточку если статус granted или notRequired
    // (эта проверка дублируется для надёжности)
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.notRequired) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: UsbPermissionMolecule(
          status: status,
          onRequestPermission: onRequestPermission,
          deviceName: deviceName,
          isRequesting: isLoading,
        ),
      ),
    );
  }
}

// ПРИМЕЧАНИЕ: PrinterDiagnosticsOrganism был удалён.
// Его функционал объединён с PrinterHeaderOrganism для устранения
// дублирования UI (тестовая печать, статус, troubleshooting tips).

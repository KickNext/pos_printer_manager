import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// A molecule component displaying printer connection status.
///
/// Combines status indicator, status text, and action buttons
/// to provide a complete status overview with actions.
///
/// Example usage:
/// ```dart
/// PrinterStatusMolecule(
///   status: StatusType.success,
///   statusText: 'Connected',
///   onTestPrint: () => _testPrint(),
///   onRefresh: () => _refreshStatus(),
/// )
/// ```
class PrinterStatusMolecule extends StatelessWidget {
  /// The current printer status.
  final StatusType status;

  /// Human-readable status text.
  final String statusText;

  /// Error message if status is error.
  final String? errorMessage;

  /// Callback for test print action.
  final VoidCallback? onTestPrint;

  /// Callback for refresh/retry action.
  final VoidCallback? onRefresh;

  /// Whether actions are in progress.
  final bool isLoading;

  /// Creates a printer status molecule widget.
  const PrinterStatusMolecule({
    super.key,
    required this.status,
    required this.statusText,
    this.errorMessage,
    this.onTestPrint,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status row
        Row(
          children: [
            StatusIndicator(status: status, size: StatusIndicatorSize.medium),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),

        // Actions
        if (onTestPrint != null || onRefresh != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onTestPrint != null)
                ActionButton(
                  label: isLoading ? 'Printing…' : 'Test Print',
                  icon: PrinterIcons.testPrint,
                  onPressed: isLoading ? null : onTestPrint,
                  isLoading: isLoading,
                  variant: ActionButtonVariant.primary,
                  size: ActionButtonSize.small,
                ),
              if (onRefresh != null && status == StatusType.error)
                ActionButton(
                  label: 'Retry',
                  icon: PrinterIcons.retry,
                  onPressed: isLoading ? null : onRefresh,
                  variant: ActionButtonVariant.secondary,
                  size: ActionButtonSize.small,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A molecule component for USB permission request.
///
/// Displays the current USB permission status with clear guidance
/// and a prominent action button to request permission.
///
/// Example usage:
/// ```dart
/// UsbPermissionMolecule(
///   status: PermissionStatus.notRequested,
///   onRequestPermission: () => _requestPermission(),
/// )
/// ```
class UsbPermissionMolecule extends StatelessWidget {
  /// The current USB permission status.
  final PermissionStatus status;

  /// Callback to request USB permission.
  final VoidCallback? onRequestPermission;

  /// Whether permission request is in progress.
  final bool isRequesting;

  /// Device name for context.
  final String? deviceName;

  /// Creates a USB permission molecule widget.
  const UsbPermissionMolecule({
    super.key,
    required this.status,
    this.onRequestPermission,
    this.isRequesting = false,
    this.deviceName,
  });

  String get _statusMessage {
    switch (status) {
      case PermissionStatus.granted:
        return 'USB permission granted. Printer is ready to use.';
      case PermissionStatus.denied:
        return 'USB permission was denied. Please grant permission to use this printer.';
      case PermissionStatus.notRequested:
        return 'USB permission is required to communicate with this printer.';
      case PermissionStatus.notRequired:
        return 'No USB permission required for network printers.';
    }
  }

  InfoBannerType get _bannerType {
    switch (status) {
      case PermissionStatus.granted:
        return InfoBannerType.success;
      case PermissionStatus.denied:
        return InfoBannerType.error;
      case PermissionStatus.notRequested:
        return InfoBannerType.warning;
      case PermissionStatus.notRequired:
        return InfoBannerType.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything for network printers
    if (status == PermissionStatus.notRequired) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Permission status banner
        InfoBanner(
          message: _statusMessage,
          icon: PrinterIcons.permissionUsb,
          type: _bannerType,
        ),

        // Action button (only show if not granted)
        if (status != PermissionStatus.granted &&
            onRequestPermission != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ActionButton(
              label: isRequesting ? 'Requesting…' : 'Grant USB Permission',
              icon: PrinterIcons.permissionRequest,
              onPressed: isRequesting ? null : onRequestPermission,
              isLoading: isRequesting,
              variant: status == PermissionStatus.denied
                  ? ActionButtonVariant.destructive
                  : ActionButtonVariant.primary,
              expanded: true,
            ),
          ),
        ],
      ],
    );
  }
}

/// A molecule component for connection information display.
///
/// Shows connection type badge and relevant connection parameters
/// in a clean, organized layout.
///
/// Example usage:
/// ```dart
/// ConnectionInfoMolecule(
///   connectionType: ConnectionType.usb,
///   title: 'USB Thermal Printer',
///   fields: [
///     ('Vendor ID', '0x0483'),
///     ('Product ID', '0x5740'),
///   ],
///   onEdit: () => _editConnection(),
///   onRemove: () => _removeConnection(),
/// )
/// ```
class ConnectionInfoMolecule extends StatelessWidget {
  /// The connection type.
  final ConnectionType connectionType;

  /// The connection/device title.
  final String title;

  /// List of field label-value pairs to display.
  final List<(String label, String? value)> fields;

  /// Callback when edit action is triggered.
  final VoidCallback? onEdit;

  /// Callback when remove action is triggered.
  final VoidCallback? onRemove;

  /// Callback when network settings action is triggered.
  final VoidCallback? onNetworkSettings;

  /// Creates a connection info molecule widget.
  const ConnectionInfoMolecule({
    super.key,
    required this.connectionType,
    required this.title,
    required this.fields,
    this.onEdit,
    this.onRemove,
    this.onNetworkSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with connection type badge
        Row(
          children: [
            ConnectionTypeBadge(connectionType: connectionType),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        if (fields.isNotEmpty) ...[
          const SizedBox(height: 24),
          // Grid of fields
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate number of columns based on width
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              return Wrap(
                spacing: 24,
                runSpacing: 16,
                children: fields.map((field) {
                  final width =
                      (constraints.maxWidth - (24 * (crossAxisCount - 1))) /
                      crossAxisCount;
                  return SizedBox(
                    width: width,
                    child: _buildField(context, field.$1, field.$2),
                  );
                }).toList(),
              );
            },
          ),
        ],

        // Actions
        if (onEdit != null ||
            onRemove != null ||
            onNetworkSettings != null) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              if (onNetworkSettings != null)
                ActionButton(
                  label: 'Network Settings',
                  icon: PrinterIcons.networkSettings,
                  onPressed: onNetworkSettings,
                  variant: ActionButtonVariant.secondary,
                  size: ActionButtonSize.small,
                  tooltip: 'Configure IP, subnet mask, gateway',
                ),
              if (onEdit != null)
                ActionButton(
                  label: 'Change',
                  icon: PrinterIcons.edit,
                  onPressed: onEdit,
                  variant: ActionButtonVariant.tertiary,
                  size: ActionButtonSize.small,
                ),
              if (onRemove != null)
                ActionButton(
                  label: 'Disconnect',
                  icon: PrinterIcons.disconnect,
                  onPressed: onRemove,
                  variant: ActionButtonVariant.destructive,
                  size: ActionButtonSize.small,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildField(BuildContext context, String label, String? value) {
    final theme = Theme.of(context);
    final hasValue = value != null && value.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasValue ? value : '-',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: hasValue
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// A molecule component for settings section.
///
/// Groups related settings with a header and organized content.
///
/// Example usage:
/// ```dart
/// SettingsSectionMolecule(
///   icon: Icons.print,
///   title: 'Print Settings',
///   children: [
///     // Settings widgets
///   ],
/// )
/// ```
class SettingsSectionMolecule extends StatelessWidget {
  /// Section icon.
  final IconData icon;

  /// Section title.
  final String title;

  /// Optional subtitle or description.
  final String? subtitle;

  /// Section content widgets.
  final List<Widget> children;

  /// Optional trailing widget for header.
  final Widget? headerTrailing;

  /// Creates a settings section molecule widget.
  const SettingsSectionMolecule({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    this.headerTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        SectionHeader(icon: icon, title: title, trailing: headerTrailing),

        // Subtitle if provided
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Content
        ...children,
      ],
    );
  }
}

/// A molecule component for discovered printer item.
///
/// Displays a discovered printer with connection info and
/// connect action.
///
/// Example usage:
/// ```dart
/// DiscoveredPrinterMolecule(
///   name: 'USB Printer',
///   connectionType: ConnectionType.usb,
///   details: 'VID: 0x0483, PID: 0x5740',
///   onConnect: () => _connect(),
/// )
/// ```
class DiscoveredPrinterMolecule extends StatelessWidget {
  /// Printer display name.
  final String name;

  /// Connection type.
  final ConnectionType connectionType;

  /// Additional details (IP, VID/PID, etc.).
  final String details;

  /// Callback when connect is pressed.
  final VoidCallback onConnect;

  /// Whether connection is in progress.
  final bool isConnecting;

  /// Creates a discovered printer molecule widget.
  const DiscoveredPrinterMolecule({
    super.key,
    required this.name,
    required this.connectionType,
    required this.details,
    required this.onConnect,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: isConnecting ? null : onConnect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Connection type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Icon(
                  PrinterIcons.forConnectionTypeUI(connectionType),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Printer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Connect action
              if (isConnecting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                FilledButton.tonal(
                  onPressed: onConnect,
                  child: const Text('Connect'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A molecule component for configured printer item.
///
/// Displays a configured printer with status, type, and connection info.
/// Designed to be consistent with [DiscoveredPrinterMolecule].
class ConfiguredPrinterMolecule extends StatelessWidget {
  /// The printer to display.
  final PosPrinter printer;

  /// Callback when item is tapped.
  final VoidCallback onTap;

  /// Creates a configured printer molecule widget.
  const ConfiguredPrinterMolecule({
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
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      printer.handler.settings.icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      fontFamily: 'monospace',
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

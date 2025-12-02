import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Permission status types for display.
enum PermissionStatus {
  /// Permission granted
  granted,

  /// Permission denied by user
  denied,

  /// Permission not yet requested
  notRequested,

  /// Permission not required (e.g., network printers)
  notRequired,
}

/// A permission badge atom component.
///
/// Displays the current permission status with an icon, color, and label.
/// Commonly used for USB permission status indication.
///
/// Example usage:
/// ```dart
/// PermissionBadge(
///   status: PermissionStatus.granted,
///   label: 'USB Permission',
/// )
/// ```
class PermissionBadge extends StatelessWidget {
  /// The current permission status.
  final PermissionStatus status;

  /// Optional custom label. If null, uses default label based on status.
  final String? label;

  /// Size of the badge.
  final PermissionBadgeSize size;

  /// Whether to show the label text.
  final bool showLabel;

  /// Creates a permission badge widget.
  const PermissionBadge({
    super.key,
    required this.status,
    this.label,
    this.size = PermissionBadgeSize.medium,
    this.showLabel = true,
  });

  /// Gets the icon for current status.
  IconData get _icon {
    switch (status) {
      case PermissionStatus.granted:
        return PrinterIcons.permissionGranted;
      case PermissionStatus.denied:
        return PrinterIcons.permissionDenied;
      case PermissionStatus.notRequested:
        return PrinterIcons.permissionRequired;
      case PermissionStatus.notRequired:
        return PrinterIcons.statusSuccess;
    }
  }

  /// Gets the color for current status.
  Color get _color {
    switch (status) {
      case PermissionStatus.granted:
        return const Color(0xFF4CAF50); // Green
      case PermissionStatus.denied:
        return const Color(0xFFF44336); // Red
      case PermissionStatus.notRequested:
        return const Color(0xFFFF9800); // Orange
      case PermissionStatus.notRequired:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Gets the default label for current status.
  String get _defaultLabel {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission Granted';
      case PermissionStatus.denied:
        return 'Permission Denied';
      case PermissionStatus.notRequested:
        return 'Permission Required';
      case PermissionStatus.notRequired:
        return 'No Permission Needed';
    }
  }

  /// Gets icon size based on badge size.
  double get _iconSize {
    switch (size) {
      case PermissionBadgeSize.small:
        return 14.0;
      case PermissionBadgeSize.medium:
        return 16.0;
      case PermissionBadgeSize.large:
        return 20.0;
    }
  }

  /// Gets font size based on badge size.
  double get _fontSize {
    switch (size) {
      case PermissionBadgeSize.small:
        return 11.0;
      case PermissionBadgeSize.medium:
        return 12.0;
      case PermissionBadgeSize.large:
        return 14.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? _defaultLabel;

    if (!showLabel) {
      return Tooltip(
        message: displayLabel,
        child: Icon(_icon, size: _iconSize, color: _color),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: _iconSize, color: _color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: _fontSize,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Size options for permission badge.
enum PermissionBadgeSize {
  /// Small badge
  small,

  /// Medium badge - default
  medium,

  /// Large badge
  large,
}

/// A connection type badge atom component.
///
/// Displays the connection type (USB, Network) with an appropriate icon.
///
/// Example usage:
/// ```dart
/// ConnectionTypeBadge(
///   connectionType: ConnectionType.usb,
/// )
/// ```
class ConnectionTypeBadge extends StatelessWidget {
  /// The connection type to display.
  final ConnectionType connectionType;

  /// Size of the badge.
  final ConnectionBadgeSize size;

  /// Whether to show the label text.
  final bool showLabel;

  /// Creates a connection type badge widget.
  const ConnectionTypeBadge({
    super.key,
    required this.connectionType,
    this.size = ConnectionBadgeSize.medium,
    this.showLabel = true,
  });

  /// Gets the icon for connection type.
  IconData get _icon {
    switch (connectionType) {
      case ConnectionType.usb:
        return PrinterIcons.connectionUsb;
      case ConnectionType.network:
        return PrinterIcons.connectionNetwork;
      case ConnectionType.bluetooth:
        return PrinterIcons.connectionBluetooth;
      case ConnectionType.unknown:
        return PrinterIcons.connectionUnknown;
    }
  }

  /// Gets the label for connection type.
  String get _label {
    switch (connectionType) {
      case ConnectionType.usb:
        return 'USB';
      case ConnectionType.network:
        return 'Network';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.unknown:
        return 'Unknown';
    }
  }

  /// Gets the color for connection type.
  Color get _color {
    switch (connectionType) {
      case ConnectionType.usb:
        return const Color(0xFF2196F3); // Blue
      case ConnectionType.network:
        return const Color(0xFF4CAF50); // Green
      case ConnectionType.bluetooth:
        return const Color(0xFF3F51B5); // Indigo
      case ConnectionType.unknown:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Gets icon size based on badge size.
  double get _iconSize {
    switch (size) {
      case ConnectionBadgeSize.small:
        return 14.0;
      case ConnectionBadgeSize.medium:
        return 16.0;
      case ConnectionBadgeSize.large:
        return 20.0;
    }
  }

  /// Gets font size based on badge size.
  double get _fontSize {
    switch (size) {
      case ConnectionBadgeSize.small:
        return 11.0;
      case ConnectionBadgeSize.medium:
        return 12.0;
      case ConnectionBadgeSize.large:
        return 14.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return Tooltip(
        message: _label,
        child: Icon(_icon, size: _iconSize, color: _color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: _iconSize, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: _fontSize,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection type options.
enum ConnectionType {
  /// USB connection
  usb,

  /// Network/WiFi connection
  network,

  /// Bluetooth connection
  bluetooth,

  /// Unknown connection type
  unknown,
}

/// Size options for connection badge.
enum ConnectionBadgeSize {
  /// Small badge
  small,

  /// Medium badge - default
  medium,

  /// Large badge
  large,
}

/// A printer type badge atom component.
///
/// Displays the printer type with an appropriate icon and label.
/// Can accept either a PrinterPOSType enum or custom string/icon.
///
/// Example usage:
/// ```dart
/// // Using PrinterPOSType enum
/// PrinterTypeBadge(printerType: PrinterPOSType.receiptPrinter)
///
/// // Using custom string and icon
/// PrinterTypeBadge.custom(
///   label: 'Receipt Printer',
///   icon: Icons.receipt_long,
/// )
/// ```
class PrinterTypeBadge extends StatelessWidget {
  /// The printer type enum (optional).
  final PrinterPOSType? _printerType;

  /// Custom label (used when printerType is null).
  final String? _customLabel;

  /// Custom icon (used when printerType is null).
  final IconData? _customIcon;

  /// Optional background color.
  final Color? backgroundColor;

  /// Creates a printer type badge from PrinterPOSType enum.
  const PrinterTypeBadge({
    super.key,
    required PrinterPOSType printerType,
    this.backgroundColor,
  }) : _printerType = printerType,
       _customLabel = null,
       _customIcon = null;

  /// Creates a printer type badge with custom label and icon.
  const PrinterTypeBadge.custom({
    super.key,
    required String label,
    required IconData icon,
    this.backgroundColor,
  }) : _printerType = null,
       _customLabel = label,
       _customIcon = icon;

  /// Gets the display label for the printer type.
  String get _label {
    if (_customLabel != null) return _customLabel;
    switch (_printerType!) {
      case PrinterPOSType.receiptPrinter:
        return 'Receipt Printer';
      case PrinterPOSType.kitchenPrinter:
        return 'Kitchen Printer';
      case PrinterPOSType.labelPrinter:
        return 'Label Printer';
      case PrinterPOSType.androBar:
        return 'AndroBar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          color: fgColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

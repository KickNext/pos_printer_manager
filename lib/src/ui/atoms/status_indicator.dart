import 'package:flutter/material.dart';
import 'package:pos_printer_manager/src/ui/atoms/printer_icons.dart';

/// Enum representing different status states for visual indicators.
///
/// Used across the application to maintain consistent status representation.
enum StatusType {
  /// Operation successful or device ready
  success,

  /// Operation failed or device has error
  error,

  /// Status unknown or not yet determined
  unknown,

  /// Operation or check in progress
  loading,

  /// Requires user attention or action
  warning,

  /// Informational state
  info,

  /// Inactive or disconnected state
  inactive,
}

/// Configuration for status indicator appearance.
///
/// Allows customization of icon, color, and label for each status type.
@immutable
class StatusConfig {
  /// The icon to display for this status.
  final IconData icon;

  /// The color for this status.
  final Color color;

  /// Optional label text for this status.
  final String? label;

  /// Creates a status configuration.
  const StatusConfig({required this.icon, required this.color, this.label});
}

/// A reusable status indicator atom component.
///
/// Displays status information with an icon and optional label.
/// Supports multiple display sizes and can be customized via [StatusConfig].
///
/// Example usage:
/// ```dart
/// StatusIndicator(
///   status: StatusType.success,
///   size: StatusIndicatorSize.medium,
/// )
/// ```
class StatusIndicator extends StatelessWidget {
  /// The current status to display.
  final StatusType status;

  /// The size of the indicator.
  final StatusIndicatorSize size;

  /// Optional custom configuration overriding defaults.
  final StatusConfig? customConfig;

  /// Whether to show the label next to the icon.
  final bool showLabel;

  /// Optional custom tooltip text.
  final String? tooltip;

  /// Creates a status indicator widget.
  const StatusIndicator({
    super.key,
    required this.status,
    this.size = StatusIndicatorSize.medium,
    this.customConfig,
    this.showLabel = false,
    this.tooltip,
  });

  /// Default configurations for each status type.
  /// Использует централизованную систему иконок PrinterIcons.
  static const Map<StatusType, StatusConfig> _defaultConfigs = {
    StatusType.success: StatusConfig(
      icon: PrinterIcons.statusSuccess,
      color: Color(0xFF4CAF50), // Colors.green
      label: 'Connected',
    ),
    StatusType.error: StatusConfig(
      icon: PrinterIcons.statusError,
      color: Color(0xFFF44336), // Colors.red
      label: 'Error',
    ),
    StatusType.unknown: StatusConfig(
      icon: PrinterIcons.statusUnknown,
      color: Color(0xFF9E9E9E), // Colors.grey
      label: 'Unknown',
    ),
    StatusType.loading: StatusConfig(
      icon: PrinterIcons.statusLoading,
      color: Color(0xFF2196F3), // Colors.blue
      label: 'Loading',
    ),
    StatusType.warning: StatusConfig(
      icon: PrinterIcons.statusWarning,
      color: Color(0xFFFF9800), // Colors.orange
      label: 'Warning',
    ),
    StatusType.info: StatusConfig(
      icon: PrinterIcons.statusInfo,
      color: Color(0xFF2196F3), // Colors.blue
      label: 'Info',
    ),
    StatusType.inactive: StatusConfig(
      icon: PrinterIcons.statusInactive,
      color: Color(0xFF757575), // Colors.grey[600]
      label: 'Inactive',
    ),
  };

  /// Gets the effective configuration for current status.
  StatusConfig get _config => customConfig ?? _defaultConfigs[status]!;

  /// Gets the icon size based on indicator size.
  double get _iconSize {
    switch (size) {
      case StatusIndicatorSize.small:
        return 16.0;
      case StatusIndicatorSize.medium:
        return 20.0;
      case StatusIndicatorSize.large:
        return 24.0;
    }
  }

  /// Gets the font size based on indicator size.
  double get _fontSize {
    switch (size) {
      case StatusIndicatorSize.small:
        return 12.0;
      case StatusIndicatorSize.medium:
        return 14.0;
      case StatusIndicatorSize.large:
        return 16.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final tooltipText = tooltip ?? config.label ?? status.name;

    Widget indicator;

    // Special handling for loading state with animation
    if (status == StatusType.loading) {
      indicator = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(config.color),
        ),
      );
    } else {
      indicator = Icon(config.icon, size: _iconSize, color: config.color);
    }

    // Add label if requested
    if (showLabel && config.label != null) {
      indicator = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(width: 6),
          Text(
            config.label!,
            style: TextStyle(
              fontSize: _fontSize,
              color: config.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // Wrap with tooltip
    return Tooltip(message: tooltipText, child: indicator);
  }
}

/// Size options for status indicator.
enum StatusIndicatorSize {
  /// Small size (16px icon)
  small,

  /// Medium size (20px icon) - default
  medium,

  /// Large size (24px icon)
  large,
}

/// Extension to convert PrinterConnectionStatus to StatusType.
extension PrinterStatusToStatusType on StatusType {
  /// Creates StatusType from a boolean connection state.
  static StatusType fromConnectionState(bool isConnected) {
    return isConnected ? StatusType.success : StatusType.error;
  }
}

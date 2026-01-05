import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Короткий алиас для доступа к локализации принтер-менеджера.
typedef _L = PrinterManagerL10n;

/// An empty state atom component.
///
/// Displays a centered message with an icon when there's no content to show.
/// Commonly used for empty lists, search results, or initial states.
///
/// Example usage:
/// ```dart
/// EmptyState(
///   icon: Icons.print_disabled,
///   title: 'No Printers Found',
///   message: 'Connect a printer or search for available printers.',
///   action: ActionButton(
///     label: 'Find Printers',
///     onPressed: () => _searchPrinters(),
///   ),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The title text.
  final String title;

  /// Optional description message.
  final String? message;

  /// Optional action widget (usually a button).
  final Widget? action;

  /// Size of the icon.
  final double iconSize;

  /// Icon color. If null, uses theme's disabled color.
  final Color? iconColor;

  /// Creates an empty state widget.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconSize = 64.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: effectiveIconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// A loading state atom component.
///
/// Displays a loading indicator with an optional message.
///
/// Example usage:
/// ```dart
/// LoadingState(
///   message: 'Searching for printers...',
/// )
/// ```
class LoadingState extends StatelessWidget {
  /// Optional message to display below the loader.
  final String? message;

  /// Size of the loading indicator.
  final double size;

  /// Creates a loading state widget.
  const LoadingState({super.key, this.message, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An error state atom component.
///
/// Displays an error message with an icon and optional retry action.
///
/// Example usage:
/// ```dart
/// ErrorState(
///   title: 'Connection Failed',
///   message: 'Could not connect to the printer.',
///   onRetry: () => _retryConnection(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  /// The error title.
  final String title;

  /// Optional detailed error message.
  final String? message;

  /// Optional retry callback.
  final VoidCallback? onRetry;

  /// Size of the error icon.
  final double iconSize;

  /// Creates an error state widget.
  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.iconSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: iconSize,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(_L.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A success state atom component.
///
/// Displays a success message with an icon.
///
/// Example usage:
/// ```dart
/// SuccessState(
///   title: 'Printer Connected',
///   message: 'Your printer is ready to use.',
/// )
/// ```
class SuccessState extends StatelessWidget {
  /// The success title.
  final String title;

  /// Optional success message.
  final String? message;

  /// Optional action widget.
  final Widget? action;

  /// Size of the success icon.
  final double iconSize;

  /// Creates a success state widget.
  const SuccessState({
    super.key,
    required this.title,
    this.message,
    this.action,
    this.iconSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const successColor = Color(0xFF4CAF50); // Colors.green

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: iconSize, color: successColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: successColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// An info banner atom component.
///
/// Displays an informational message in a styled container.
///
/// Example usage:
/// ```dart
/// InfoBanner(
///   message: 'USB printers require permission on Android.',
///   icon: Icons.info_outline,
/// )
/// ```
class InfoBanner extends StatelessWidget {
  /// The message to display.
  final String message;

  /// Optional icon. Defaults to info icon.
  final IconData icon;

  /// The type of banner (info, warning, error, success).
  final InfoBannerType type;

  /// Whether the banner can be dismissed.
  final bool dismissible;

  /// Callback when banner is dismissed.
  final VoidCallback? onDismiss;

  /// Creates an info banner widget.
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.type = InfoBannerType.info,
    this.dismissible = false,
    this.onDismiss,
  });

  Color get _backgroundColor {
    switch (type) {
      case InfoBannerType.info:
        return const Color(0xFFE3F2FD); // Blue[50]
      case InfoBannerType.warning:
        return const Color(0xFFFFF3E0); // Orange[50]
      case InfoBannerType.error:
        return const Color(0xFFFFEBEE); // Red[50]
      case InfoBannerType.success:
        return const Color(0xFFE8F5E9); // Green[50]
    }
  }

  Color get _iconColor {
    switch (type) {
      case InfoBannerType.info:
        return const Color(0xFF2196F3); // Blue
      case InfoBannerType.warning:
        return const Color(0xFFFF9800); // Orange
      case InfoBannerType.error:
        return const Color(0xFFF44336); // Red
      case InfoBannerType.success:
        return const Color(0xFF4CAF50); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: _iconColor.withValues(alpha: 0.87),
              ),
            ),
          ),
          if (dismissible)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: _iconColor),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// Type options for info banner.
enum InfoBannerType {
  /// Informational message
  info,

  /// Warning message
  warning,

  /// Error message
  error,

  /// Success message
  success,
}

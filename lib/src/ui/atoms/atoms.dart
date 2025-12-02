/// Atomic UI components - the smallest, indivisible UI building blocks.
///
/// This library exports all atom-level components used throughout
/// the pos_printer_manager UI. Atoms are simple, stateless (or minimally
/// stateful) widgets that serve as the foundation for more complex
/// molecules and organisms.
///
/// ## Components:
///
/// ### Icons
/// - [PrinterIcons] - Centralized icon system for consistent UI
///
/// ### Status & Indicators
/// - [StatusIndicator] - Displays connection/operation status
/// - [PermissionBadge] - Shows permission status (USB, etc.)
/// - [ConnectionTypeBadge] - Displays connection type (USB, Network)
/// - [PrinterTypeBadge] - Shows printer type with icon
///
/// ### Buttons
/// - [ActionButton] - Customizable action button with variants
///
/// ### Labels & Information
/// - [IconLabel] - Icon with label text
/// - [InfoField] - Label-value information field
/// - [SectionHeader] - Section header with icon and title
///
/// ### States
/// - [EmptyState] - Empty content placeholder
/// - [LoadingState] - Loading indicator with message
/// - [ErrorState] - Error display with retry option
/// - [SuccessState] - Success display with message
/// - [InfoBanner] - Informational banner message
///
/// Example usage:
/// ```dart
/// import 'package:pos_printer_manager/src/ui/atoms/atoms.dart';
///
/// Icon(PrinterIcons.forType(PrinterPOSType.kitchenPrinter))
/// StatusIndicator(status: StatusType.success)
/// ActionButton(label: 'Connect', onPressed: _connect)
/// ```
library;

export 'action_button.dart';
export 'badges.dart';
export 'icon_label.dart';
export 'printer_icons.dart';
export 'states.dart';
export 'status_indicator.dart';

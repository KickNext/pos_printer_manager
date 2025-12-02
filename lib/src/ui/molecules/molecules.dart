/// Molecular UI components - composed from atoms.
///
/// This library exports all molecule-level components used throughout
/// the pos_printer_manager UI. Molecules are composed of atoms and
/// other molecules, representing more complex UI patterns.
///
/// ## Components:
///
/// ### Printer Components
/// - [PrinterStatusMolecule] - Status display with actions
/// - [UsbPermissionMolecule] - USB permission request UI
/// - [ConnectionInfoMolecule] - Connection details display
/// - [SettingsSectionMolecule] - Grouped settings section
/// - [DiscoveredPrinterMolecule] - Found printer item
///
/// ### Wizard Components
/// - [WizardStepperMolecule] - Multi-step progress indicator
/// - [PrinterTypeSelectionMolecule] - Printer type selector
/// - [ConfirmationDialogMolecule] - Confirmation dialog content
/// - [ValidatedInputMolecule] - Input with validation
///
/// Example usage:
/// ```dart
/// import 'package:pos_printer_manager/src/ui/molecules/molecules.dart';
///
/// PrinterStatusMolecule(
///   status: StatusType.success,
///   statusText: 'Connected',
/// )
/// ```
library;

export 'printer_molecules.dart';
export 'wizard_molecules.dart';

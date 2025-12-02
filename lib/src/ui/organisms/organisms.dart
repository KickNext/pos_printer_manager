/// Organism UI components - complex composed components.
///
/// This library exports all organism-level components used throughout
/// the pos_printer_manager UI. Organisms are composed of molecules
/// and atoms to create complex, self-contained UI sections.
///
/// ## Components:
///
/// ### Setup & Configuration
/// - [PrinterSetupWizard] - Multi-step printer creation wizard
/// - [ConnectionConfigOrganism] - Connection configuration panel
/// - [PrinterHeaderOrganism] - Printer info with status and quick actions
/// - [DangerZoneCard] - Destructive actions section
///
/// ### Discovery & Lists
/// - [PrinterDiscoveryOrganism] - Printer search dialog
/// - [PrinterListOrganism] - Printer list display
/// - [PrinterListItem] - Individual printer card
///
/// Example usage:
/// ```dart
/// import 'package:pos_printer_manager/src/ui/organisms/organisms.dart';
///
/// PrinterSetupWizard(
///   printerManager: manager,
///   onComplete: (printer) => print('Created: ${printer.config.name}'),
/// )
/// ```
library;

export 'connection_config_organism.dart';
export 'network_config_dialog.dart';
export 'printer_detail_organisms.dart';
export 'printer_list_organism.dart';
export 'printer_setup_wizard.dart';

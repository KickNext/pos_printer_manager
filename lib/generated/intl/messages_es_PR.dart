// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es_PR locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es_PR';

  static String m0(connectionType) =>
      "Los parámetros de conexión están configurados (${connectionType}).";

  static String m1(error) => "No se pudo verificar el permiso USB: ${error}";

  static String m2(error) => "Error al crear la impresora: ${error}";

  static String m3(count) => "Se encontraron ${count} impresora(s)";

  static String m4(number) => "Impresora ${number}";

  static String m5(error) => "La prueba de impresora falló: ${error}";

  static String m6(deviceInfo) => "Permiso USB otorgado: ${deviceInfo}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addPrinter": MessageLookupByLibrary.simpleMessage("Agregar Impresora"),
    "addPrinterToStart": MessageLookupByLibrary.simpleMessage(
      "Agregue una impresora para comenzar.",
    ),
    "additionalSettings": MessageLookupByLibrary.simpleMessage(
      "Configuraciones Adicionales",
    ),
    "androBar": MessageLookupByLibrary.simpleMessage("AndroBar"),
    "androBarDescription": MessageLookupByLibrary.simpleMessage(
      "Sistema de pantalla del bar",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Atrás"),
    "bluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "change": MessageLookupByLibrary.simpleMessage("Cambiar"),
    "clearError": MessageLookupByLibrary.simpleMessage("Limpiar Error"),
    "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "configureConnectionLater": MessageLookupByLibrary.simpleMessage(
      "Puede configurar la conexión después de crearla",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "connect": MessageLookupByLibrary.simpleMessage("Conectar"),
    "connectionConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuración de Conexión",
    ),
    "connectionError": MessageLookupByLibrary.simpleMessage(
      "Error de Conexión",
    ),
    "connectionParamsConfigured": m0,
    "couldNotCheckUsbPermission": m1,
    "create": MessageLookupByLibrary.simpleMessage("Crear"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Zona de Peligro"),
    "dangerZoneDescription": MessageLookupByLibrary.simpleMessage(
      "Eliminar esta impresora borrará toda su configuración. Puede agregarla nuevamente más tarde, pero deberá reconfigurarla.",
    ),
    "dhcp": MessageLookupByLibrary.simpleMessage("DHCP"),
    "diagnosing": MessageLookupByLibrary.simpleMessage("Diagnosticando..."),
    "diagnostics": MessageLookupByLibrary.simpleMessage("Diagnósticos"),
    "diagnosticsAllPassed": MessageLookupByLibrary.simpleMessage(
      "Todas las Pruebas Pasaron",
    ),
    "diagnosticsAllPassedDescription": MessageLookupByLibrary.simpleMessage(
      "Todas las pruebas de diagnóstico pasaron exitosamente. Su impresora está configurada correctamente.",
    ),
    "diagnosticsProblemsDescription": MessageLookupByLibrary.simpleMessage(
      "Algunas pruebas de diagnóstico fallaron. Revise los problemas a continuación y siga las sugerencias para resolverlos.",
    ),
    "diagnosticsProblemsFound": MessageLookupByLibrary.simpleMessage(
      "Se Encontraron Problemas",
    ),
    "diagnosticsSomeFailed": MessageLookupByLibrary.simpleMessage(
      "Algunas pruebas de diagnóstico fallaron. Revise los problemas a continuación y siga las sugerencias para resolverlos.",
    ),
    "diagnosticsSuccessDescription": MessageLookupByLibrary.simpleMessage(
      "Todas las pruebas de diagnóstico pasaron exitosamente. Su impresora está configurada correctamente.",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Deshabilitado"),
    "disconnect": MessageLookupByLibrary.simpleMessage("Desconectar"),
    "disconnectPrinterConfirmation": MessageLookupByLibrary.simpleMessage(
      "Esto eliminará la configuración de conexión actual. Puede reconectarse más tarde.",
    ),
    "disconnectPrinterQuestion": MessageLookupByLibrary.simpleMessage(
      "¿Desconectar Impresora?",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Habilitado"),
    "failedToCreatePrinter": m2,
    "findPrinters": MessageLookupByLibrary.simpleMessage("Buscar Impresoras"),
    "foundPrinters": m3,
    "gateway": MessageLookupByLibrary.simpleMessage("Puerta de Enlace"),
    "gatewayHint": MessageLookupByLibrary.simpleMessage("192.168.1.1"),
    "grantUsbPermission": MessageLookupByLibrary.simpleMessage(
      "Otorgar Permiso USB",
    ),
    "grantUsbPermissionSuggestion": MessageLookupByLibrary.simpleMessage(
      "Otorgue el permiso USB haciendo clic en el botón \"Otorgar Permiso USB\".",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("Dirección IP"),
    "ipAddressHint": MessageLookupByLibrary.simpleMessage("192.168.1.100"),
    "ipAddressRequired": MessageLookupByLibrary.simpleMessage(
      "Se requiere dirección IP",
    ),
    "kitchenPrinter": MessageLookupByLibrary.simpleMessage(
      "Impresora de Cocina",
    ),
    "kitchenPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Para órdenes de cocina",
    ),
    "labelPrinter": MessageLookupByLibrary.simpleMessage(
      "Impresora de Etiquetas",
    ),
    "labelPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Para etiquetas de productos",
    ),
    "macAddress": MessageLookupByLibrary.simpleMessage("Dirección MAC"),
    "macAddressRequired": MessageLookupByLibrary.simpleMessage(
      "Se requiere dirección MAC para la configuración de red",
    ),
    "manufacturer": MessageLookupByLibrary.simpleMessage("Fabricante"),
    "maxPrintersReached": MessageLookupByLibrary.simpleMessage(
      "Se alcanzó el número máximo de impresoras.",
    ),
    "nameYourPrinter": MessageLookupByLibrary.simpleMessage(
      "Nombre su impresora",
    ),
    "nameYourPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Dele a su impresora un nombre descriptivo para identificarla fácilmente.",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Red"),
    "networkConnection": MessageLookupByLibrary.simpleMessage(
      "Conexión de Red",
    ),
    "networkSettings": MessageLookupByLibrary.simpleMessage(
      "Configuración de Red",
    ),
    "networkSettingsTooltip": MessageLookupByLibrary.simpleMessage(
      "Configurar IP, máscara de subred, puerta de enlace",
    ),
    "networkSettingsUpdated": MessageLookupByLibrary.simpleMessage(
      "Configuración de red actualizada exitosamente",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "noConnection": MessageLookupByLibrary.simpleMessage("Sin Conexión"),
    "noConnectionConfigured": MessageLookupByLibrary.simpleMessage(
      "No hay conexión configurada. Por favor, configure la conexión USB o de red primero.",
    ),
    "noConnectionDescription": MessageLookupByLibrary.simpleMessage(
      "No hay impresora conectada. Busque impresoras disponibles para configurar la conexión.",
    ),
    "noPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "No Se Necesita Permiso",
    ),
    "noPrintersAvailable": MessageLookupByLibrary.simpleMessage(
      "No Hay Impresoras Disponibles",
    ),
    "noPrintersConfigured": MessageLookupByLibrary.simpleMessage(
      "No Hay Impresoras Configuradas",
    ),
    "noPrintersFound": MessageLookupByLibrary.simpleMessage(
      "No Se Encontraron Impresoras",
    ),
    "noPrintersFoundDescription": MessageLookupByLibrary.simpleMessage(
      "Asegúrese de que su impresora esté encendida y conectada a la misma red o por USB.",
    ),
    "noUsbPermissionNeededMessage": MessageLookupByLibrary.simpleMessage(
      "No se requiere permiso USB para impresoras de red.",
    ),
    "notConnected": MessageLookupByLibrary.simpleMessage("No Conectada"),
    "notRequiredForNetworkPrinters": MessageLookupByLibrary.simpleMessage(
      "No requerido para impresoras de red.",
    ),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permiso Denegado",
    ),
    "permissionGranted": MessageLookupByLibrary.simpleMessage(
      "Permiso Otorgado",
    ),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Se Requiere Permiso",
    ),
    "pleaseEnterName": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingrese un nombre",
    ),
    "pleaseSelectPrinterType": MessageLookupByLibrary.simpleMessage(
      "Por favor, seleccione un tipo de impresora",
    ),
    "printerConnectivity": MessageLookupByLibrary.simpleMessage(
      "Conectividad de Impresora",
    ),
    "printerDefaultName": m4,
    "printerDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de la Impresora",
    ),
    "printerName": MessageLookupByLibrary.simpleMessage(
      "Nombre de la Impresora",
    ),
    "printerNameHint": MessageLookupByLibrary.simpleMessage(
      "ej., Display de Cocina, Impresora del Bar",
    ),
    "printerRespondedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "La impresora respondió exitosamente al comando de prueba.",
    ),
    "printerTestFailed": m5,
    "printing": MessageLookupByLibrary.simpleMessage("Imprimiendo..."),
    "productId": MessageLookupByLibrary.simpleMessage("ID de Producto"),
    "productName": MessageLookupByLibrary.simpleMessage("Nombre del Producto"),
    "readyToConnect": MessageLookupByLibrary.simpleMessage(
      "Lista para Conectar",
    ),
    "readyToConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Su impresora ha sido creada. Ahora puede configurar la conexión.",
    ),
    "readyToPrint": MessageLookupByLibrary.simpleMessage("Lista para Imprimir"),
    "receiptPrinter": MessageLookupByLibrary.simpleMessage(
      "Impresora de Recibos",
    ),
    "receiptPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Para recibos y facturas",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "remove": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "removePrinter": MessageLookupByLibrary.simpleMessage("Eliminar Impresora"),
    "removePrinterConfirmation": MessageLookupByLibrary.simpleMessage(
      "Esto eliminará la impresora y toda su configuración. Puede agregarla nuevamente más tarde.",
    ),
    "removePrinterQuestion": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar Impresora?",
    ),
    "renamePrinter": MessageLookupByLibrary.simpleMessage(
      "Renombrar Impresora",
    ),
    "requesting": MessageLookupByLibrary.simpleMessage("Solicitando..."),
    "retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "runDiagnosticsTooltip": MessageLookupByLibrary.simpleMessage(
      "Ejecutar diagnósticos completos y mostrar problemas si los hay",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "saveSettings": MessageLookupByLibrary.simpleMessage(
      "Guardar Configuración",
    ),
    "scanningNetworkAndUsb": MessageLookupByLibrary.simpleMessage(
      "Escaneando red y USB...",
    ),
    "searchAgain": MessageLookupByLibrary.simpleMessage("Buscar de Nuevo"),
    "searchingForPrinters": MessageLookupByLibrary.simpleMessage(
      "Buscando impresoras...",
    ),
    "selectPrinterType": MessageLookupByLibrary.simpleMessage(
      "Seleccione el tipo de impresora",
    ),
    "selectPrinterTypeDescription": MessageLookupByLibrary.simpleMessage(
      "Elija el tipo de impresora que desea agregar.",
    ),
    "serialNumber": MessageLookupByLibrary.simpleMessage("Número de Serie"),
    "stepName": MessageLookupByLibrary.simpleMessage("Nombre"),
    "stepType": MessageLookupByLibrary.simpleMessage("Tipo"),
    "subnetMask": MessageLookupByLibrary.simpleMessage("Máscara de Subred"),
    "subnetMaskHint": MessageLookupByLibrary.simpleMessage("255.255.255.0"),
    "suggestionCheckConnection": MessageLookupByLibrary.simpleMessage(
      "Verifique la conexión y configuración de la impresora.",
    ),
    "suggestionCheckNetworkAndIp": MessageLookupByLibrary.simpleMessage(
      "Verifique la conexión de red y la dirección IP de la impresora.",
    ),
    "suggestionCheckPowerAndConnection": MessageLookupByLibrary.simpleMessage(
      "Verifique que la impresora esté encendida y conectada. Intente reconectar.",
    ),
    "suggestionGrantPermission": MessageLookupByLibrary.simpleMessage(
      "Otorgue el permiso USB e intente nuevamente.",
    ),
    "suggestionGrantUsbPermission": MessageLookupByLibrary.simpleMessage(
      "Otorgue el permiso USB e intente nuevamente.",
    ),
    "suggestionLoadPaper": MessageLookupByLibrary.simpleMessage(
      "Cargue papel en la impresora.",
    ),
    "suggestionVerifyPrinterConnected": MessageLookupByLibrary.simpleMessage(
      "Verifique que la impresora esté conectada y visible para el dispositivo.",
    ),
    "testPrint": MessageLookupByLibrary.simpleMessage("Prueba de Impresión"),
    "tipCheckAndroBarNetwork": MessageLookupByLibrary.simpleMessage(
      "Verifique la conectividad de red al dispositivo AndroBar",
    ),
    "tipCheckLabels": MessageLookupByLibrary.simpleMessage(
      "Asegúrese de que las etiquetas estén cargadas correctamente",
    ),
    "tipCheckPaper": MessageLookupByLibrary.simpleMessage(
      "Verifique que el papel esté cargado correctamente",
    ),
    "tipCheckPowerOn": MessageLookupByLibrary.simpleMessage(
      "Verifique que la impresora esté encendida",
    ),
    "tipNetworkConnection": MessageLookupByLibrary.simpleMessage(
      "Para Red: Verifique la conexión WiFi/Ethernet",
    ),
    "tipUsbCable": MessageLookupByLibrary.simpleMessage(
      "Para USB: Asegúrese de que el cable esté bien conectado",
    ),
    "troubleshootingTips": MessageLookupByLibrary.simpleMessage(
      "Consejos de Solución de Problemas",
    ),
    "tryReconnectingUsb": MessageLookupByLibrary.simpleMessage(
      "Intente reconectar el dispositivo USB.",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Desconocido"),
    "usb": MessageLookupByLibrary.simpleMessage("USB"),
    "usbConnection": MessageLookupByLibrary.simpleMessage("Conexión USB"),
    "usbPermission": MessageLookupByLibrary.simpleMessage("Permiso USB"),
    "usbPermissionCheck": MessageLookupByLibrary.simpleMessage("Permiso USB"),
    "usbPermissionDeniedError": MessageLookupByLibrary.simpleMessage(
      "Permiso USB denegado",
    ),
    "usbPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "El permiso USB fue denegado. Por favor, otorgue el permiso para usar esta impresora.",
    ),
    "usbPermissionGrantedDiag": MessageLookupByLibrary.simpleMessage(
      "Permiso USB otorgado.",
    ),
    "usbPermissionGrantedMessage": MessageLookupByLibrary.simpleMessage(
      "Permiso USB otorgado. La impresora está lista para usar.",
    ),
    "usbPermissionGrantedShort": MessageLookupByLibrary.simpleMessage(
      "Permiso USB otorgado.",
    ),
    "usbPermissionGrantedSuccess": MessageLookupByLibrary.simpleMessage(
      "Permiso USB otorgado",
    ),
    "usbPermissionGrantedWithDevice": m6,
    "usbPermissionNotGranted": MessageLookupByLibrary.simpleMessage(
      "Permiso USB no otorgado.",
    ),
    "usbPermissionNotRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "No se requiere permiso USB para impresoras de red.",
    ),
    "usbPermissionRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "Se requiere permiso USB para comunicarse con esta impresora.",
    ),
    "useFindPrintersButton": MessageLookupByLibrary.simpleMessage(
      "Use el botón \"Buscar Impresoras\" para configurar la conexión.",
    ),
    "useFinderToConnect": MessageLookupByLibrary.simpleMessage(
      "Use el botón \"Buscar Impresoras\" para configurar la conexión.",
    ),
    "vendorId": MessageLookupByLibrary.simpleMessage("ID de Proveedor"),
  };
}

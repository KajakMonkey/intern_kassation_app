// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get app_name => 'Intern Kassation';

  @override
  String get about_app => 'Om Appen';

  @override
  String get next => 'Næste';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nej';

  @override
  String get cancel => 'Annuller';

  @override
  String get ok => 'OK';

  @override
  String get try_again => 'Prøv igen';

  @override
  String get other => 'Andet';

  @override
  String get production_order => 'Produktionsordre';

  @override
  String get field_cannot_be_empty => 'Feltet må ikke være tomt';

  @override
  String get an_error_occurred => 'Der opstod en fejl';

  @override
  String get account_page_title => 'Konto';

  @override
  String get login_form_title => 'Log ind';

  @override
  String get username_label => 'Brugernavn';

  @override
  String get password_label => 'Adgangskode';

  @override
  String get login => 'Log ind';

  @override
  String get login_successful => 'Du er logget ind';

  @override
  String get account_page_anonymous => 'Kunne ikke hente kontooplysninger.';

  @override
  String get account_page_session_id_label => 'Session ID:';

  @override
  String get account_page_no_session => 'Der er ingen aktiv session. Log ind for at fortsætte.';

  @override
  String get logout => 'Log ud';

  @override
  String get logout_confirmation_title => 'Log ud';

  @override
  String get logout_confirmation_message => 'Er du sikker på, at du vil logge ud?';

  @override
  String get scan_use_hardware_scanner => 'Brug scanner';

  @override
  String get manual_entry => 'Indtast manuelt';

  @override
  String get enter_a_production_order => 'Indtast en produktionsordre';

  @override
  String get scan_or_manual_entry => 'Scan en stregkode eller indtast manuelt';

  @override
  String get scan_entry => 'Scan en stregkode';

  @override
  String get latest_discarded_items => 'Seneste kasserede ordre';

  @override
  String get production_order_already_discarded_recently =>
      'Denne produktionsordre er allerede blevet kasseret for nylig.';

  @override
  String get discard_again => 'Kassér igen';

  @override
  String get loading_production_order => 'Indlæser produktionsordre';

  @override
  String get scanner_reset => 'Scanner nulstillet';

  @override
  String get correct_barcode_dialog => 'Er stregkoden korrekt?';

  @override
  String get barcode_scan_error => 'Der opstod en fejl under stregkodescanning';

  @override
  String get scan_a_barcode => 'Scan en stregkode';

  @override
  String get discard_changes_title => 'Kasser ændringer';

  @override
  String get discard_changes_message => 'Er du sikker på, at du vil kassere dine ændringer?';

  @override
  String step_of(int currentStep, int totalSteps) {
    return 'Trin $currentStep af $totalSteps';
  }

  @override
  String get invalid_employee_id => 'Ugyldigt medarbejder ID';

  @override
  String get employee => 'Medarbejder';

  @override
  String get enter_employee_id => 'Indtast medarbejder ID';

  @override
  String get employee_number => 'Medarbejdernummer';

  @override
  String get confirm_employee => 'Er dette korrekt?';

  @override
  String confirm_employee_message(String employeeName, String employeeId) {
    return 'Navn: $employeeName\nMedarbejdernummer: $employeeId';
  }

  @override
  String get select_reason_for_discard => 'Vælg årsag til kassation';

  @override
  String get enter_error_code => 'Indtast en fejlkode';

  @override
  String get using_stale_reasons_warning =>
      'Bruger forældede fejlkoder. Nogle fejlkoder kan mangle. Prøv at opdatere fejlkoderne.';

  @override
  String get select_a_machine => 'Vælg en maskine';

  @override
  String get error_code_not_found => 'Fejlkode ikke fundet';

  @override
  String get error_image_max_images_exceeded =>
      'Maksimalt antal billeder overskredet. Fjern et billede for at tilføje et nyt.';

  @override
  String get error_image_removal_failed => 'Kunne ikke fjerne billedet. Prøv igen.';

  @override
  String get attach_images => 'Vedhæft billeder';

  @override
  String get take_picture => 'Tag billede';

  @override
  String get pick_from_gallery => 'Vælg fra galleri';

  @override
  String images_selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count billeder valgt',
      one: '1 billede valgt',
      zero: 'Ingen billeder valgt',
    );
    return '$_temp0';
  }

  @override
  String max_images(int max) {
    return 'Max $max billeder';
  }

  @override
  String get large_image_upload_warning => 'Bemærk: Upload af store billeder kan tage længere tid.';

  @override
  String get more_details => 'Hvis det er nødvendigt, kan du tilføje flere detaljer her';

  @override
  String get free_text_elaboration => 'Forklarende fritekst / uddybning';

  @override
  String get dev_date_picker_warning =>
      'Hvis dette er synligt i appen er det et udviklingsmiljø.\nDette burde ikke være synligt i produktionen.';

  @override
  String get overview => 'Oversigt';

  @override
  String get images_attached => 'Vedhæftede billeder';

  @override
  String get reason_for_discard => 'Årsag til kassation';

  @override
  String get code => 'Kode';

  @override
  String get description => 'Beskrivelse';

  @override
  String get machine => 'Maskine';

  @override
  String get order_information => 'Ordre Information';

  @override
  String get sales_id => 'Salgs ID';

  @override
  String get worktop => 'Plade';

  @override
  String get date => 'Dato';

  @override
  String get submit => 'Indsend';

  @override
  String get submit_discard_title => 'Indsend kassation';

  @override
  String get submit_discard_message => 'Er du sikker på, at du vil indsende denne kassation?';

  @override
  String get discard_lookup_page_title => 'Kassations opslag';

  @override
  String get enter_production_order_lookup => 'Indtast produktionsordre/Salgs ID';

  @override
  String get minimum_three_letters_or_numbers => 'Minimum 3 bogstaver eller tal';

  @override
  String get search => 'Søg';

  @override
  String get discard_lookup_no_results => 'Ingen kasserede produktionsordrer fundet for denne forespørgsel.';

  @override
  String get next_page => 'Næste side';

  @override
  String get previous_page => 'Forrige side';

  @override
  String get product_group => 'Produktgruppe';

  @override
  String get error_code => 'Fejlkode';

  @override
  String get discard_details_title => 'Kassations detaljer';

  @override
  String get username_cannot_be_empty => 'Brugernavn må ikke være tom';

  @override
  String get password_cannot_be_empty => 'Adgangskode må ikke være tom';

  @override
  String get error_failed_fetch_user_unknown => 'Der opstod en ukendt fejl under hentning af brugerdata.';

  @override
  String get error_auth_search_failed => 'Login mislykkedes. Prøv igen senere.';

  @override
  String get error_auth_server_unavailable => 'Login mislykkedes. Serveren er utilgængelig.';

  @override
  String get error_auth_unauthorized => 'Du har ikke tilladelse til at bruge denne app. Kontakt IT-afdelingen.';

  @override
  String get error_auth_invalid_credentials => 'Ugyldigt brugernavn eller adgangskode.';

  @override
  String get error_auth_account_disabled => 'Din konto er deaktiveret. Kontakt IT-afdelingen.';

  @override
  String get error_auth_refresh_token_expired => 'Din session er udløbet. Log ind igen.';

  @override
  String get error_auth_refresh_token_revoked => 'Din session er blevet tilbagekaldt. Log ind igen.';

  @override
  String get error_auth_refresh_token_missing => 'Din session er ugyldig. Log ind igen.';

  @override
  String get error_auth_refresh_token_invalid => 'Din session er ugyldig. Log ind igen.';

  @override
  String get error_auth_refresh_token_user_not_found => 'Din session blev ikke fundet. Log ind igen.';

  @override
  String get error_auth_invalid_due_to_password_change => 'Din adgangskode er blevet ændret. Log ind igen.';

  @override
  String get error_auth_invalid_for_device => 'Denne session er ikke gyldig for denne enhed. Log ind igen.';

  @override
  String get error_auth_invalid_format => 'Der opstod en fejl under behandling af login data.';

  @override
  String get error_auth_invalid_access_token =>
      'Din login session er ugyldig eller udløbet. Du burde ikke se denne fejl. Prøv at genstarte appen eller login igen.';

  @override
  String get error_employee_missing_id => 'Medarbejder ID mangler.';

  @override
  String get error_employee_not_found => 'Medarbejder ikke fundet.';

  @override
  String get error_general_unknown => 'Der opstod en ukendt fejl.';

  @override
  String get error_order_not_found => 'Produktionsordre blev ikke fundet eller er ugyldig.';

  @override
  String get error_order_unable_to_extract_worktop => 'Kunne ikke hente bordplade oplysninger fra produktionsordren.';

  @override
  String get error_order_no_images_provided =>
      'Billed upload kaldt uden vedhæftede billeder. Du burde aldrig se denne fejl.';

  @override
  String get error_order_content_type_not_supported => 'Den angivne filtype understøttes ikke.';

  @override
  String get error_order_file_too_large => 'En af de uploadede filer er for stor.';

  @override
  String get error_order_file_stream_not_available => 'Kunne ikke få adgang til den uploadede fil.';

  @override
  String get error_discarded_order_not_found => 'Kasseret ordre blev ikke fundet.';

  @override
  String get error_discarded_invalid_discarded_order_query => 'Ugyldig forespørgsel for kasseret ordre.';

  @override
  String get error_discarded_invalid_discarded_order_query_length =>
      'Forespørgselslængden for kasseret ordre er ugyldig: minimum 3 tegn som ikke er \'*\'';

  @override
  String get error_auth_unknown => 'Der opstod en ukendt login fejl.';

  @override
  String get error_auth_invalid_token => 'Ugyldig eller udløbet login. Log ind igen.';

  @override
  String get error_auth_invalid_refresh_token => 'Ugyldig eller udløbet login. Log ind igen.';

  @override
  String get error_auth_token_not_found => 'Login ikke fundet. Log ind igen.';

  @override
  String get error_auth_user_id_not_found => 'Bruger ID ikke fundet. Log ind igen.';

  @override
  String get error_validation_unknown => 'Der opstod en ukendt valideringsfejl.';

  @override
  String get error_validation_invalid_json_format => 'Ugyldigt JSON-format.';

  @override
  String get error_validation_parsing_error => 'Fejl under behandling af data.';

  @override
  String get error_validation_api_error => 'Der opstod en fejl under kommunikation med serveren.';

  @override
  String get error_validation_missing_discard_reason => 'Årsag til kassation mangler.';

  @override
  String get error_network_unknown => 'Der opstod en ukendt netværksfejl.';

  @override
  String get error_network_connection_timeout => 'Forbindelsen udløb. Tjek din internetforbindelse og prøv igen.';

  @override
  String get error_network_send_timeout =>
      'Tidsgrænsen for afsendelse af anmodningen blev overskredet. Prøv igen senere.';

  @override
  String get error_network_receive_timeout => 'Tidsgrænsen for modtagelse af svar blev overskredet. Prøv igen senere.';

  @override
  String get error_network_bad_response => 'Modtog et ugyldigt svar fra serveren. Prøv igen senere.';

  @override
  String get error_network_request_cancelled => 'Anmodningen blev annulleret. Prøv igen.';

  @override
  String get error_network_connection_error =>
      'Der kunne ikke oprettes forbindelse til serveren. Tjek din internetforbindelse og prøv igen.';

  @override
  String get error_network_bad_certificate => 'Der opstod et problem med serverens ssl certifikat. Prøv igen senere.';

  @override
  String get error_storage_unknown => 'Der opstod en ukendt lagringsfejl.';

  @override
  String get error_storage_secure_storage_read_error => 'Fejl under læsning af sikre data. Prøv igen.';

  @override
  String get error_storage_secure_storage_write_error => 'Fejl under skrivning af sikre data. Prøv igen.';

  @override
  String get error_storage_secure_storage_delete_error => 'Fejl under sletning af sikre data. Prøv igen.';

  @override
  String get error_storage_shared_prefs_read_error => 'Fejl under læsning af delte præferencer. Prøv igen.';

  @override
  String get error_storage_shared_prefs_write_error => 'Fejl under skrivning af delte præferencer. Prøv igen.';

  @override
  String get error_storage_shared_prefs_delete_error => 'Fejl under sletning af delte præferencer. Prøv igen.';

  @override
  String get error_product_invalid_product_type => 'Ugyldig produkttype angivet.';

  @override
  String get error_product_invalid_product_group => 'Der blev ikke fundet en gyldig produktgruppe.';

  @override
  String get error_product_invalid_dropdown_name => 'Der blev ikke fundet et gyldigt dropdownmenu med navn';

  @override
  String get error_product_defects_not_found => 'Der blev ikke fundet nogen produktdefekter for dette produkttype.';

  @override
  String get view_technical_details => 'Vis tekniske detaljer';

  @override
  String get view_error_details => 'Vis fejldetaljer';
}

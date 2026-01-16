import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('da')];

  /// No description provided for @app_name.
  ///
  /// In da, this message translates to:
  /// **'Intern Kassation'**
  String get app_name;

  /// No description provided for @about_app.
  ///
  /// In da, this message translates to:
  /// **'Om Appen'**
  String get about_app;

  /// No description provided for @next.
  ///
  /// In da, this message translates to:
  /// **'Næste'**
  String get next;

  /// No description provided for @yes.
  ///
  /// In da, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In da, this message translates to:
  /// **'Nej'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In da, this message translates to:
  /// **'Annuller'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In da, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @try_again.
  ///
  /// In da, this message translates to:
  /// **'Prøv igen'**
  String get try_again;

  /// No description provided for @other.
  ///
  /// In da, this message translates to:
  /// **'Andet'**
  String get other;

  /// No description provided for @production_order.
  ///
  /// In da, this message translates to:
  /// **'Produktionsordre'**
  String get production_order;

  /// No description provided for @field_cannot_be_empty.
  ///
  /// In da, this message translates to:
  /// **'Feltet må ikke være tomt'**
  String get field_cannot_be_empty;

  /// No description provided for @an_error_occurred.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en fejl'**
  String get an_error_occurred;

  /// No description provided for @account_page_title.
  ///
  /// In da, this message translates to:
  /// **'Konto'**
  String get account_page_title;

  /// No description provided for @login_form_title.
  ///
  /// In da, this message translates to:
  /// **'Log ind'**
  String get login_form_title;

  /// No description provided for @username_label.
  ///
  /// In da, this message translates to:
  /// **'Brugernavn'**
  String get username_label;

  /// No description provided for @password_label.
  ///
  /// In da, this message translates to:
  /// **'Adgangskode'**
  String get password_label;

  /// No description provided for @login.
  ///
  /// In da, this message translates to:
  /// **'Log ind'**
  String get login;

  /// No description provided for @login_successful.
  ///
  /// In da, this message translates to:
  /// **'Du er logget ind'**
  String get login_successful;

  /// No description provided for @account_page_anonymous.
  ///
  /// In da, this message translates to:
  /// **'Kunne ikke hente kontooplysninger.'**
  String get account_page_anonymous;

  /// No description provided for @account_page_session_id_label.
  ///
  /// In da, this message translates to:
  /// **'Session ID:'**
  String get account_page_session_id_label;

  /// No description provided for @account_page_no_session.
  ///
  /// In da, this message translates to:
  /// **'Der er ingen aktiv session. Log ind for at fortsætte.'**
  String get account_page_no_session;

  /// No description provided for @logout.
  ///
  /// In da, this message translates to:
  /// **'Log ud'**
  String get logout;

  /// No description provided for @logout_confirmation_title.
  ///
  /// In da, this message translates to:
  /// **'Log ud'**
  String get logout_confirmation_title;

  /// No description provided for @logout_confirmation_message.
  ///
  /// In da, this message translates to:
  /// **'Er du sikker på, at du vil logge ud?'**
  String get logout_confirmation_message;

  /// No description provided for @scan_use_hardware_scanner.
  ///
  /// In da, this message translates to:
  /// **'Brug scanner'**
  String get scan_use_hardware_scanner;

  /// No description provided for @manual_entry.
  ///
  /// In da, this message translates to:
  /// **'Indtast manuelt'**
  String get manual_entry;

  /// No description provided for @enter_a_production_order.
  ///
  /// In da, this message translates to:
  /// **'Indtast en produktionsordre'**
  String get enter_a_production_order;

  /// No description provided for @scan_or_manual_entry.
  ///
  /// In da, this message translates to:
  /// **'Scan en stregkode eller indtast manuelt'**
  String get scan_or_manual_entry;

  /// No description provided for @scan_entry.
  ///
  /// In da, this message translates to:
  /// **'Scan en stregkode'**
  String get scan_entry;

  /// No description provided for @latest_discarded_items.
  ///
  /// In da, this message translates to:
  /// **'Seneste kasserede ordre'**
  String get latest_discarded_items;

  /// No description provided for @production_order_already_discarded_recently.
  ///
  /// In da, this message translates to:
  /// **'Denne produktionsordre er allerede blevet kasseret for nylig.'**
  String get production_order_already_discarded_recently;

  /// No description provided for @discard_again.
  ///
  /// In da, this message translates to:
  /// **'Kassér igen'**
  String get discard_again;

  /// No description provided for @loading_production_order.
  ///
  /// In da, this message translates to:
  /// **'Indlæser produktionsordre'**
  String get loading_production_order;

  /// No description provided for @scanner_reset.
  ///
  /// In da, this message translates to:
  /// **'Scanner nulstillet'**
  String get scanner_reset;

  /// No description provided for @correct_barcode_dialog.
  ///
  /// In da, this message translates to:
  /// **'Er stregkoden korrekt?'**
  String get correct_barcode_dialog;

  /// No description provided for @barcode_scan_error.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en fejl under stregkodescanning'**
  String get barcode_scan_error;

  /// No description provided for @scan_a_barcode.
  ///
  /// In da, this message translates to:
  /// **'Scan en stregkode'**
  String get scan_a_barcode;

  /// No description provided for @discard_changes_title.
  ///
  /// In da, this message translates to:
  /// **'Kasser ændringer'**
  String get discard_changes_title;

  /// No description provided for @discard_changes_message.
  ///
  /// In da, this message translates to:
  /// **'Er du sikker på, at du vil kassere dine ændringer?'**
  String get discard_changes_message;

  /// No description provided for @step_of.
  ///
  /// In da, this message translates to:
  /// **'Trin {currentStep} af {totalSteps}'**
  String step_of(int currentStep, int totalSteps);

  /// No description provided for @invalid_employee_id.
  ///
  /// In da, this message translates to:
  /// **'Ugyldigt medarbejder ID'**
  String get invalid_employee_id;

  /// No description provided for @employee.
  ///
  /// In da, this message translates to:
  /// **'Medarbejder'**
  String get employee;

  /// No description provided for @enter_employee_id.
  ///
  /// In da, this message translates to:
  /// **'Indtast medarbejder ID'**
  String get enter_employee_id;

  /// No description provided for @employee_number.
  ///
  /// In da, this message translates to:
  /// **'Medarbejdernummer'**
  String get employee_number;

  /// No description provided for @confirm_employee.
  ///
  /// In da, this message translates to:
  /// **'Er dette korrekt?'**
  String get confirm_employee;

  /// No description provided for @confirm_employee_message.
  ///
  /// In da, this message translates to:
  /// **'Navn: {employeeName}\nMedarbejdernummer: {employeeId}'**
  String confirm_employee_message(String employeeName, String employeeId);

  /// No description provided for @select_reason_for_discard.
  ///
  /// In da, this message translates to:
  /// **'Vælg årsag til kassation'**
  String get select_reason_for_discard;

  /// No description provided for @enter_error_code.
  ///
  /// In da, this message translates to:
  /// **'Indtast en fejlkode'**
  String get enter_error_code;

  /// No description provided for @using_stale_reasons_warning.
  ///
  /// In da, this message translates to:
  /// **'Bruger forældede fejlkoder. Nogle fejlkoder kan mangle. Prøv at opdatere fejlkoderne.'**
  String get using_stale_reasons_warning;

  /// No description provided for @select_a_machine.
  ///
  /// In da, this message translates to:
  /// **'Vælg en maskine'**
  String get select_a_machine;

  /// No description provided for @error_code_not_found.
  ///
  /// In da, this message translates to:
  /// **'Fejlkode ikke fundet'**
  String get error_code_not_found;

  /// No description provided for @error_image_max_images_exceeded.
  ///
  /// In da, this message translates to:
  /// **'Maksimalt antal billeder overskredet. Fjern et billede for at tilføje et nyt.'**
  String get error_image_max_images_exceeded;

  /// No description provided for @error_image_removal_failed.
  ///
  /// In da, this message translates to:
  /// **'Kunne ikke fjerne billedet. Prøv igen.'**
  String get error_image_removal_failed;

  /// No description provided for @attach_images.
  ///
  /// In da, this message translates to:
  /// **'Vedhæft billeder'**
  String get attach_images;

  /// No description provided for @take_picture.
  ///
  /// In da, this message translates to:
  /// **'Tag billede'**
  String get take_picture;

  /// No description provided for @pick_from_gallery.
  ///
  /// In da, this message translates to:
  /// **'Vælg fra galleri'**
  String get pick_from_gallery;

  /// Shows how many images are selected
  ///
  /// In da, this message translates to:
  /// **'{count, plural, =0{Ingen billeder valgt} =1{1 billede valgt} other{{count} billeder valgt}}'**
  String images_selected(int count);

  /// Shows the maximum number of images that can be attached
  ///
  /// In da, this message translates to:
  /// **'Max {max} billeder'**
  String max_images(int max);

  /// No description provided for @large_image_upload_warning.
  ///
  /// In da, this message translates to:
  /// **'Bemærk: Upload af store billeder kan tage længere tid.'**
  String get large_image_upload_warning;

  /// No description provided for @more_details.
  ///
  /// In da, this message translates to:
  /// **'Hvis det er nødvendigt, kan du tilføje flere detaljer her'**
  String get more_details;

  /// No description provided for @free_text_elaboration.
  ///
  /// In da, this message translates to:
  /// **'Forklarende fritekst / uddybning'**
  String get free_text_elaboration;

  /// No description provided for @dev_date_picker_warning.
  ///
  /// In da, this message translates to:
  /// **'Hvis dette er synligt i appen er det et udviklingsmiljø.\nDette burde ikke være synligt i produktionen.'**
  String get dev_date_picker_warning;

  /// No description provided for @overview.
  ///
  /// In da, this message translates to:
  /// **'Oversigt'**
  String get overview;

  /// No description provided for @images_attached.
  ///
  /// In da, this message translates to:
  /// **'Vedhæftede billeder'**
  String get images_attached;

  /// No description provided for @reason_for_discard.
  ///
  /// In da, this message translates to:
  /// **'Årsag til kassation'**
  String get reason_for_discard;

  /// No description provided for @code.
  ///
  /// In da, this message translates to:
  /// **'Kode'**
  String get code;

  /// No description provided for @description.
  ///
  /// In da, this message translates to:
  /// **'Beskrivelse'**
  String get description;

  /// No description provided for @machine.
  ///
  /// In da, this message translates to:
  /// **'Maskine'**
  String get machine;

  /// No description provided for @order_information.
  ///
  /// In da, this message translates to:
  /// **'Ordre Information'**
  String get order_information;

  /// No description provided for @sales_id.
  ///
  /// In da, this message translates to:
  /// **'Salgs ID'**
  String get sales_id;

  /// No description provided for @worktop.
  ///
  /// In da, this message translates to:
  /// **'Plade'**
  String get worktop;

  /// No description provided for @date.
  ///
  /// In da, this message translates to:
  /// **'Dato'**
  String get date;

  /// No description provided for @submit.
  ///
  /// In da, this message translates to:
  /// **'Indsend'**
  String get submit;

  /// No description provided for @submit_discard_title.
  ///
  /// In da, this message translates to:
  /// **'Indsend kassation'**
  String get submit_discard_title;

  /// No description provided for @submit_discard_message.
  ///
  /// In da, this message translates to:
  /// **'Er du sikker på, at du vil indsende denne kassation?'**
  String get submit_discard_message;

  /// No description provided for @discard_lookup_page_title.
  ///
  /// In da, this message translates to:
  /// **'Kassations opslag'**
  String get discard_lookup_page_title;

  /// No description provided for @enter_production_order_lookup.
  ///
  /// In da, this message translates to:
  /// **'Indtast produktionsordre/Salgs ID'**
  String get enter_production_order_lookup;

  /// No description provided for @minimum_three_letters_or_numbers.
  ///
  /// In da, this message translates to:
  /// **'Minimum 3 bogstaver eller tal'**
  String get minimum_three_letters_or_numbers;

  /// No description provided for @search.
  ///
  /// In da, this message translates to:
  /// **'Søg'**
  String get search;

  /// No description provided for @discard_lookup_no_results.
  ///
  /// In da, this message translates to:
  /// **'Ingen kasserede produktionsordrer fundet for denne forespørgsel.'**
  String get discard_lookup_no_results;

  /// No description provided for @next_page.
  ///
  /// In da, this message translates to:
  /// **'Næste side'**
  String get next_page;

  /// No description provided for @previous_page.
  ///
  /// In da, this message translates to:
  /// **'Forrige side'**
  String get previous_page;

  /// No description provided for @product_group.
  ///
  /// In da, this message translates to:
  /// **'Produktgruppe'**
  String get product_group;

  /// No description provided for @error_code.
  ///
  /// In da, this message translates to:
  /// **'Fejlkode'**
  String get error_code;

  /// No description provided for @discard_details_title.
  ///
  /// In da, this message translates to:
  /// **'Kassations detaljer'**
  String get discard_details_title;

  /// No description provided for @username_cannot_be_empty.
  ///
  /// In da, this message translates to:
  /// **'Brugernavn må ikke være tom'**
  String get username_cannot_be_empty;

  /// No description provided for @password_cannot_be_empty.
  ///
  /// In da, this message translates to:
  /// **'Adgangskode må ikke være tom'**
  String get password_cannot_be_empty;

  /// No description provided for @error_failed_fetch_user_unknown.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en ukendt fejl under hentning af brugerdata.'**
  String get error_failed_fetch_user_unknown;

  /// No description provided for @error_auth_search_failed.
  ///
  /// In da, this message translates to:
  /// **'Login mislykkedes. Prøv igen senere.'**
  String get error_auth_search_failed;

  /// No description provided for @error_auth_server_unavailable.
  ///
  /// In da, this message translates to:
  /// **'Login mislykkedes. Serveren er utilgængelig.'**
  String get error_auth_server_unavailable;

  /// No description provided for @error_auth_unauthorized.
  ///
  /// In da, this message translates to:
  /// **'Du har ikke tilladelse til at bruge denne app. Kontakt IT-afdelingen.'**
  String get error_auth_unauthorized;

  /// No description provided for @error_auth_invalid_credentials.
  ///
  /// In da, this message translates to:
  /// **'Ugyldigt brugernavn eller adgangskode.'**
  String get error_auth_invalid_credentials;

  /// No description provided for @error_auth_account_disabled.
  ///
  /// In da, this message translates to:
  /// **'Din konto er deaktiveret. Kontakt IT-afdelingen.'**
  String get error_auth_account_disabled;

  /// No description provided for @error_auth_refresh_token_expired.
  ///
  /// In da, this message translates to:
  /// **'Din session er udløbet. Log ind igen.'**
  String get error_auth_refresh_token_expired;

  /// No description provided for @error_auth_refresh_token_revoked.
  ///
  /// In da, this message translates to:
  /// **'Din session er blevet tilbagekaldt. Log ind igen.'**
  String get error_auth_refresh_token_revoked;

  /// No description provided for @error_auth_refresh_token_missing.
  ///
  /// In da, this message translates to:
  /// **'Din session er ugyldig. Log ind igen.'**
  String get error_auth_refresh_token_missing;

  /// No description provided for @error_auth_refresh_token_invalid.
  ///
  /// In da, this message translates to:
  /// **'Din session er ugyldig. Log ind igen.'**
  String get error_auth_refresh_token_invalid;

  /// No description provided for @error_auth_refresh_token_user_not_found.
  ///
  /// In da, this message translates to:
  /// **'Din session blev ikke fundet. Log ind igen.'**
  String get error_auth_refresh_token_user_not_found;

  /// No description provided for @error_auth_invalid_due_to_password_change.
  ///
  /// In da, this message translates to:
  /// **'Din adgangskode er blevet ændret. Log ind igen.'**
  String get error_auth_invalid_due_to_password_change;

  /// No description provided for @error_auth_invalid_for_device.
  ///
  /// In da, this message translates to:
  /// **'Denne session er ikke gyldig for denne enhed. Log ind igen.'**
  String get error_auth_invalid_for_device;

  /// No description provided for @error_auth_invalid_format.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en fejl under behandling af login data.'**
  String get error_auth_invalid_format;

  /// No description provided for @error_auth_invalid_access_token.
  ///
  /// In da, this message translates to:
  /// **'Din login session er ugyldig eller udløbet. Du burde ikke se denne fejl. Prøv at genstarte appen eller login igen.'**
  String get error_auth_invalid_access_token;

  /// No description provided for @error_employee_missing_id.
  ///
  /// In da, this message translates to:
  /// **'Medarbejder ID mangler.'**
  String get error_employee_missing_id;

  /// No description provided for @error_employee_not_found.
  ///
  /// In da, this message translates to:
  /// **'Medarbejder ikke fundet.'**
  String get error_employee_not_found;

  /// No description provided for @error_general_unknown.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en ukendt fejl.'**
  String get error_general_unknown;

  /// No description provided for @error_order_not_found.
  ///
  /// In da, this message translates to:
  /// **'Produktionsordre blev ikke fundet eller er ugyldig.'**
  String get error_order_not_found;

  /// No description provided for @error_order_unable_to_extract_worktop.
  ///
  /// In da, this message translates to:
  /// **'Kunne ikke hente bordplade oplysninger fra produktionsordren.'**
  String get error_order_unable_to_extract_worktop;

  /// No description provided for @error_order_no_images_provided.
  ///
  /// In da, this message translates to:
  /// **'Billed upload kaldt uden vedhæftede billeder. Du burde aldrig se denne fejl.'**
  String get error_order_no_images_provided;

  /// No description provided for @error_order_content_type_not_supported.
  ///
  /// In da, this message translates to:
  /// **'Den angivne filtype understøttes ikke.'**
  String get error_order_content_type_not_supported;

  /// No description provided for @error_order_file_too_large.
  ///
  /// In da, this message translates to:
  /// **'En af de uploadede filer er for stor.'**
  String get error_order_file_too_large;

  /// No description provided for @error_order_file_stream_not_available.
  ///
  /// In da, this message translates to:
  /// **'Kunne ikke få adgang til den uploadede fil.'**
  String get error_order_file_stream_not_available;

  /// No description provided for @error_discarded_order_not_found.
  ///
  /// In da, this message translates to:
  /// **'Kasseret ordre blev ikke fundet.'**
  String get error_discarded_order_not_found;

  /// No description provided for @error_discarded_invalid_discarded_order_query.
  ///
  /// In da, this message translates to:
  /// **'Ugyldig forespørgsel for kasseret ordre.'**
  String get error_discarded_invalid_discarded_order_query;

  /// No description provided for @error_discarded_invalid_discarded_order_query_length.
  ///
  /// In da, this message translates to:
  /// **'Forespørgselslængden for kasseret ordre er ugyldig: minimum 3 tegn som ikke er \'*\''**
  String get error_discarded_invalid_discarded_order_query_length;

  /// No description provided for @error_auth_unknown.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en ukendt login fejl.'**
  String get error_auth_unknown;

  /// No description provided for @error_auth_invalid_token.
  ///
  /// In da, this message translates to:
  /// **'Ugyldig eller udløbet login. Log ind igen.'**
  String get error_auth_invalid_token;

  /// No description provided for @error_auth_invalid_refresh_token.
  ///
  /// In da, this message translates to:
  /// **'Ugyldig eller udløbet login. Log ind igen.'**
  String get error_auth_invalid_refresh_token;

  /// No description provided for @error_auth_token_not_found.
  ///
  /// In da, this message translates to:
  /// **'Login ikke fundet. Log ind igen.'**
  String get error_auth_token_not_found;

  /// No description provided for @error_auth_user_id_not_found.
  ///
  /// In da, this message translates to:
  /// **'Bruger ID ikke fundet. Log ind igen.'**
  String get error_auth_user_id_not_found;

  /// No description provided for @error_validation_unknown.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en ukendt valideringsfejl.'**
  String get error_validation_unknown;

  /// No description provided for @error_validation_invalid_json_format.
  ///
  /// In da, this message translates to:
  /// **'Ugyldigt JSON-format.'**
  String get error_validation_invalid_json_format;

  /// No description provided for @error_validation_parsing_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under behandling af data.'**
  String get error_validation_parsing_error;

  /// No description provided for @error_validation_api_error.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en fejl under kommunikation med serveren.'**
  String get error_validation_api_error;

  /// No description provided for @error_validation_missing_discard_reason.
  ///
  /// In da, this message translates to:
  /// **'Årsag til kassation mangler.'**
  String get error_validation_missing_discard_reason;

  /// No description provided for @error_network_unknown.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en ukendt netværksfejl.'**
  String get error_network_unknown;

  /// No description provided for @error_network_connection_timeout.
  ///
  /// In da, this message translates to:
  /// **'Forbindelsen udløb. Tjek din internetforbindelse og prøv igen.'**
  String get error_network_connection_timeout;

  /// No description provided for @error_network_send_timeout.
  ///
  /// In da, this message translates to:
  /// **'Tidsgrænsen for afsendelse af anmodningen blev overskredet. Prøv igen senere.'**
  String get error_network_send_timeout;

  /// No description provided for @error_network_receive_timeout.
  ///
  /// In da, this message translates to:
  /// **'Tidsgrænsen for modtagelse af svar blev overskredet. Prøv igen senere.'**
  String get error_network_receive_timeout;

  /// No description provided for @error_network_bad_response.
  ///
  /// In da, this message translates to:
  /// **'Modtog et ugyldigt svar fra serveren. Prøv igen senere.'**
  String get error_network_bad_response;

  /// No description provided for @error_network_request_cancelled.
  ///
  /// In da, this message translates to:
  /// **'Anmodningen blev annulleret. Prøv igen.'**
  String get error_network_request_cancelled;

  /// No description provided for @error_network_connection_error.
  ///
  /// In da, this message translates to:
  /// **'Der kunne ikke oprettes forbindelse til serveren. Tjek din internetforbindelse og prøv igen.'**
  String get error_network_connection_error;

  /// No description provided for @error_network_bad_certificate.
  ///
  /// In da, this message translates to:
  /// **'Der opstod et problem med serverens ssl certifikat. Prøv igen senere.'**
  String get error_network_bad_certificate;

  /// No description provided for @error_storage_unknown.
  ///
  /// In da, this message translates to:
  /// **'Der opstod en ukendt lagringsfejl.'**
  String get error_storage_unknown;

  /// No description provided for @error_storage_secure_storage_read_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under læsning af sikre data. Prøv igen.'**
  String get error_storage_secure_storage_read_error;

  /// No description provided for @error_storage_secure_storage_write_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under skrivning af sikre data. Prøv igen.'**
  String get error_storage_secure_storage_write_error;

  /// No description provided for @error_storage_secure_storage_delete_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under sletning af sikre data. Prøv igen.'**
  String get error_storage_secure_storage_delete_error;

  /// No description provided for @error_storage_shared_prefs_read_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under læsning af delte præferencer. Prøv igen.'**
  String get error_storage_shared_prefs_read_error;

  /// No description provided for @error_storage_shared_prefs_write_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under skrivning af delte præferencer. Prøv igen.'**
  String get error_storage_shared_prefs_write_error;

  /// No description provided for @error_storage_shared_prefs_delete_error.
  ///
  /// In da, this message translates to:
  /// **'Fejl under sletning af delte præferencer. Prøv igen.'**
  String get error_storage_shared_prefs_delete_error;

  /// No description provided for @error_product_invalid_product_type.
  ///
  /// In da, this message translates to:
  /// **'Ugyldig produkttype angivet.'**
  String get error_product_invalid_product_type;

  /// No description provided for @error_product_invalid_product_group.
  ///
  /// In da, this message translates to:
  /// **'Der blev ikke fundet en gyldig produktgruppe.'**
  String get error_product_invalid_product_group;

  /// No description provided for @error_product_invalid_dropdown_name.
  ///
  /// In da, this message translates to:
  /// **'Der blev ikke fundet et gyldigt dropdownmenu med navn'**
  String get error_product_invalid_dropdown_name;

  /// No description provided for @error_product_defects_not_found.
  ///
  /// In da, this message translates to:
  /// **'Der blev ikke fundet nogen produktdefekter for dette produkttype.'**
  String get error_product_defects_not_found;

  /// No description provided for @view_technical_details.
  ///
  /// In da, this message translates to:
  /// **'Vis tekniske detaljer'**
  String get view_technical_details;

  /// No description provided for @view_error_details.
  ///
  /// In da, this message translates to:
  /// **'Vis fejldetaljer'**
  String get view_error_details;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['da'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

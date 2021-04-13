import 'package:flutter/material.dart';
import 'package:flutterclient/injection_container.dart';
import 'package:flutterclient/src/models/api/response_objects/application_style/application_style_response_object.dart';
import 'package:flutterclient/src/models/api/response_objects/language_response_object.dart';
import 'package:flutterclient/src/models/api/response_objects/user_data_response_object.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/local_database/i_offline_database_provider.dart';
import 'package:flutterclient/src/services/local/locale/supported_locale_manager.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'package:flutterclient/src/util/color/get_color_from_app_style.dart';
import 'package:flutterclient/src/util/theme/theme_manager.dart';

class OfflineStartupPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;

  const OfflineStartupPageWidget(
      {Key? key, required this.appState, required this.manager})
      : super(key: key);

  @override
  _OfflineStartupPageWidgetState createState() =>
      _OfflineStartupPageWidgetState();
}

class _OfflineStartupPageWidgetState extends State<OfflineStartupPageWidget> {
  void _loadData() {
    ApplicationStyleResponseObject? appStyle = widget.manager.applicationStyle;

    if (appStyle != null) {
      widget.appState.applicationStyle = appStyle;

      sl<ThemeManager>().value = ThemeData(
        primaryColor: widget.appState.applicationStyle!.themeColor,
        primarySwatch: getColorFromAppStyle(widget.appState.applicationStyle!),
        brightness: Brightness.light,
      );
    }

    widget.appState.language = LanguageResponseObject(
        language: widget.manager.language ?? 'en', languageResource: '');

    widget.appState.picSize = widget.manager.picSize ?? 320;

    widget.appState.mobileOnly = widget.manager.mobileOnly;
    widget.appState.webOnly = widget.manager.webOnly;

    Map<String, String>? translations = widget.manager.possibleTranslations;

    if (translations != null && translations.isNotEmpty) {
      widget.appState.translationConfig.possibleTranslations = translations;

      widget.appState.translationConfig.supportedLocales = List<Locale>.from(
          widget.appState.translationConfig.possibleTranslations.keys
              .map((key) {
        if (key.contains('_'))
          return Locale(key.substring(key.indexOf('_') + 1, key.indexOf('.')));
        else
          return Locale('en');
      }));

      sl<SupportedLocaleManager>().value =
          widget.appState.translationConfig.supportedLocales;
    }

    UserDataResponseObject? userData = widget.manager.userData;

    if (userData != null) {
      widget.appState.userData = userData;
    }
  }

  void _setAppState() {
    widget.appState.isOffline = widget.manager.isOffline;

    final path = widget.appState.baseDirectory + '/offlineDB.db';

    sl<IOfflineDatabaseProvider>().openCreateDatabase(path);
  }

  void _checkForLogin() {
    if (widget.manager.authKey != null) {}
  }

  @override
  void initState() {
    super.initState();

    _loadData();

    _setAppState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
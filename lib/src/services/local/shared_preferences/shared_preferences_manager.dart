import 'dart:convert';

import 'package:flutterclient/src/models/api/response_objects/application_style/application_style_response_object.dart';
import 'package:flutterclient/src/models/api/response_objects/user_data_response_object.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class SharedPreferencesManager {
  final SharedPreferences sharedPreferences;
  final iv = IV.fromLength(16);
  final encrypter =
      Encrypter(AES(Key.fromUtf8('dkAO8lt3BPf6MrI3f9qnwIL1SW8kH5Va')));

  SharedPreferencesManager({required this.sharedPreferences});

  bool get loadConfig => sharedPreferences.getBool('loadConfig') ?? true;

  String? get baseUrl => sharedPreferences.getString('baseUrl');

  String? get appName => sharedPreferences.getString('appName');

  String? get appMode => sharedPreferences.getString('appMode');

  String? get deviceId => sharedPreferences.getString('deviceId');

  String? get appVersion => sharedPreferences.getString('appVersion');

  String? get previousAppVersion =>
      sharedPreferences.getString('previousAppVersion');

  Map<String, String>? get possibleTranslations {
    String? jsonString = sharedPreferences.getString('possibleTranslations');

    if (jsonString != null) {
      return Map<String, String>.from(json.decode(jsonString));
    } else {
      return null;
    }
  }

  String? get language => sharedPreferences.getString('language');

  int? get picSize => sharedPreferences.getInt('picSize');

  bool get mobileOnly => sharedPreferences.getBool('mobileOnly') ?? false;

  bool get webOnly => sharedPreferences.getBool('webOnly') ?? false;

  ApplicationStyleResponseObject? get applicationStyle {
    String? jsonString = sharedPreferences.getString('applicationStyle');

    if (jsonString != null) {
      return ApplicationStyleResponseObject.fromJson(
          map: json.decode(jsonString));
    }

    return null;
  }

  String? get applicationStyleHash =>
      sharedPreferences.getString('applicationStyleHash');

  set loadConfig(bool? loadConfig) {
    if (loadConfig != null)
      sharedPreferences.setBool('loadConfig', loadConfig);
    else
      sharedPreferences.remove('loadConfig');
  }

  List<String>? get savedImages {
    String? jsonString = sharedPreferences.getString('savedImages');

    if (jsonString != null) {
      return List<String>.from(json.decode(jsonString));
    } else {
      return null;
    }
  }

  String? get authKey => sharedPreferences.getString('authKey');

  UserDataResponseObject? get userData {
    String? jsonString = sharedPreferences.getString('userData');

    if (jsonString != null) {
      return UserDataResponseObject.fromJson(map: json.decode(jsonString));
    } else {
      return null;
    }
  }

  Map<String, dynamic>? get syncLoginData {
    Map<String, dynamic> data = <String, dynamic>{};

    data.putIfAbsent(
        'username',
        () => encrypter.decrypt(
            Encrypted.fromBase64(
                sharedPreferences.getString('syncUsername') ?? ''),
            iv: iv));
    data.putIfAbsent(
        'password',
        () => encrypter.decrypt(
            Encrypted.fromBase64(
                sharedPreferences.getString('syncPassword') ?? ''),
            iv: iv));

    return data;
  }

  bool get isOffline => sharedPreferences.getBool('isOffline') ?? false;

  String? get offlineUsername => encrypter.decrypt(
      Encrypted.fromBase64(
          sharedPreferences.getString('offlineUsername') ?? ''),
      iv: iv);

  String? get offlinePassword => encrypter.decrypt(
      Encrypted.fromBase64(
          sharedPreferences.getString('offlinePassword') ?? ''),
      iv: iv);

  bool get initialStart => sharedPreferences.getBool('initialStart') ?? true;

  set initialStart(bool initialStart) =>
      sharedPreferences.setBool('initialStart', initialStart);

  set isOffline(bool isOffline) =>
      sharedPreferences.setBool('isOffline', isOffline);

  set offlineUsername(String? username) {
    if (username != null && username.isNotEmpty) {
      final hash = sha256.convert(utf8.encode(username)).toString();

      sharedPreferences.setString('offlineUsername', hash);
    } else {
      sharedPreferences.remove('offlineUsername');
    }
  }

  set offlinePassword(String? password) {
    if (password != null && password.isNotEmpty) {
      final hash = sha256.convert(utf8.encode(password)).toString();

      sharedPreferences.setString('offlinePassword', hash);
    } else {
      sharedPreferences.remove('offlinePassword');
    }
  }

  void setSyncLoginData(
      {required String? username, required String? password}) {
    if (username != null && username.isNotEmpty) {
      sharedPreferences.setString(
          'syncUsername', encrypter.encrypt(username, iv: iv).base64);
    } else {
      sharedPreferences.remove('syncUsername');
    }

    if (password != null && password.isNotEmpty) {
      sharedPreferences.setString(
          'syncPassword', encrypter.encrypt(password, iv: iv).base64);
    } else {
      sharedPreferences.remove('syncPassword');
    }
  }

  set baseUrl(String? baseUrl) {
    if (baseUrl != null)
      sharedPreferences.setString('baseUrl', baseUrl);
    else
      sharedPreferences.remove('baseUrl');
  }

  set appName(String? appName) {
    if (appName != null)
      sharedPreferences.setString('appName', appName);
    else
      sharedPreferences.remove('appName');
  }

  set appMode(String? appMode) {
    if (appMode != null)
      sharedPreferences.setString('appMode', appMode);
    else
      sharedPreferences.remove('appMode');
  }

  set deviceId(String? deviceId) {
    if (deviceId != null)
      sharedPreferences.setString('deviceId', deviceId);
    else
      sharedPreferences.remove('deviceId');
  }

  set appVersion(String? appVersion) {
    if (appVersion != null)
      sharedPreferences.setString('appVersion', appVersion);
    else
      sharedPreferences.remove('appVersion');
  }

  set previousAppVersion(String? previousAppVersion) {
    if (previousAppVersion != null)
      sharedPreferences.setString('previousAppVersion', previousAppVersion);
    else
      sharedPreferences.remove('previousAppVersion');
  }

  set possibleTranslations(Map<String, dynamic>? possibleTranslations) {
    if (possibleTranslations != null && possibleTranslations.isNotEmpty) {
      String? jsonString = json.encode(possibleTranslations);

      sharedPreferences.setString('possibleTranslations', jsonString);
    } else {
      sharedPreferences.remove('possibleTranslations');
    }
  }

  set language(String? language) {
    if (language != null && language.isNotEmpty) {
      sharedPreferences.setString('language', language);
    } else {
      sharedPreferences.remove('language');
    }
  }

  set picSize(int? picSize) {
    if (picSize != null) {
      sharedPreferences.setInt('picSize', picSize);
    } else {
      sharedPreferences.remove('picSize');
    }
  }

  set mobileOnly(bool? mobileOnly) {
    if (mobileOnly != null) {
      sharedPreferences.setBool('mobileOnly', mobileOnly);
    } else {
      sharedPreferences.remove('mobileOnly');
    }
  }

  set webOnly(bool? webOnly) {
    if (webOnly != null) {
      sharedPreferences.setBool('webOnly', webOnly);
    } else {
      sharedPreferences.remove('webOnly');
    }
  }

  set applicationStyle(ApplicationStyleResponseObject? applicationStyle) {
    if (applicationStyle != null) {
      sharedPreferences.setString(
          'applicationStyle', json.encode(applicationStyle.toJson()));
    } else {
      sharedPreferences.remove('applicationStyle');
    }
  }

  set applicationStyleHash(String? hash) {
    if (hash != null) {
      sharedPreferences.setString('applicationStyleHash', hash);
    } else {
      sharedPreferences.remove('applicationStyleHash');
    }
  }

  set savedImages(List<String>? images) {
    if (images != null) {
      sharedPreferences.setString('savedImages', json.encode(images));
    } else {
      sharedPreferences.remove('savedImages');
    }
  }

  set authKey(String? authKey) {
    if (authKey != null && authKey.isNotEmpty) {
      sharedPreferences.setString('authKey', authKey);
    } else {
      sharedPreferences.remove('authKey');
    }
  }

  set userData(UserDataResponseObject? userData) {
    if (userData != null) {
      sharedPreferences.setString('userData', json.encode(userData.toJson()));
    } else {
      sharedPreferences.remove('userData');
    }
  }
}

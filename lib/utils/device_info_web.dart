import 'dart:convert';
import 'dart:html';
import 'package:flutter/services.dart';
import 'package:jvx_flutterclient/utils/device_info.dart';
import 'package:platform_detect/platform_detect.dart';
import '../utils/globals.dart' as globals;

class DeviceInfoWeb implements DeviceInfo {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  DeviceInfoWeb() {
    this.technology = "FlutterWeb";
    this.deviceType = browser.name;
    this.deviceTypeModel = window.navigator.userAgent;
    this.osName = operatingSystem.name;
    getAppVersion().then((val) => this.appVersion = val);
    print(
        'Running on: ${this.osName} (SDK ${this.osVersion}), ${this.deviceType} ${this.deviceTypeModel}');
  }

  getAppVersion() async {
    Map<String, dynamic> buildversion = json.decode(await rootBundle.loadString(
        globals.package
            ? 'packages/jvx_flutterclient/env/app_version.json'
            : 'env/app_version.json'));
    return buildversion['version'];
  }
}

DeviceInfo getDeviceInfo() => DeviceInfoWeb();

library jvx_flutterclient.globals;

import 'package:jvx_flutterclient/custom_screen/i_app_frame.dart';

import 'app_listener.dart';
import '../custom_screen/i_socket_handler.dart';
import '../custom_screen/custom_screen_manager/i_custom_screen_manager.dart';
import '../model/so_action.dart' as prefix0;
import '../model/api/response/application_style_resp.dart';
import '../model/menu_item.dart';

String appName;
String baseUrl; //'http://172.16.0.15:8080/JVx.mobile/services/mobile';
String language = 'de';
bool debug = false;
String clientId;
String jsessionId;
List<String> images;
Map<String, String> translation = <String, String>{};
String dir;
ApplicationStyleResponse applicationStyle;
bool isLoading = false;
bool hasToDownload = false;
String appVersion;
String username = '';
String profileImage = '';
String password = '';
String appMode = '';
List<MenuItem> items;
prefix0.SoAction changeScreen;
int timeout = 10;
int uploadPicWidth = 320;
String displayName;
bool handleSessionTimeout = true;
ICustomScreenManager customScreenManager;
ISocketHandler customSocketHandler;
AppListener appListener;
bool package = false;
Map<String, String> files = Map<String, String>();
String currentScreenComponentId;
String currentTempalteName;
IAppFrame appFrame;
bool mobileOnly = false;
String layoutMode = 'Mini';
List<dynamic> roles = [];
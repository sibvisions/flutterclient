import '../../models/api/requests/application_style_request.dart';
import '../../models/api/requests/change_request.dart';
import '../../models/api/requests/close_screen_request.dart';
import '../../models/api/requests/data/data_request.dart';
import '../../models/api/requests/device_status_request.dart';
import '../../models/api/requests/download_images_request.dart';
import '../../models/api/requests/download_request.dart';
import '../../models/api/requests/download_translation_request.dart';
import '../../models/api/requests/login_request.dart';
import '../../models/api/requests/logout_request.dart';
import '../../models/api/requests/menu_request.dart';
import '../../models/api/requests/navigation_request.dart';
import '../../models/api/requests/open_screen_request.dart';
import '../../models/api/requests/press_button_request.dart';
import '../../models/api/requests/set_component_value.dart';
import '../../models/api/requests/startup_request.dart';
import '../../models/api/requests/tab_close_request.dart';
import '../../models/api/requests/tab_select_request.dart';
import '../../models/api/requests/upload_request.dart';
import '../../models/state/app_state.dart';
import '../local/shared_preferences/shared_preferences_manager.dart';
import '../remote/cubit/api_cubit.dart';

abstract class ApiRepository {
  final SharedPreferencesManager manager;
  final AppState appState;

  ApiRepository({
    required this.manager,
    required this.appState,
  });

  Future<ApiState> startup(StartupRequest request);
  Future<ApiState> applicationStyle(ApplicationStyleRequest request);
  Future<ApiState> downloadTranslation(DownloadTranslationRequest request);
  Future<ApiState> downloadImages(DownloadImagesRequest request);
  Future<ApiState> download(DownloadRequest request);
  Future<ApiState> login(LoginRequest request);
  Future<ApiState> logout(LogoutRequest request);
  Future<ApiState> change(ChangeRequest request);
  Future<ApiState> closeScreen(CloseScreenRequest request);
  Future<ApiState> deviceStatus(DeviceStatusRequest request);
  Future<ApiState> menu(MenuRequest request);
  Future<ApiState> navigation(NavigationRequest request);
  Future<ApiState> openScreen(OpenScreenRequest request);
  Future<ApiState> pressButton(PressButtonRequest request);
  Future<ApiState> setComponentValue(SetComponentValueRequest request);
  Future<ApiState> tabClose(TabCloseRequest request);
  Future<ApiState> tabSelect(TabSelectRequest request);
  Future<ApiState> upload(UploadRequest request);
  Future<List<ApiState>> data(DataRequest request);
}

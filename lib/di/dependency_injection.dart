import 'package:jvx_mobile_v3/services/abstract/i_download_service.dart';
import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/abstract/i_logout_service.dart';
import 'package:jvx_mobile_v3/services/abstract/i_startup_service.dart';
import 'package:jvx_mobile_v3/services/mock/mock_login_service.dart';
import 'package:jvx_mobile_v3/services/mock/mock_logout_service.dart';
import 'package:jvx_mobile_v3/services/mock/mock_startup_service.dart';
import 'package:jvx_mobile_v3/services/real/real_download_service.dart';
import 'package:jvx_mobile_v3/services/real/real_login_service.dart';
import 'package:jvx_mobile_v3/services/real/real_logout_service.dart';
import 'package:jvx_mobile_v3/services/real/real_startup_service.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

/// [MOCK] if runtime is in test environment
/// [PRO] if runtime is in production environment
enum Flavor { MOCK, PRO }

/// For injecting instances of Services
class Injector {
  static final Injector _singelton = new Injector._internal();
  static Flavor _flavor;

  static void configure(Flavor flavor) async {
    _flavor = flavor;
  }

  factory Injector() => _singelton;

  Injector._internal();

  ILoginService get loginService {
    switch (_flavor) {
      case Flavor.MOCK:
        return MockLoginService();
      default:
        return LoginService(new RestClient());
    }
  }
  
  IStartupService get startupService {
    switch (_flavor) {
      case Flavor.MOCK:
        return MockStartupService();
      default:
        return StartupService(new RestClient());
    }
  }

  ILogoutService get logoutService {
    switch (_flavor) {
      case Flavor.MOCK:
        return MockLogoutService();
      default:
        return LogoutService(new RestClient());
    }
  }

  IDownloadSerivce get downloadService {
    switch (_flavor) {
      case Flavor.MOCK:
        return ImageDownloadService(new RestClient());
      default:
        return ImageDownloadService(new RestClient());
    }
  }
}
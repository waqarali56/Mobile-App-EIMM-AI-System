

import 'app_config.dart';

class API {
  static String get baseUrl => AppConfig.baseUrl;

  // Auth endpoints
  static String get login => baseUrl + "/auth/login";
  static String get register => baseUrl + "/auth/register";
  static String get authBase => baseUrl + "/auth";
  static String get changePassword => baseUrl + "/auth/change-password";

}

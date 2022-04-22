import 'package:shared_preferences/shared_preferences.dart';

class PrefMngr {
  Future<bool> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString(key);
    return val;
  }
}

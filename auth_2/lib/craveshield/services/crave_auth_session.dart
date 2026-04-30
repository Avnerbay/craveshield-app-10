import 'package:shared_preferences/shared_preferences.dart';

class CraveAuthSession {
  const CraveAuthSession._();

  static const isLoggedInKey = 'isLoggedIn';
  static const userNameKey = 'userName';
  static const userEmailKey = 'userEmail';
  static const selectedAddictionKey = 'selectedAddiction';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> saveSession({
    String? name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString(userNameKey, name.trim());
    }
    await prefs.setString(userEmailKey, email.trim());
  }

  static Future<void> saveSelectedAddiction(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedAddictionKey, value);
  }
}

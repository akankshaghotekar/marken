import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  static const String _isLoggedIn = "is_logged_in";
  static const String _userSrNo = "user_srno";
  static const String _employeeType = "employee_type";
  static const String _name = "name";
  static const String _employeeSrNo = "employee_srno";

  static Future<void> saveLogin({
    required String userSrNo,
    required String employeeSrNo,
    required String employeeType,
    required String name,
  }) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setBool(_isLoggedIn, true);
    await pref.setString(_userSrNo, userSrNo);
    await pref.setString(_employeeSrNo, employeeSrNo);
    await pref.setString(_employeeType, employeeType);
    await pref.setString(_name, name);
  }

  static Future<String?> getEmployeeSrNo() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_employeeSrNo);
  }

  static Future<bool> isLoggedIn() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_isLoggedIn) ?? false;
  }

  static Future<String?> getEmployeeType() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_employeeType);
  }

  static Future<String?> getName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_name);
  }

  static Future<String?> getUserSrNo() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_userSrNo);
  }

  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}

class ApiConfig {
  static const String baseUrl = "https://digitalspaceinc.com/mark_ent/ws/";

  static String get loginUrl => "${baseUrl}login.php";

  static String get holidayListUrl => "${baseUrl}holidayList.php";

  static String get markAttendanceUrl => "${baseUrl}markAttendance.php";
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:marken/helper/api/api_config.dart';
import 'package:marken/helper/model/attendance_report_model.dart';
import 'package:marken/helper/model/holiday_model.dart';
import 'package:marken/helper/model/login_model.dart';

class ApiService {
  /// GENERIC POST REQUEST
  static Future<Map<String, dynamic>> _postRequest(
    String url,
    Map<String, String> params,
  ) async {
    try {
      final response = await http.post(Uri.parse(url), body: params);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 1, 'message': 'Server error'};
      }
    } catch (e) {
      return {'status': 1, 'message': 'Network error'};
    }
  }

  /// LOGIN
  static Future<LoginModel?> login({
    required String username,
    required String password,
  }) async {
    final res = await _postRequest(ApiConfig.loginUrl, {
      'username': username,
      'password': password,
    });

    if (res['status'] == 0) {
      return LoginModel.fromJson(res);
    }

    return null;
  }

  /// GET HOLIDAY LIST
  static Future<List<HolidayData>> getHolidayList() async {
    final res = await _postRequest(ApiConfig.holidayListUrl, {});

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List).map((e) => HolidayData.fromJson(e)).toList();
    }

    return [];
  }

  /// MARK ATTENDANCE (INHOUSE — with image)
  static Future<Map<String, dynamic>> markAttendance({
    required String usersrno,
    required String employeesrno,
    required String billDate,
    required String inOut,
    File? imgFile,
    required String lat,
    required String lng,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.markAttendanceUrl),
      );

      request.fields['usersrno'] = usersrno;
      request.fields['employeesrno'] = employeesrno;
      request.fields['bill_date'] = billDate;
      request.fields['in_out'] = inOut;
      request.fields['lat'] = lat;
      request.fields['lng'] = lng;

      if (imgFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imgFile.path),
        );
      }

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      return {'status': 1, 'message': 'Server error'};
    } catch (e) {
      return {'status': 1, 'message': 'Network error'};
    }
  }

  /// GET ATTENDANCE STATUS
  static Future<Map<String, dynamic>> getAttendanceStatus({
    required String usersrno,
    required String employeesrno,
  }) async {
    return await _postRequest("${ApiConfig.baseUrl}get_attendance_status.php", {
      'usersrno': usersrno,
      'employeesrno': employeesrno,
    });
  }

  /// GET ATTENDANCE REPORT
  static Future<List<AttendanceReportModel>> getAttendanceReport({
    required String usersrno,
    required String employeesrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/mark_ent/ws/get_attendance_report.php",
      {
        'usersrno': usersrno,
        'employeesrno': employeesrno,
        'from_date': fromDate,
        'to_date': toDate,
      },
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => AttendanceReportModel.fromJson(e))
          .toList();
    }

    return [];
  }

  /// ADD ATTENDANCE REGULARIZE
  static Future<Map<String, dynamic>> addAttendanceRegularize({
    required String usersrno,
    required String employeesrno,
    required String srno,
    required String date,
    required String comment,
  }) async {
    final res = await _postRequest(
      "https://digitalspaceinc.com/mark_ent/ws/addattendanceregularize.php",
      {
        'usersrno': usersrno,
        'employeesrno': employeesrno,
        'srno': srno,
        'attendance_date': date,
        'comment': comment,
      },
    );

    return res;
  }

  /// SEND LIVE LOCATION — ONSITE employees only

  static Future<Map<String, dynamic>> sendLiveLocation({
    required String usersrno,
    required String employeesrno,
    required String lat,
    required String lng,
  }) async {
    return await _postRequest(
      "https://digitalspaceinc.com/mark_ent/ws/addEmployeeLocation.php",
      {
        'usersrno': usersrno,
        'employeesrno': employeesrno,
        'lat': lat,
        'lng': lng,
      },
    );
  }
}

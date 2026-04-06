class HolidayModel {
  final int status;
  final String message;
  final List<HolidayData> data;

  HolidayModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List).map((e) => HolidayData.fromJson(e)).toList(),
    );
  }
}

class HolidayData {
  final String srno;
  final String date;
  final String holidayType;
  final String holidayTitle;

  HolidayData({
    required this.srno,
    required this.date,
    required this.holidayType,
    required this.holidayTitle,
  });

  factory HolidayData.fromJson(Map<String, dynamic> json) {
    return HolidayData(
      srno: json['srno'],
      date: json['date'],
      holidayType: json['holiday_type'],
      holidayTitle: json['holiday_title'],
    );
  }
}

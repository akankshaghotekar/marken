class AttendanceReportModel {
  final String srno;
  final String date;
  final String day;
  final String punchIn;
  final String punchOut;
  final String status;
  final String regularizeStatus;

  AttendanceReportModel({
    required this.srno,
    required this.date,
    required this.day,
    required this.punchIn,
    required this.punchOut,
    required this.status,
    required this.regularizeStatus,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      srno: json['srno'] ?? "",
      date: json['date'] ?? "",
      day: json['day'] ?? "",
      punchIn: json['punch_in_time'] ?? "",
      punchOut: json['punch_out_time'] ?? "",
      status: json['status'] ?? "",
      regularizeStatus: json['attendance_regularize'] ?? "",
    );
  }
}

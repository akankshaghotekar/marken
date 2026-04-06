import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marken/helper/api/api_service.dart';
import 'package:marken/helper/model/attendance_report_model.dart';
import 'package:marken/helper/shared_pref/app_pref.dart';
import 'package:marken/screens/attendance/attendance_regularize_form.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  List<AttendanceReportModel> reportList = [];
  bool isLoading = false;

  String? _usersrno;
  String? _employeesrno;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _usersrno = await AppPref.getUserSrNo();
    _employeesrno = await AppPref.getEmployeeSrNo();
    await _fetchReport();
  }

  Future<void> _fetchReport() async {
    if (_usersrno == null || _employeesrno == null) return;
    if (!mounted) return;
    setState(() => isLoading = true);

    final data = await ApiService.getAttendanceReport(
      usersrno: _usersrno!,
      employeesrno: _employeesrno!,
      fromDate: _formatter.format(fromDate),
      toDate: _formatter.format(toDate),
    );

    if (!mounted) return;
    setState(() {
      reportList = data ?? [];
      isLoading = false;
    });
  }

  /// "18-03-2026" -> "18"
  String _extractDay(String dateStr) {
    if (dateStr.contains("-")) return dateStr.split("-")[0];
    return "--";
  }

  /// "18-03-2026" -> "MAR"
  String _extractMonth(String dateStr) {
    const monthNames = {
      "01": "JAN",
      "02": "FEB",
      "03": "MAR",
      "04": "APR",
      "05": "MAY",
      "06": "JUN",
      "07": "JUL",
      "08": "AUG",
      "09": "SEP",
      "10": "OCT",
      "11": "NOV",
      "12": "DEC",
    };
    if (dateStr.contains("-")) {
      final parts = dateStr.split("-");
      if (parts.length >= 2) {
        return monthNames[parts[1].padLeft(2, '0')] ?? "--";
      }
    }
    return "--";
  }

  /// "18-Mar-2026 15:17:27" -> "15:17:27"   empty -> "--:--"
  String _extractTime(String dateTimeStr) {
    if (dateTimeStr.trim().isEmpty) return "--:--";
    final parts = dateTimeStr.trim().split(" ");
    if (parts.length >= 2) return parts.last;
    return "--:--";
  }

  Color _getColor(String status) {
    if (status.toLowerCase().contains("present")) return Colors.green;
    if (status.toLowerCase().contains("half")) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Attendance Report",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 20.h),

            /// FILTER ROW
            Row(
              children: [
                _dateBox("From Date", fromDate, _pickFromDate),
                SizedBox(width: 12.w),
                _dateBox("To Date", toDate, _pickToDate),
                SizedBox(width: 12.w),
                _viewButton(),
              ],
            ),

            SizedBox(height: 20.h),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportList.isEmpty
                  ? const Center(child: Text("No data found"))
                  : ListView.builder(
                      itemCount: reportList.length,
                      itemBuilder: (context, index) {
                        final item = reportList[index];
                        return _AttendanceCard(
                          day: _extractDay(item.date),
                          month: _extractMonth(item.date),
                          color: _getColor(item.status),
                          attendanceRegularize: item.regularizeStatus,
                          punchIn: _extractTime(item.punchIn),
                          punchOut: _extractTime(item.punchOut),
                          srno: item.srno,
                          onRefresh: _fetchReport,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatter.format(date),
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  Icon(Icons.calendar_month, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: GestureDetector(
        onTap: _fetchReport,
        child: Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColor.primaryBlue,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  "View",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await _showPicker(fromDate, DateTime(2000));
    if (picked != null) {
      setState(() {
        fromDate = picked;
        if (toDate.isBefore(picked)) toDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await _showPicker(toDate, fromDate);
    if (picked != null) setState(() => toDate = picked);
  }

  Future<DateTime?> _showPicker(DateTime initial, DateTime first) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.primaryBlue),
          ),
          child: child!,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ATTENDANCE CARD
// ---------------------------------------------------------------------------

class _AttendanceCard extends StatelessWidget {
  final String day;
  final String month;
  final Color color;
  final String punchIn;
  final String punchOut;
  final String srno;
  final String attendanceRegularize;
  final Function()? onRefresh;

  const _AttendanceCard({
    required this.day,
    required this.month,
    required this.color,
    required this.attendanceRegularize,
    required this.punchIn,
    required this.punchOut,
    required this.srno,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool isApproved = attendanceRegularize == "Approved";
    final bool isRequested = attendanceRegularize == "Request";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── DATE BADGE: day number on top, month abbreviation below ──
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          // ── PUNCH IN: time only ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punchIn,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Punch In",
                  style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                ),
              ],
            ),
          ),

          // ── PUNCH OUT: time only ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punchOut,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Punch Out",
                  style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                ),
              ],
            ),
          ),

          // ── REGULARIZE ───────────────────────────────────────────────
          GestureDetector(
            onTap: isApproved
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceRegularizeForm(srno: srno),
                      ),
                    );
                    if (result == true && onRefresh != null) {
                      onRefresh!();
                    }
                  },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_calendar,
                  color: isApproved
                      ? Colors.green
                      : isRequested
                      ? Colors.orange
                      : AppColor.primaryBlue,
                  size: 26.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  isApproved
                      ? "Approved"
                      : isRequested
                      ? "Request Sent"
                      : "Not Requested",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isApproved
                        ? Colors.green
                        : isRequested
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
              child: ListView(
                children: const [
                  _AttendanceCard(
                    day: "06",
                    week: "TUE",
                    color: Colors.green,
                    attendanceRegularize: "Not Requested",
                  ),
                  _AttendanceCard(
                    day: "07",
                    week: "WED",
                    color: Colors.orange,
                    attendanceRegularize: "Request",
                  ),
                  _AttendanceCard(
                    day: "08",
                    week: "THU",
                    color: Colors.red,
                    attendanceRegularize: "Approved",
                  ),
                  _AttendanceCard(
                    day: "09",
                    week: "FRI",
                    color: Colors.green,
                    attendanceRegularize: "Not Requested",
                  ),
                ],
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
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.primaryBlue,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "View",
          style: TextStyle(
            color: AppColor.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
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
        toDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await _showPicker(toDate, fromDate);
    if (picked != null) {
      setState(() => toDate = picked);
    }
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

/// ATTENDANCE CARD

class _AttendanceCard extends StatelessWidget {
  final String day;
  final String week;
  final Color color;
  final String attendanceRegularize;

  const _AttendanceCard({
    required this.day,
    required this.week,
    required this.color,
    required this.attendanceRegularize,
  });

  @override
  Widget build(BuildContext context) {
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
          /// DATE BADGE
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  week,
                  style: TextStyle(color: Colors.white, fontSize: 11.sp),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          /// TIMES
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "09:08 AM",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Punch In",
                  style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "06:05 PM",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Punch Out",
                  style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                ),
              ],
            ),
          ),

          /// REGULARIZE ACTION
          Column(
            children: [
              GestureDetector(
                onTap: attendanceRegularize == "Approved"
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttendanceRegularizeForm(srno: "1"),
                          ),
                        );
                      },
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_calendar,
                      color: attendanceRegularize == "Approved"
                          ? Colors.green
                          : attendanceRegularize == "Request"
                          ? Colors.orange
                          : AppColor.primaryBlue,
                      size: 26.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      attendanceRegularize == "Approved"
                          ? "Approved"
                          : attendanceRegularize == "Request"
                          ? "Request Sent"
                          : "Not Requested",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: attendanceRegularize == "Approved"
                            ? Colors.green
                            : attendanceRegularize == "Request"
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

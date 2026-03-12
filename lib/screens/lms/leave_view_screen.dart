import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marken/screens/lms/leave_request_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';

class LeaveViewScreen extends StatefulWidget {
  const LeaveViewScreen({super.key});

  @override
  State<LeaveViewScreen> createState() => _LeaveViewScreenState();
}

class _LeaveViewScreenState extends State<LeaveViewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  bool showResult = false;

  List<Map<String, String>> leaveList = [];

  void loadStaticLeaves() {
    leaveList = [
      {"from": "10-03-2026", "to": "10-03-2026", "status": "Approved"},
      {"from": "05-03-2026", "to": "06-03-2026", "status": "Pending"},
      {"from": "01-03-2026", "to": "01-03-2026", "status": "Rejected"},
    ];

    setState(() {
      showResult = true;
    });
  }

  Future<void> pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate.isBefore(fromDate)) {
            toDate = fromDate;
          }
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
        showAdd: true,
        onAdd: () {
          Navigator.push(
            context,
            AnimatedPageRoute(page: const LeaveRequestScreen()),
          );
        },
      ),
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              "Leave View",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryBlue,
              ),
            ),
            Divider(color: AppColor.iconBg, height: 10.h),

            SizedBox(height: 20.h),

            Row(
              children: [
                Expanded(
                  child: dateBox("From", fromDate, () => pickDate(true)),
                ),
                SizedBox(width: 10.w),
                Expanded(child: dateBox("To", toDate, () => pickDate(false))),
                SizedBox(width: 10.w),
                viewButton(),
              ],
            ),

            SizedBox(height: 20.h),
            Divider(color: AppColor.iconBg, height: 30.h),

            if (showResult)
              Expanded(
                child: ListView.builder(
                  itemCount: leaveList.length,
                  itemBuilder: (context, index) {
                    final item = leaveList[index];

                    return LeaveStatusCard(
                      fromDate: item["from"]!,
                      toDate: item["to"]!,
                      status: item["status"]!,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget dateBox(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5.h),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(date)),
                Icon(Icons.calendar_month),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget viewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryBlue),
        onPressed: loadStaticLeaves,
        child: const Text("View", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class LeaveStatusCard extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final String status;

  const LeaveStatusCard({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.status,
  });

  Color _statusColor() {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _lighterShade(Color color) {
    return Color.fromARGB(40, color.red, color.green, color.blue);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _statusColor();
    final bgColor = _lighterShade(borderColor);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              fromDate,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              toDate,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: borderColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marken/screens/lms/leave_view_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime? fromDate;
  DateTime? toDate;

  final TextEditingController reasonController = TextEditingController();

  int availableBalance = 12;
  int lwp = 0;

  String halfDay = "No";

  Future<void> pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void submitLeave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Leave Request Submitted!",
          style: TextStyle(color: AppColor.primaryBlue),
        ),
        backgroundColor: AppColor.iconBg,
      ),
    );

    reasonController.clear();

    setState(() {
      fromDate = null;
      toDate = null;
    });

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        AnimatedPageRoute(page: const LeaveViewScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            /// Scrollable form
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "Leave Request",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryBlue,
                    ),
                  ),
                  Divider(color: AppColor.iconBg),

                  SizedBox(height: 10.h),

                  dateField("From Date", fromDate, () => pickDate(true)),
                  SizedBox(height: 15.h),

                  dateField("To Date", toDate, () => pickDate(false)),

                  SizedBox(height: 20.h),

                  readonlyField(
                    "Available Balance",
                    availableBalance.toString(),
                  ),

                  SizedBox(height: 15.h),

                  dropdownField(),

                  SizedBox(height: 15.h),

                  readonlyField("Leave Applied For", "1 Day"),

                  SizedBox(height: 15.h),

                  readonlyField("LWP", lwp.toString()),

                  SizedBox(height: 15.h),

                  reasonField(),

                  SizedBox(height: 20.h),
                ],
              ),
            ),

            /// Fixed Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryBlue,
                  minimumSize: Size(double.infinity, 45.h),
                ),
                onPressed: submitLeave,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: AppColor.white),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget dateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),

        SizedBox(height: 6.h),

        InkWell(
          onTap: onTap,
          child: Container(
            height: 45.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null
                      ? "Select Date"
                      : DateFormat('dd-MM-yyyy').format(date),
                ),
                Icon(Icons.calendar_month),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),

        SizedBox(height: 6.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.grey),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget dropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Half Day"),

        SizedBox(height: 6.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.grey),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: halfDay,
              items: [
                "Yes",
                "No",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                setState(() => halfDay = val!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget reasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reason"),

        SizedBox(height: 6.h),

        TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter reason",
          ),
        ),
      ],
    );
  }
}

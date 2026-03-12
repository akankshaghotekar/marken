import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';

class AttendanceRegularizeForm extends StatefulWidget {
  final String srno;

  const AttendanceRegularizeForm({super.key, required this.srno});

  @override
  State<AttendanceRegularizeForm> createState() =>
      _AttendanceRegularizeFormState();
}

class _AttendanceRegularizeFormState extends State<AttendanceRegularizeForm> {
  DateTime? attendanceDate;
  final TextEditingController commentController = TextEditingController();

  bool isLoading = false;

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  bool get isFormValid {
    if (attendanceDate == null) return false;
    if (commentController.text.trim().isEmpty) return false;
    return true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: attendanceDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => attendanceDate = picked);
    }
  }

  void _submit() async {
    if (!isFormValid) return;

    setState(() => isLoading = true);

    /// Fake API delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Attendance regularize request submitted",
          style: TextStyle(color: AppColor.primaryBlue),
        ),
        backgroundColor: AppColor.iconBg,
      ),
    );

    Navigator.pop(context, true);

    commentController.clear();
    attendanceDate = null;
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Center(
              child: Text(
                "Attendance Regularize",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 25.h),

            /// DATE
            Text(
              "Attendance Date",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 6.h),

            InkWell(
              onTap: _pickDate,
              child: Container(
                height: 45.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColor.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attendanceDate == null
                          ? "Select Date"
                          : formatter.format(attendanceDate!),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    Icon(Icons.calendar_month, size: 20.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            /// COMMENT
            Text(
              "Comment",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 6.h),

            Container(
              height: 110.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.grey),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter reason...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ),

            const Spacer(),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? AppColor.primaryBlue
                      : Colors.grey,
                ),
                onPressed: isFormValid ? _submit : null,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/screens/attendance/attendance_report_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isPunchedIn = false;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _onPunchTap() {
    setState(() {
      isPunchedIn = true;
      _rotationController.repeat(); // start rotating for punch out
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        showNotification: true,
        onMenu: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      body: Column(
        children: [
          SizedBox(height: 20.h),

          Text(
            "Mark Attendance",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.primaryBlue,
            ),
          ),

          SizedBox(height: 80.h),

          /// SINGLE PUNCH CIRCLE (Animated Switch)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: isPunchedIn
                ? _PunchCircle(
                    key: const ValueKey("OUT"),
                    label: "PUNCH\nOUT",
                    iconColor: Colors.green,
                    borderColor: AppColor.primaryBlue,
                    rotation: _rotationController,
                  )
                : GestureDetector(
                    key: const ValueKey("IN"),
                    onTap: _onPunchTap,
                    child: _PunchCircle(
                      label: "PUNCH\nIN",
                      iconColor: Colors.red,
                      borderColor: AppColor.primaryBlue,
                    ),
                  ),
          ),

          SizedBox(height: 80.h),

          /// TIME INFO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeInfo("09:08 AM", "Punch In"),
                _timeInfo("--:--", "Punch Out"),
              ],
            ),
          ),

          const Spacer(),

          /// VIEW REPORT BUTTON
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 35.h),
            child: SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    AnimatedPageRoute(page: AttendanceReportScreen()),
                  );
                },
                child: const Text(
                  "View Attendance report",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25.h),
        ],
      ),
    );
  }

  /// TIME INFO
  Widget _timeInfo(String time, String label) {
    return Column(
      children: [
        Icon(Icons.access_time, color: AppColor.primaryBlue, size: 22.sp),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColor.grey),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------------
/// PUNCH CIRCLE
/// ------------------------------------------------------------------

class _PunchCircle extends StatelessWidget {
  final String label;
  final Color iconColor;
  final Color borderColor;
  final AnimationController? rotation;

  const _PunchCircle({
    super.key,
    required this.label,
    required this.iconColor,
    required this.borderColor,
    this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RotationTransition(
          turns: rotation ?? const AlwaysStoppedAnimation(0),
          child: Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 6.w),
            ),
          ),
        ),
        Container(
          width: 130.w,
          height: 130.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 4.w),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, color: iconColor, size: 32.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

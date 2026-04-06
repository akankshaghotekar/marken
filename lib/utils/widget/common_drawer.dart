import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/helper/shared_pref/app_pref.dart';
import 'package:marken/screens/attendance/attendance_screen.dart';
import 'package:marken/screens/holiday/holiday_list_screen.dart';
import 'package:marken/screens/home_screen/home_screen.dart';
import 'package:marken/screens/lms/leave_view_screen.dart';
import 'package:marken/screens/login/login_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'package:marken/utils/app_colors.dart';

class CommonDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const CommonDrawer({super.key, required this.onClose});

  Future<void> _navigate(BuildContext context, String menu) async {
    Navigator.pop(context);

    switch (menu) {
      case "Home":
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return;

      case "Mark Attendance":
        Navigator.pushReplacement(
          context,
          AnimatedPageRoute(page: AttendanceScreen()),
        );
        break;
      case "LMS":
        Navigator.pushReplacement(
          context,
          AnimatedPageRoute(page: LeaveViewScreen()),
        );
        break;
      case "Holiday List":
        Navigator.pushReplacement(
          context,
          AnimatedPageRoute(page: HolidayListScreen()),
        );
        break;

      case "Logout":
        await AppPref.logout();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.appBgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(color: AppColor.primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CLOSE ICON
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Icon(
                        Icons.close,
                        color: AppColor.white,
                        size: 22.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  /// HOME + LOCATION
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/marken-app-logo.png',
                        height: 40.h,
                      ),
                      SizedBox(width: 12.w),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Marken",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          FutureBuilder<String?>(
                            future: AppPref.getName(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "",
                                style: TextStyle(
                                  color: AppColor.orange,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            _drawerItem(context, Icons.home_outlined, "Home"),

            _drawerItem(context, Icons.fingerprint_outlined, "Mark Attendance"),
            _drawerItem(context, Icons.menu_book_rounded, "LMS"),
            _drawerItem(context, Icons.calendar_month_outlined, "Holiday List"),

            const Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: InkWell(
                onTap: () => _navigate(context, "Logout"),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColor.red, size: 25.sp),
                    SizedBox(width: 16.w),
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () => _navigate(context, title),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 26.sp, color: AppColor.textDark),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

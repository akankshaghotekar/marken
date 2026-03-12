import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColor.iconBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.primaryBlue, width: 1.w),
          ),
          height: 150.h,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to Marken",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryBlue,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                "Akanksha Ghotekar",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                "Employee ID: 09",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

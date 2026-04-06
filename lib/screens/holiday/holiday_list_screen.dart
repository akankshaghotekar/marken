import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/helper/api/api_service.dart';
import 'package:marken/helper/model/holiday_model.dart';
import 'package:marken/utils/app_colors.dart';
import 'package:marken/utils/widget/common_app_bar.dart';
import 'package:marken/utils/widget/common_drawer.dart';

class HolidayListScreen extends StatefulWidget {
  const HolidayListScreen({super.key});

  @override
  State<HolidayListScreen> createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends State<HolidayListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<HolidayData> holidays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHolidays();
  }

  Future<void> fetchHolidays() async {
    final data = await ApiService.getHolidayList();

    setState(() {
      holidays = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.appBgColor,
      appBar: CommonAppBar(
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Holiday List",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryBlue,
              ),
            ),
            Divider(color: AppColor.iconBg),

            SizedBox(height: 20.h),

            /// Table Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColor.primaryBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Date",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Holiday Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            /// Holiday List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: holidays.length,
                      itemBuilder: (context, index) {
                        final holiday = holidays[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 10.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColor.grey),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    holiday.date,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    holiday.holidayTitle.replaceAll("\n", " "),
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/utils/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final bool showNotification;
  final bool showAdd;

  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onAdd;

  const CommonAppBar({
    super.key,
    this.showBack = false,
    this.showNotification = false,
    this.showAdd = false,
    this.onBack,
    this.onMenu,
    this.onAdd,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: showBack ? onBack : onMenu,
              child: _iconCircle(showBack ? Icons.arrow_back : Icons.menu),
            ),

            Image.asset('assets/images/marken-logo.png', height: 40.h),

            Row(
              children: [
                if (showNotification)
                  IconButton(
                    onPressed: () {},
                    icon: _iconCircle(Icons.notifications_outlined),
                  ),

                if (showNotification && showAdd) SizedBox(width: 8.w),

                if (showAdd)
                  IconButton(onPressed: onAdd, icon: _iconCircle(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColor.iconBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, size: 24.sp),
    );
  }
}

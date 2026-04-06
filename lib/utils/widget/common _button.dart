import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marken/utils/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final FontWeight? fontWeight;
  final double? fontSize;
  final bool isDisabled;

  const CommonButton({
    super.key,
    required this.title,
    required this.onTap,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.fontWeight,
    this.fontSize,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 45.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Color.fromRGBO(0, 2, 100, 0.4)
              : (backgroundColor ?? AppColor.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
          ),
          elevation: 2,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 15.sp,
            fontWeight: fontWeight ?? FontWeight.w600,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}

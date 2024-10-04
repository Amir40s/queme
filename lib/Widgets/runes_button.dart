import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class RunesButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const RunesButton({
    super.key,
    required this.title,
    this.loading = false,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
        ),
        width: 350.w,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                      fontFamily: 'Palanquin Dark'),
                ),
        ),
      ),
    );
  }
}

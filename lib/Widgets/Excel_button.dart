import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class ExcelButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const ExcelButton({
    super.key,
    required this.title,
    this.loading = false,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        decoration:  BoxDecoration(
          color: Colors.green[700],
        ),
        height:48.h,
        width: 392.w,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : Text(
            title,
            style:  TextStyle(
                fontSize: 16.h,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
                fontFamily: 'Palanquin Dark'),
          ),
        ),
      ),
    );
  }
}
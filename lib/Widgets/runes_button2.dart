import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';


class RunesButton2 extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const RunesButton2({
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
        decoration: BoxDecoration(
          color: Colors.transparent, // Remove the fill color
          border: Border.all(
            color: Colors.red, // Set the outline color to red
            width: 2, // Set the width of the border (adjust if needed)
          ),
        ),
        height: 34.h,
        width: 350.w,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
            color: AppColors.buttonColor, // Adjust the loading indicator color if needed
          )
              : Text(
            title,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.buttonColor, // Set the text color to red
                fontFamily: 'Palanquin Dark'),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class ClamedButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const ClamedButton({
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
          color: Colors.grey[300],
        ),
        height: 34.h,
        width: 101.w,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : Text(
            title,
            style:  TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Palanquin Dark'),
          ),
        ),
      ),
    );
  }
}

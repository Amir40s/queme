import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ClamedButton extends StatelessWidget {
  final String title;
  final bool loading;
  final Color? bgColor;
  final Color? textColor;

  final VoidCallback onPress;
  const ClamedButton({
    super.key,
    required this.title,
    this.loading = false,
    required this.onPress,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.grey[300],
        ),
        width: 101.w,
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
                      color: textColor ?? Colors.grey,
                      fontFamily: 'Palanquin Dark'),
                ),
        ),
      ),
    );
  }
}

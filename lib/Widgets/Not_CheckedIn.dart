import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class NotCheckedInButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const NotCheckedInButton({
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
            color: Colors.orange[100],
        ),
        height: 40.h,
        width: 170.w,
        child: Center(
          child: loading
              ?  CircularProgressIndicator(
            color: Colors.orange[200],
          )
              : Text(
            title,
            style:  TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontFamily: 'Palanquin Dark'),
          ),
        ),
      ),
    );
  }
}

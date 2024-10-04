import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queme/Widgets/round_button.dart';

class ClaimSuccfullyScreen extends StatefulWidget {
  const ClaimSuccfullyScreen({super.key});

  @override
  State<ClaimSuccfullyScreen> createState() => _ClaimSuccfullyScreenState();
}

class _ClaimSuccfullyScreenState extends State<ClaimSuccfullyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/images/done.svg',
                    height: 250.h,
                    width: 190.w,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Dog Claimed",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "You have successfully claimed Tommy. You \nwill now receive updates.",
                  style: TextStyle(
                    fontFamily: "Palanquin",
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                // RoundButton triggers _loginAsHost when pressed
                RoundButton(
                  title: "Done",
                  onPress: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

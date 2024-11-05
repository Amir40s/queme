import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Auth/Login_Screen.dart';
import 'package:queme/Screens/Host_Screens/Host_Dashboard/Host_Dashboard.dart';
import 'package:queme/Screens/Host_Screens/Host_Dashboard/host_bottom_nav.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/provider/eventProvider.dart';

class PaymentSuccessfulScreen extends StatefulWidget {
  const PaymentSuccessfulScreen({super.key});

  @override
  State<PaymentSuccessfulScreen> createState() =>
      _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
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
                  "Payment Successful",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Thank you for your payment. A confirmation\nemail has been sent to your email address.",
                  style: TextStyle(
                    fontFamily: "Palanquin",
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                RoundButton(
                  title: "Login as HOST",
                  onPress: () {
                    Provider.of<EventProvider>(context, listen: false)
                        .changeUserType('Host');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HostBottomNav(),
                      ),
                    );
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

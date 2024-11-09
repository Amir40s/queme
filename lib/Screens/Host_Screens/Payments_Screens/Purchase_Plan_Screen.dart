import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Host_Screens/Payments_Screens/Payment_Plans_Screen.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/provider/paymentProvider.dart';
import '../../../Widgets/colors.dart';
import 'Payment_Info_Screen.dart';

class PurchasePlanScreen extends StatefulWidget {
  final PackageModel package;
  const PurchasePlanScreen({
    super.key,
    required this.package,
  });

  @override
  State<PurchasePlanScreen> createState() => _PurchasePlanScreenState();
}

class _PurchasePlanScreenState extends State<PurchasePlanScreen> {
  // Firebase Database reference
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(), // Make sure Firebase is initialized
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              // Back Button and Heading
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(15.0.h),
                        child: SvgPicture.asset(
                          'assets/images/back_arrow.svg',
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    "Purchase Plan",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Palanquin Dark",
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              _buildPlanDetails(),

              const Spacer(),
              Consumer<PaymentProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : RoundButton(
                          title: "Confirm Purchase",
                          onPress: () {
                            widget.package.price == '0'
                                ? provider.updateFreeTrialPaymentInfo(
                                    widget.package.renewal,
                                    widget.package.eventsCount)
                                : provider.makePayment(
                                    context,
                                    widget.package.price,
                                    widget.package.renewal,
                                    widget.package.eventsCount,
                                  );
                          },
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to Display Plan Details
  Widget _buildPlanDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.package.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    fontSize: 24.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.package.description,
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Fee",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          fontSize: 16.sp)),
                  Text(
                    "\$${widget.package.price}",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16.sp,
                        color: AppColors.buttonColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

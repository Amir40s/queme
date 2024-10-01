import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Widgets/round_button.dart';
import '../../../Widgets/colors.dart';
import 'Purchase_Plan_Screen.dart';

class PaymentPlansScreen extends StatefulWidget {
  const PaymentPlansScreen({super.key});

  @override
  State<PaymentPlansScreen> createState() => _PaymentPlansScreenState();
}

class _PaymentPlansScreenState extends State<PaymentPlansScreen> {
  // Navigate to the PurchasePlanScreen with plan details
  void _navigateToPurchasePlan(String title, String description, int amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchasePlanScreen(
          planTitle: title,
          planDescription: description,
          planAmount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              Row(
                children: [
                   SizedBox(width: 20.w),
                   Text(
                    "Plans",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Palanquin Dark",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 10.h),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey.shade300,
                  ),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 25.h, vertical: 10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Monthly Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            fontSize: 24.sp,
                          ),
                        ),
                         SizedBox(height: 10.h),
                         Text(
                          "Host up to 6 events per month",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         SizedBox(height: 10.h),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Event Amount",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "\$400",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 20.sp,
                                color: AppColors.buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: RoundButton(
                            title: "Purchase Plan",
                            onPress: () {
                              _navigateToPurchasePlan(
                                "Monthly Plan",
                                "Host up to 6 events per month",
                                400,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Similarly for Yearly Plan and LifeTime Plan
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 10.h),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey.shade300,
                  ),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 25.h, vertical: 10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Yearly Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            fontSize: 24.sp,
                          ),
                        ),
                         SizedBox(height: 10.h),
                         Text(
                          "Host up to 80 events per month",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         SizedBox(height: 10.h),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Event Amount",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "\$5000",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 20.sp,
                                color: AppColors.buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 15.h),
                          child: RoundButton(
                            title: "Purchase Plan",
                            onPress: () {
                              _navigateToPurchasePlan(
                                "Yearly Plan",
                                "Host up to 80 events per month",
                                1400,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

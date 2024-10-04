import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import '../../../Widgets/colors.dart';
import 'Payment_Info_Screen.dart';
import 'Payment_Successful_Screen.dart';

class PurchasePlanScreen extends StatefulWidget {
  final String planTitle;
  final String planDescription;
  final int planAmount;

  PurchasePlanScreen({
    Key? key,
    required this.planTitle,
    required this.planDescription,
    required this.planAmount,
  }) : super(key: key);

  @override
  State<PurchasePlanScreen> createState() => _PurchasePlanScreenState();
}

class _PurchasePlanScreenState extends State<PurchasePlanScreen> {
  String? _selectedPaymentMethod =
      'Paypal'; // Initially selected payment method
  String? userCardNumber; // Will store the masked card number

  // Firebase Database reference
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(), // Make sure Firebase is initialized
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  @override
  void initState() {
    super.initState();
    _loadUserCardInfo();
  }

  Future<void> _loadUserCardInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef =
          _database.child(currentUser.uid).child('cardInfo');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        String savedCard = snapshot.value as String;
        setState(() {
          userCardNumber = savedCard;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                // Plan Details Container
                _buildPlanDetails(),

                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Payment Method",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 20.h),
                _buildPaymentMethods(),

                SizedBox(height: 20.h),

                // Display Add Card or Card Info
                userCardNumber == null
                    ? _buildAddCardContainer()
                    : _buildCardInfo(),

                SizedBox(height: 50.h),
                RoundButton(
                  title: "Confirm Purchase",
                  onPress: () {
                    _confirmPurchase(); // Update Firebase with selected method
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentSuccessfulScreen()));
                  },
                ),
              ],
            ),
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
              Text(widget.planTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      fontSize: 24.sp)),
              SizedBox(height: 10.h),
              Text(widget.planDescription,
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Registration Fee",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          fontSize: 16.sp)),
                  Text("\$${widget.planAmount}",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16.sp,
                          color: AppColors.buttonColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Service Fee",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          fontSize: 16.sp)),
                  Text("\$20",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16.sp,
                          color: AppColors.buttonColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Discount",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          fontSize: 16.sp)),
                  Text("\$10",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16.sp,
                          color: AppColors.buttonColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Add Card Container if No Card is Saved
  Widget _buildAddCardContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(width: 2, color: AppColors.buttonColor),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentInfoScreen()))
                  .then((value) {
                if (value == true) {
                  _loadUserCardInfo(); // Reload card info when returning from PaymentInfoScreen
                }
              });
            },
            child: SvgPicture.asset('assets/images/add.svg',
                height: 45.h, width: 45.w),
          ),
          SizedBox(height: 10.h),
          Text("Add Card",
              style: TextStyle(
                  fontFamily: "Poppins",
                  color: AppColors.buttonColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Display Masked Card Info and Edit Icon
  Widget _buildCardInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Card: $userCardNumber",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentInfoScreen()))
                .then((value) {
              if (value == true) {
                _loadUserCardInfo(); // Reload card info after editing
              }
            });
          },
        ),
      ],
    );
  }

  // Build Payment Methods
  Widget _buildPaymentMethods() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPaymentMethodOption('Paypal', 'assets/images/paypal.svg'),
        _buildPaymentMethodOption('Stripe', 'assets/images/stripe.svg'),
      ],
    );
  }

  // Build a Single Payment Method Option
  Widget _buildPaymentMethodOption(String method, String assetPath) {
    return Container(
      width: 162.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2.w, color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(15.0.h),
                child: SvgPicture.asset(assetPath, height: 18, width: 18),
              ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(method,
              style: TextStyle(fontFamily: "Poppins", fontSize: 14.sp)),
          Radio<String>(
            value: method,
            groupValue: _selectedPaymentMethod,
            activeColor: Colors.red, // Active color set to red
            onChanged: (String? value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Handle Purchase Confirmation and Save Data to Firebase
  void _confirmPurchase() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Add log to see if button was clicked
    print("Confirm Purchase button clicked");

    if (currentUser != null) {
      print("User is logged in, proceeding to save data");

      // Save the selected payment method to Firebase
      await _database.child('Users').child(currentUser.uid).update({
        'paymentMethod': _selectedPaymentMethod,
        'paymentok': 'approved',
      });

      print("Payment method saved to Firebase");

      // Show success message
      Utils.toastMessage("Payment Successful", Colors.green);
    } else {
      print("No user logged in");

      // Show error if no user is logged in
      Utils.toastMessage("No user logged in", Colors.red);
    }
  }
}

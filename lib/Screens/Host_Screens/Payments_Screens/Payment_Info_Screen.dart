import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';

import 'Payment_Successful_Screen.dart';

class PaymentInfoScreen extends StatefulWidget {
   const PaymentInfoScreen({super.key});

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cardController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController countryController = TextEditingController(text: 'Pakistan');

  bool agreeTerms = false;
  bool saveCardInfo = false;

  final DatabaseReference _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(), // Make sure Firebase is initialized
      databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/')
      .ref();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              children: [
                // Heading and Back Button
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding:  EdgeInsets.all(15.0.h),
                          child: SvgPicture.asset(
                            'assets/images/back_arrow.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                      ),
                    ),
                     SizedBox(width: 20.w),
                    Text(
                      "Payment Information",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Palanquin Dark",
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h,),
                Image.asset(
                  "assets/images/credit_card.png",
                  height: 200.h,
                  width: 342.w,
                ),
                 SizedBox(height: 15.h),

                // Card Holder Name Field
                _buildTextField("Card Holder Name", nameController, "e.g. Mehtab"),
                 SizedBox(height: 10.h),

                // Card Number Field
                _buildCardNumberField(),
                 SizedBox(height: 10.h),

                // Expiry Date and CVV
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Exp Date", expiryDateController, "MM/YY"),
                    ),
                     SizedBox(width: 10.w),
                    Expanded(
                      child: _buildTextField("CVV Code", cvvController, "123"),
                    ),
                  ],
                ),
                 SizedBox(height: 10.h),

                // Country Field
                _buildTextField("Country", countryController, "Country"),

                // Terms and Save Card Info Checkboxes
                _buildCheckboxes(),
                RoundButton(
                  title: "Pay Now",
                  onPress: () async {
                    await _saveCardInfoToFirebase();  // Call to save card info
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  const PaymentSuccessfulScreen()),
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

  // Method to Build Standard TextFields
  Widget _buildTextField(String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 5.h,),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14.sp),
            border:  const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Build Card Number Field
  Widget _buildCardNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("Card Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        TextFormField(
          controller: cardController,
          decoration:  const InputDecoration(
            hintText: "************1234",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Build Checkboxes for Terms and Save Card Info
  Widget _buildCheckboxes() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: agreeTerms,
              onChanged: (value) {
                setState(() {
                  agreeTerms = value!;
                });
              },
              activeColor: Colors.red,
            ),
            Text("I agree to the terms and Conditions", style: TextStyle(fontSize: 16.sp,)),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: saveCardInfo,
              onChanged: (value) {
                setState(() {
                  saveCardInfo = value!;
                });
              },
              activeColor: Colors.red,
            ),
            Text("Save Card Info", style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ],
    );
  }

  Future<void> _saveCardInfoToFirebase() async {
    String cardNumber = cardController.text;

    User? currentUser = _auth.currentUser;  // Get the current user

    if (currentUser != null && cardNumber.isNotEmpty) {
      String uid = currentUser.uid; // Get the UID of the current user
      String maskedCardNumber = "************${cardNumber.substring(cardNumber.length - 4)}";

      print("UID: $uid");
      print("Masked Card Number: $maskedCardNumber");

      // Add card info under "Users/UID/cardInfo"
      await _database.child('Users').child(uid).child('cardInfo').set({
        'cardHolderName': nameController.text,
        'cardNumber': maskedCardNumber,
        'expiryDate': expiryDateController.text,
        'cvv': cvvController.text,
        'country': countryController.text,
      }).then((_) {
        print("Card information saved successfully.");
      Utils.toastMessage("Card information saved successfully", Colors.green);
      }).catchError((error) {
        print("Failed to save card info: $error");
       Utils.toastMessage(error.toString(), Colors.red);
      });
    } else {
      print("Invalid card number or user is not logged in.");
     Utils.toastMessage("Invalid card number or user is not logged in", Colors.red);
    }
  }
}

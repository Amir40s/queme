// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:queme/Screens/Host_Screens/Payments_Screens/Payment_Successful_Screen.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/config/stripe_keys.dart';

class PaymentProvider with ChangeNotifier {
  Map<String, dynamic>? paymentIntent;
  bool isPaymentSuccessful = false; // Variable to track payment success
  bool isLoading = false;

  void makePayment(
      BuildContext context, String price, String packageTitle) async {
    try {
      // STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
        price,
        'USD',
        'customer@example.com',
        'Charge for the app',
      );

      // STEP 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret:
                paymentIntent!['client_secret'], // Gotten from payment intent
            style: ThemeMode.light,
            merchantDisplayName: 'Queme'),
      );

      // STEP 3: Display Payment Sheet
      final isSuccess = await displayPaymentSheet(context);
      if (isSuccess) {
        isPaymentSuccessful = true;
        await updateUserPaymentInfo(price, packageTitle);
        Get.offAll(() => const PaymentSuccessfulScreen());
      } else {
        isPaymentSuccessful = false;
      }
    } catch (err) {
      isPaymentSuccessful = false;
      showSnackBar(
          context, 'Something went wrong, please try again', Colors.red);
      log('Payment Error: $err');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> createPaymentIntent(
    String amount,
    String currency,
    String email,
    String name,
  ) async {
    try {
      final price = calculateAmount(amount);

      // Request body
      final Map<String, dynamic> body = {
        'amount': price,
        'currency': currency,
        'description': name,
      };

      // Make post request to Stripe
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeKey.testSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<bool> displayPaymentSheet(BuildContext context) async {
    bool isSuccess = false;
    try {
      await Stripe.instance.presentPaymentSheet().then((result) {
        showSnackBar(context, 'Payment Successful', Colors.green);
        paymentIntent = null;
        isPaymentSuccessful = true;
        isSuccess = true;
      }).onError((error, stackTrace) {
        throw Exception('Payment failed: $error');
      });
      return isSuccess;
    } on StripeException catch (e) {
      log('Stripe Error: $e');
      isPaymentSuccessful = false;
      return false;
    } catch (e) {
      log('Error: $e');
      showSnackBar(context, 'Payment Canceled', Colors.red);
      isPaymentSuccessful = false; // Set to false if canceled
      return false;
    }
  }

  Future<void> updateUserPaymentInfo(String price, String packageTitle) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    try {
      isLoading = true;
      final userData = await getCurrentUserData();
      await dbRef.child('Users').child(userId).update({
        'plan': 'paid',
        'planPurchasedDate': DateTime.now().toString(),
        'planType': packageTitle,
        'planPrice': price,
        'userType': 'Host',
      });
      await dbRef.child('Payments').push().set({
        'userId': userId,
        'amount': price,
        'image': userData?['profileImageUrl'] ?? '',
        'name': userData?['name'] ?? '',
        'packageTitle': packageTitle,
        'createdAt': DateTime.now().toString(),
      });
      await dbRef
          .child('Admin')
          .child('-O9u-jOTpJUADfHdUH30')
          .child('Notifications')
          .push()
          .set({
        'title': 'Package purchased',
        'body': '${userData!['name']} purchased $packageTitle',
        'createdAt': DateTime.now().toString(),
      });
      log("User payment info updated successfully");
    } catch (e) {
      log("Error updating payment info: $e");
      throw Exception("Failed to update payment info");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateFreeTrialPaymentInfo(String title) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    try {
      isLoading = true;
      final userData = await getCurrentUserData();
      await dbRef.child('Users').child(userId).update({
        'freeTrialStart': DateTime.now().toString(),
        'plan': 'paid',
        'planType': title,
        'userType': 'Host',
      });
      await dbRef.child('Payments').push().set({
        'userId': userId,
        'amount': 0,
        'image': userData?['profileImageUrl'] ?? '',
        'name': userData?['name'] ?? '',
        'packageTitle': 'Free Trial',
        'createdAt': DateTime.now().toString(),
      });
      await dbRef
          .child('Admin')
          .child('-O9u-jOTpJUADfHdUH30')
          .child('Notifications')
          .push()
          .set({
        'title': 'Package purchased',
        'body': '${userData!['name']} purchased Free Trial',
        'createdAt': DateTime.now().toString(),
      });

      Get.offAll(() => const PaymentSuccessfulScreen());
      log("User payment info updated successfully");
    } catch (e) {
      log("Error updating payment info: $e");
      throw Exception("Failed to update payment info");
    }
    isLoading = false;
    notifyListeners();
  }

  String calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }

  void showSnackBar(BuildContext context, String text, Color color) {
    Utils.toastMessage(text, color);
  }
}

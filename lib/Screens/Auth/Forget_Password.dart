import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailController = TextEditingController();

  // Function to send reset password email
  Future<void> sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      Utils.toastMessage("Password reset email sent", Colors.green);
      Navigator.pop(context);
    } catch (e) {
     Utils.toastMessage(e.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forget Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please Enter your Email',
                style: TextStyle(fontSize: 24.sp),
              ),
              Padding(
                padding: EdgeInsets.all(20.0.h),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              RoundButton(
                title: "Submit",
                onPress: () {
                  sendPasswordResetEmail(); // Trigger the password reset email
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

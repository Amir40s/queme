import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Utils/Utils.dart';
import '../../Widgets/colors.dart';
import '../../Widgets/round_button.dart';
import 'Login_Screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  String? _userType;  // This will hold the selected user type


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();


  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(), // Make sure Firebase is initialized
      databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/'
  ).ref();


  bool isLoading = false;

  // Disposing controllers and focus nodes
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _obscurePassword.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  // Validation for name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  // Validation for email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validation for password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validation for confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Function to handle user registration
  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Save user data in Firebase Realtime Database
          await _database.child('Users').child(user.uid).set({
            'uid': user.uid,
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(), // Optionally store password (hashing recommended)
            'userType': _userType ?? "Participant",  // Save the user type, default to "Participant" if not selected
          });

          // Navigate to login screen after successful registration
          Utils.toastMessage("Register Successfully", Colors.green);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      } on FirebaseAuthException catch (e) {
        Utils.toastMessage(e.toString(), Colors.red);
        setState(() {
          isLoading = false;
        });
        // Handle Firebase authentication errors
        String errorMessage = 'Registration failed';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 30.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      "Create Your Account",
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Palanquin Dark'),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/dog_logo.svg',
                      height: 72.h,
                      width: 72.w,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                        fontSize: 14.sp),
                    decoration: InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(
                      //     vertical: 20.h, horizontal: 10.w),
                      suffixIcon: Icon(Icons.account_circle_rounded, size: 24.sp),
                      border: const OutlineInputBorder(),
                      hintText: "Enter Name",
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateName,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(emailFocusNode);
                    },
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14.sp),
                    decoration: InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(
                      //     vertical: 16.h, horizontal: 10.w),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.email_outlined, size: 24),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Enter Email",
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    validator: validateEmail,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ValueListenableBuilder(
                    valueListenable: _obscurePassword,
                    builder: (context, value, child) {
                      return TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword.value,
                        obscuringCharacter: '*',
                        focusNode: passwordFocusNode,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 14.sp),
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.symmetric(
                          //     vertical: 16.h, horizontal: 10.w),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                _obscurePassword.value =
                                !_obscurePassword.value;
                              },
                              child: Icon(
                                _obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 24.h,
                              ),
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          hintText: "Enter Password",
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        validator: validatePassword,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ValueListenableBuilder(
                    valueListenable: _obscurePassword,
                    builder: (context, value, child) {
                      return TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscurePassword.value,
                        obscuringCharacter: '*',
                        focusNode: confirmPasswordFocusNode,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 18.sp),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16.h, horizontal: 10.w),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                _obscurePassword.value =
                                !_obscurePassword.value;
                              },
                              child: Icon(
                                _obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 24.h,
                              ),
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        validator: validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "User Type",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Host',
                              groupValue: _userType,
                              onChanged: (String? value) {
                                setState(() {
                                  _userType = value;
                                });
                              },
                            ),
                            SizedBox(width: 5.w), // Space between Radio and Text
                            Text(
                              'Host',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Participant',
                              groupValue: _userType,
                              onChanged: (String? value) {
                                setState(() {
                                  _userType = value;
                                });
                              },
                            ),
                            SizedBox(width: 5.w), // Space between Radio and Text
                            Text(
                              'Participant',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  isLoading
                      ? const CircularProgressIndicator()
                      : RoundButton(
                    title: "Register",
                    onPress: () {
                      registerUser();
                    },
                  ),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins'),
                          ),
                          Text(
                            " Login ",
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.buttonColor,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins'),
                          ),
                          Text(
                            "here",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )

    );
  }
}

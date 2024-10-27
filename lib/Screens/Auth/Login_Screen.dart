import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:queme/Screens/Host_Screens/Host_Dashboard/host_bottom_nav.dart';
import 'package:queme/Widgets/colors.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import '../../Utils/Utils.dart';
import '../../Widgets/round_button2.dart';
import '../Host_Screens/Host_Dashboard/Host_Dashboard.dart';
import '../Host_Screens/Payments_Screens/Payment_Plans_Screen.dart';
import '../Partcipants_Screens/Participent_BottomNav.dart';
import 'Forget_Password.dart';
import 'Register_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  // Login with Google
  Future<void> _loginWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _saveUserDataToDatabase(
          userCredential.user, googleUser.displayName ?? 'Google User');
      Utils.toastMessage("Login Successful", Colors.green);
      _navigateBasedOnUserType(userCredential.user);
    } catch (e) {
      print(e.toString());
      Utils.toastMessage(e.toString(), Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save or update user data to Firebase Realtime Database
  Future<void> _saveUserDataToDatabase(User? user, String displayName) async {
    if (user != null) {
      DatabaseEvent event =
          await _database.child('Users').child(user.uid).child('MyDogs').once();

      Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      Map<String, dynamic> myDogs = {};

      if (data != null) {
        data.forEach((key, value) {
          myDogs[key] = {
            'imageUrl': value['imageUrl'],
            'name': value['name'],
          };
        });
      }

      // Now save the user data along with 'MyDogs'
      await _database.child('Users').child(user.uid).set({
        'name': displayName,
        'email': user.email,
        'uid': user.uid,
        'profileImageUrl': user.photoURL,
        'MyDogs': myDogs, // Save the fetched and processed 'MyDogs' data
        'userType': 'Participant', // Default user type if not specified
      });
    }
  }

  // Login with Facebook
  Future<void> _loginWithFacebook() async {
    setState(() {
      isLoading = true;
    });
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        UserCredential userCredential =
            await _auth.signInWithCredential(facebookAuthCredential);
        await _saveUserDataToDatabase(userCredential.user, 'Facebook User');
        _navigateBasedOnUserType(userCredential.user);
      } else {
        Utils.toastMessage(result.message.toString(), Colors.red);
      }
    } catch (e) {
      Utils.toastMessage(e.toString(), Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> _navigateBasedOnUserType(User? user) async {
    if (user == null) return;

    try {
      DatabaseReference userRef = _database.child('Users').child(user.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        String userType = userData['userType'] ?? 'Participant';
        String paymentStatus = userData['paymentok'] ?? 'pending';

        if (userType == 'Host' && paymentStatus == 'approved') {
          Get.offAll(() => HostBottomNav());
        } else if (userType == 'Participant') {
          Get.offAll(() => ParticipentBottomNav());
        } else {
          Get.offAll(() => PaymentPlansScreen());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Payment not approved. Please complete the payment.')),
          );
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loginWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        _navigateBasedOnUserType(userCredential.user);
        Utils.toastMessage("Login Successful", Colors.green);
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed';
        if (e.code == 'user-not-found') {
          errorMessage = 'User not found';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        }
        Utils.toastMessage(errorMessage.toString(), Colors.red);
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 28.w, vertical: 40.h), // Adjusted padding
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        fontSize:
                            24.sp, // Adjusted with .sp for responsive text size
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h), // Adjusted space
                  Center(
                    child: Text(
                      "Access your account securely. Sign in to manage your personalized experience",
                      style: TextStyle(
                        fontSize: 14.sp, // Adjusted font size
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  SvgPicture.asset('assets/images/dog_logo.svg',
                      height: 72.h, width: 146.w), // Adjusted size
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Email",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold), // Adjusted text size
                    decoration: InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w), // Adjusted padding
                      suffixIcon: Icon(Icons.email_outlined, size: 24.sp),
                      border: const OutlineInputBorder(),
                      hintText: "Enter email",
                    ),
                    validator: validateEmail,
                    onFieldSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(passwordFocusNode),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Password",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight:
                                FontWeight.bold)), // Adjusted text size),
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold), // Adjusted text size
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.h,
                              horizontal: 10.w), // Adjusted padding
                          suffixIcon: InkWell(
                            onTap: () {
                              _obscurePassword.value = !_obscurePassword.value;
                            },
                            child: Icon(
                                _obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 24.sp),
                          ),
                          border: const OutlineInputBorder(),
                          hintText: "Enter Password",
                        ),
                        validator: validatePassword,
                        textInputAction: TextInputAction.done,
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPassword(),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("Forgot Password",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  isLoading
                      ? const CircularProgressIndicator()
                      : RoundButton(
                          title: "Log In",
                          onPress: () => _loginWithEmailPassword(),
                        ),
                  SizedBox(height: 10.h),
                  RoundButton2(
                    title: "Register",
                    onPress: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen())),
                  ),
                  SizedBox(height: 20.h),
                  SvgPicture.asset(
                    'assets/images/cwith.svg',
                    height: 60.h,
                    width: 90.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: _loginWithGoogle,
                        child: SvgPicture.asset(
                          'assets/images/google.svg',
                          height: 48.h,
                          width: 48.w,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                          onTap: _loginWithFacebook,
                          child: SvgPicture.asset(
                            'assets/images/facebook.svg',
                            height: 48.h,
                            width: 48.w,
                          )),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                        Text(
                          " Register ",
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                        Text(
                          "here",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

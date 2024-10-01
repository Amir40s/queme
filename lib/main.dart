import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add this import
import 'package:queme/Widgets/colors.dart';
import 'Screens/Auth/Splash_Screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.playIntegrity,
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Integrate ScreenUtil
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light().copyWith(
              primary: Colors.red,
            ),
            scaffoldBackgroundColor: AppColors.whiteColor,
            fontFamily: 'Palanquin Dark',
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: 18.0.sp),
              bodyMedium: TextStyle(fontSize: 16.0.sp),
              displayLarge: TextStyle(fontSize: 30.0.sp),
              displayMedium: TextStyle(fontSize: 24.0.sp),
            ),
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.red, // Apply color to buttons
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: child, // Use child here to maintain consistency
        );
      },
      child: const SplashScreen(), // Your SplashScreen as the initial screen
    );
  }
}

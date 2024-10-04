import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:queme/Widgets/colors.dart';
import 'package:queme/provider/eventProvider.dart';
import 'Screens/Auth/Splash_Screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('9e0e893c-a777-4670-b0e6-8bfd077f7b46');
  OneSignal.Notifications.requestPermission(true);
  // SendNotification().generateDeviceId();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EventProvider>(create: (_) => EventProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              colorScheme: const ColorScheme.light().copyWith(
                primary: Colors.red,
              ),
              appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
              scaffoldBackgroundColor: AppColors.whiteColor,
              fontFamily: 'Palanquin Dark',
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: 18.0),
                bodyMedium: TextStyle(fontSize: 16.0),
                displayLarge: TextStyle(fontSize: 30.0),
                displayMedium: TextStyle(fontSize: 24.0),
              ),
              buttonTheme: const ButtonThemeData(
                buttonColor: Colors.red,
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: child,
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}

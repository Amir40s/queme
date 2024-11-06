import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Partcipants_Screens/Profile_Screen/Profile_Screen.dart';
import 'package:queme/Widgets/colors.dart';
import 'package:queme/config/stripe_keys.dart';
import 'package:queme/provider/appLifeCycleProvider.dart';
import 'package:queme/provider/eventProvider.dart';
import 'package:queme/provider/paymentProvider.dart';
import 'Screens/Auth/Splash_Screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = StripeKey.testPublishKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AppLifeCycleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: Consumer<AppLifeCycleProvider>(
        builder: (context, _, __) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return GetMaterialApp(
                theme: ThemeData(
                  colorScheme: const ColorScheme.light().copyWith(
                    primary: Colors.red,
                  ),
                  appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
                  scaffoldBackgroundColor: AppColors.whiteColor,
                  fontFamily: 'Palanquin Dark',
                  textTheme: const TextTheme(
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
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:queme/Screens/Host_Screens/Host_Dashboard/host_bottom_nav.dart';
import 'package:queme/Utils/Utils.dart';
import 'Login_Screen.dart';
import '../Partcipants_Screens/Participent_BottomNav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DatabaseReference userRef =
          _database.child('Users').child(currentUser.uid);
      DataSnapshot snapshot = await userRef.get();

      bool isDateInPast(String dateString) {
        DateTime date = DateTime.parse(dateString);
        DateTime currentDate = DateTime.now();
        return date.isBefore(currentDate);
      }

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        // Check if the user is blocked
        bool isBlocked = userData['deleted'] ?? false;

        if (isBlocked) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
          Utils.toastMessage(
              'Your account has been blocked by the admin.', Colors.red);
          return;
        }

        String plan = userData['plan'] ?? 'free';
        final date = DateTime.now();
        bool isPlanEnd = userData['planEndDate'] != null
            ? !date.isBefore(
                DateTime.parse(userData['planEndDate']),
              )
            : true;
        bool dateInPast = userData['hostingEnd'] != null
            ? isDateInPast(userData['hostingEnd'])
            : false;
        bool isEventEmpty =
            int.parse(userData['eventCount'] ?? '0') <= 0 ? true : false;
        updateToken(currentUser.uid);
        if ((plan == 'paid') && (dateInPast || isPlanEnd || isEventEmpty)) {
          // Update the user's plan to "free" in Firebase
          await userRef.update({'plan': 'free'});
          plan = 'free'; // Update the local variable to reflect the change
        }

        if (plan == 'paid') {
          if (!dateInPast) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HostBottomNav()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HostBottomNav()),
            );
          }
        } else if (plan == 'free') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ParticipentBottomNav()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void updateToken(String id) async {
    final token = await FirebaseMessaging.instance.getToken();
    _database.child('Users').child(id).update({
      'token': token.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140101),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 390,
          width: 390,
        ),
      ),
    );
  }
}

bool isFreeTrialActive(String trialEndDateString) {
  DateTime trialEndDate = DateTime.parse(trialEndDateString);
  DateTime currentDate = DateTime.now();

  return currentDate.isBefore(trialEndDate);
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
              'You account have been blocked by the admin.', Colors.red);
          return;
        }

        String userType = userData['userType'] ?? 'Participant';
        String plan = userData['plan'] ?? 'free';

        if (plan == 'paid') {
          // updateToken(currentUser.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HostBottomNav()),
          );
        } else if (plan == 'free') {
          // updateToken(currentUser.uid);
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

  // void updateToken(String id) async {
  //   final token = await SendNotification().generateDeviceId();
  //
  //   _database.child('Users').child(id).update({
  //     'token': token.toString(),
  //   });
  // }

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

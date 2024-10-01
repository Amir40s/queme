import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Host_Screens/Host_Dashboard/Host_Dashboard.dart';
import 'Login_Screen.dart';
import '../Partcipants_Screens/Participent_BottomNav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Firebase Database reference
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(), // Use the already initialized Firebase app
    databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 3 seconds (splash screen duration)
    await Future.delayed(const Duration(seconds: 3));

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, now fetch user data from Firebase Realtime Database
      DatabaseReference userRef = _database.child('Users').child(currentUser.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        String userType = userData['userType'] ?? 'Participant'; // Default to 'Participant'
        String paymentStatus = userData['paymentok'] ?? 'pending'; // Default to 'pending'

        // Navigate based on userType and paymentok status
        if (userType == 'Host' && paymentStatus == 'approved') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HostDashboard()),
          );
        } else if (userType == 'Participant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ParticipentBottomNav()),
          );
        } else {
          // Handle unknown user type or pending payment
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // If user data doesn't exist, go to the LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // If the user is not logged in, navigate to the LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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

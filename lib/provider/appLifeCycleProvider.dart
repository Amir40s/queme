import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AppLifeCycleProvider with ChangeNotifier, WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isUserOnline = false;
  bool _isAppInBackground = false;

  AppLifeCycleProvider() {
    WidgetsBinding.instance.addObserver(this);
    _setUserOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setUserOnline() {
    if (!_isUserOnline) {
      print('User is online');
      User? user = _auth.currentUser;
      if (user != null) {
        _database.child('Users/${user.uid}').update({'isOnline': true});
        _isUserOnline = true;
      }
    }
  }

  void setUserOffline() {
    if (_isUserOnline) {
      print('User is offline');
      User? user = _auth.currentUser;
      if (user != null) {
        _database.child('Users/${user.uid}').update({'isOnline': false});
        _isUserOnline = false;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // When the app resumes, mark the user online
        _isAppInBackground = false;
        _setUserOnline();
        break;

      case AppLifecycleState.inactive:
        // When the app is inactive (transitioning), do nothing immediately
        _isAppInBackground = true;
        break;

      case AppLifecycleState.paused:
        // When the app is paused, start a delayed check
        _isAppInBackground = true;
        _handleAppPausedState();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // When the app is detached or hidden, set the user offline
        setUserOffline();
        break;
    }
  }

  // Function to handle the paused state with a delay
  void _handleAppPausedState() async {
    await Future.delayed(Duration(seconds: 5));
    if (_isAppInBackground) {
      // If the app is still in the background after the delay, set the user offline
      setUserOffline();
    }
  }
}

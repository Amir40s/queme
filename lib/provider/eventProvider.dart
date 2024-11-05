import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:queme/Screens/Host_Screens/Payments_Screens/Payment_Plans_Screen.dart';
import 'package:queme/Utils/Utils.dart';

class EventProvider with ChangeNotifier {
  List<String> _followingEventIds = [];
  bool _isLoading = false;
  List<String> _followingRunsIds = [];
  String _token = '';

  List<String> get followingEventIds => _followingEventIds;
  String get token => _token;
  List<String> get followingRunsIds => _followingRunsIds;
  bool get isLoading => _isLoading;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  void fetchFollowingEventIds() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference userFollowingEventsRef =
        _database.child("Users").child(userId).child("followingEvents");

    try {
      DataSnapshot snapshot = await userFollowingEventsRef.get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          followingEventIds.add(value['eventId']);
        });
        notifyListeners();
      } else {
        print("No events found");
      }
    } catch (error) {
      print("Error fetching event IDs: $error");
    }
  }

  void fetchFollowingRuneIds() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DatabaseReference userFollowingRunesRef =
        _database.child("Users").child(userId).child("followingRunes");

    try {
      DataSnapshot snapshot = await userFollowingRunesRef.get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          _followingRunsIds.add(value['runeId']);
        });
        notifyListeners();
      } else {
        print("No runes found");
      }
    } catch (error) {
      print("Error fetching rune IDs: $error");
    }
  }

  Future<void> unfollowEvent(String eventId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _isLoading = true;
      String uid = currentUser.uid;
      try {
        await _database
            .child("Users")
            .child(uid)
            .child("followingEvents")
            .child(eventId)
            .remove();
        _database
            .child("Events")
            .child(eventId)
            .child('Followers')
            .child(currentUser.uid)
            .remove();
        Utils.toastMessage("Unfollowed event successfully", Colors.green);
        followingEventIds.remove(eventId);
        _isLoading = false;
        notifyListeners();
      } on FirebaseException catch (e) {
        Utils.toastMessage("Error: ${e.message}", Colors.red);
      }
    }
  }

  Future<void> followEvent(
    String id,
    String name,
    String date,
    String location,
  ) async {
    try {
      _isLoading = true;
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _database
            .child("Users")
            .child(currentUser.uid)
            .child("followingEvents")
            .child(id)
            .set({
          'eventId': id,
          'eventName': name,
          'eventLocation': location,
          'eventStartDate': date,
        });
        _database
            .child("Events")
            .child(id)
            .child('Followers')
            .child(currentUser.uid)
            .set({
          'token': _token,
          'id': currentUser.uid,
        });
        _isLoading = false;
        followingEventIds.add(id);
        notifyListeners();
        Utils.toastMessage("You are now following this event", Colors.green);
      }
    } on FirebaseException catch (e) {
      Utils.toastMessage("Error: ${e.message}", Colors.red);
    }
  }

  Future<void> followRune(String runeId, String runeName, String runeStartDate,
      String runeLocation, String eventId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        String? userName = currentUser.displayName ?? currentUser.email;

        // Add rune to user's following list
        await _database
            .child("Users")
            .child(userId)
            .child("followingRunes")
            .child(runeId)
            .set({
          'runeId': runeId,
          'runeName': runeName,
          'runeStartDate': runeStartDate,
          'runeLocation': runeLocation,
          'eventId': eventId,
        });

        // Add user to the rune's followers list
        await _database
            .child("Events")
            .child(eventId)
            .child("Runes")
            .child(runeId)
            .child('Followers')
            .child(userId) // Use the userId as the key
            .set({
          'token': _token,
          'id': userId,
        });

        _followingRunsIds.add(runeId);
        notifyListeners();
        Utils.toastMessage(
            "You are now following rune $runeName", Colors.green);
      }
    } on FirebaseException catch (e) {
      Utils.toastMessage("Error: ${e.message}", Colors.red);
    }
  }

  Future<void> unfollowRuns(String id, String eventId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        // Remove the rune from the user's following list
        await _database
            .child("Users")
            .child(uid)
            .child("followingRunes")
            .child(id)
            .remove();

        // Remove the user from the rune's followers list
        await _database
            .child("Events")
            .child(eventId)
            .child("Runes")
            .child(id)
            .child('Followers')
            .child(uid) // Use the userId as the key
            .remove();

        _followingRunsIds.remove(id);
        notifyListeners();
        Utils.toastMessage("Unfollowed run successfully", Colors.green);
      } on FirebaseException catch (e) {
        Utils.toastMessage("Error: ${e.message}", Colors.red);
      }
    }
  }

  void fetchUserToken() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        DataSnapshot snapshot =
            await _database.child("Users").child(uid).child("token").get();

        if (snapshot.exists) {
          _token = (snapshot.value as String?)!;
        }
        notifyListeners();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void changeUserType(String type) {
    _database
        .child('Users')
        .child(_auth.currentUser!.uid)
        .update({'userType': type});
  }

  void addPayment(PackageModel model, String name, String image) {
    User? currentUser = _auth.currentUser;
    _database.child('Payments').push().set(
      {
        'title': model.title,
        'price': model.price,
        'image': image,
        'name': name,
        'createdAt': DateTime.now().toString(),
      },
    );
    _database.child('Users').child(currentUser!.uid).update({
      "paymentok": "approved",
    });
  }

  getCurrentUserData() async {
    User? currentUser = _auth.currentUser;
    DatabaseReference userRef =
        _database.child('Users').child(currentUser!.uid);
    DataSnapshot snapshot = await userRef.get();
    Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

    return userData;
  }
}

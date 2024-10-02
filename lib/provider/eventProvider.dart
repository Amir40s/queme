import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:queme/Utils/Utils.dart';

class EventProvider with ChangeNotifier {
  List<String> _followingEventIds = [];
  bool _isLoading = false;
  List<String> _followingRunsIds = [];

  List<String> get followingEventIds => _followingEventIds;
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
      String id, String name, String date, String location) async {
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
      String runeLocation) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _database
            .child("Users")
            .child(currentUser.uid)
            .child("followingRunes")
            .child(runeId)
            .set({
          'runeId': runeId,
          'runeName': runeName,
          'runeStartDate': runeStartDate,
          'runeLocation': runeLocation
        });
        _followingRunsIds.add(runeId);
        notifyListeners();
        Utils.toastMessage("You are now following run $runeName", Colors.green);
        _database.child("Events").child("followingRunes").child(runeId).set({
          'runeId': runeId,
          'runeName': runeName,
          'runeStartDate': runeStartDate,
          'runeLocation': runeLocation
        });
      }
    } on FirebaseException catch (e) {
      Utils.toastMessage("Error: ${e.message}", Colors.red);
    }
  }

  Future<void> unfollowRuns(String id) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        await _database
            .child("Users")
            .child(uid)
            .child("followingRunes")
            .child(id)
            .remove();
        _followingRunsIds.remove(id);
        notifyListeners();
        Utils.toastMessage("Unfollowed run successfully", Colors.green);
      } on FirebaseException catch (e) {
        Utils.toastMessage("Error: ${e.message}", Colors.red);
      }
    }
  }

  void changeUserType(String type) {
    _database
        .child('Users')
        .child(_auth.currentUser!.uid)
        .update({'userType': type});
  }
}

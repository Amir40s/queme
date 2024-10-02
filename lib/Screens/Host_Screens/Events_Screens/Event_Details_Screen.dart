import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Create_Runes_Screen.dart';
import 'Host_Runs_Screen.dart';
import '../../../Widgets/colors.dart';
import '../../../Widgets/runes_button.dart';
import '../../../Widgets/runes_button2.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventLocation;
  final String eventStartDate;

  EventDetailsScreen({
    required this.eventId,
    required this.eventName,
    required this.eventLocation,
    required this.eventStartDate,
  });

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<Map<String, dynamic>> runesList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  @override
  void initState() {
    super.initState();
    _fetchRunes();
  }

  // Function to fetch runes for the current event
  void _fetchRunes() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      _database
          .child("Users")
          .child(uid)
          .child("Events")
          .child(widget.eventId)
          .child("Runes")
          .onValue
          .listen((event) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> loadedRunes = [];

        if (data != null) {
          data.forEach((key, value) {
            loadedRunes.add({
              'runeId': key,
              'runeName': value['runeName'],
              'runeLocation': value['runeLocation'],
              'runeStartDate': value['runeStartDate'],
            });
          });
        }

        setState(() {
          runesList = loadedRunes;
        });
      });
    }
  }

  // Function to delete a rune from Firebase
  Future<void> _deleteRune(String runeId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Deleting the rune from the Firebase Realtime Database
      await _database
          .child("Users")
          .child(uid)
          .child("Events")
          .child(widget.eventId)
          .child("Runes")
          .child(runeId)
          .remove();

      // Refresh the page by re-fetching the runes
      setState(() {
        _fetchRunes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRunesScreen(
                eventId: widget.eventId,
              ),
            ),
          );
        },
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: const Center(child: Icon(Icons.add)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(15.0.h),
                      child: SvgPicture.asset(
                        'assets/images/back_arrow.svg',
                        height: 24.h,
                        width: 24.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  "Event Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Palanquin Dark",
                    fontSize: 16.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Event Name",
                style: TextStyle(
                  fontSize: 16.h,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Palanquin Dark',
                ),
              ),
            ),
            SizedBox(height: 5.h),
            TextFormField(
              initialValue: widget.eventName,
              style: TextStyle(fontSize: 16.h, color: Colors.black),
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date",
                  style: TextStyle(
                    fontSize: 16.h,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Palanquin Dark',
                  ),
                ),
                SizedBox(height: 5.h),
                TextFormField(
                  initialValue: widget.eventStartDate,
                  style: TextStyle(fontSize: 16.h, color: Colors.black),
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Location",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Palanquin Dark',
                ),
              ),
            ),
            SizedBox(height: 5.h),
            TextFormField(
              initialValue: widget.eventLocation,
              style: TextStyle(fontSize: 16.sp, color: Colors.black),
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              "Runs",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Palanquin Dark',
                  color: AppColors.buttonColor),
            ),
            SizedBox(height: 10.h),
            Divider(
              thickness: 3,
              color: AppColors.buttonColor,
            ),
            Expanded(
              child: runesList.isNotEmpty
                  ? ListView.builder(
                      itemCount: runesList.length,
                      itemBuilder: (context, index) {
                        var rune = runesList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rune['runeName'] ?? 'No name',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month, size: 24.h),
                                    SizedBox(width: 5.w),
                                    Text("${rune['runeStartDate']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp)),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 20.h),
                                    SizedBox(width: 5.w),
                                    Text(rune['runeLocation'] ?? 'No location',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                RunesButton(
                                    title: "Start Run",
                                    onPress: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HostRunsScreen(
                                            eventId: widget.eventId,
                                            runeId: rune['runeId'],
                                            runeName: rune['runeName'],
                                          ),
                                        ),
                                      );
                                    }),
                                SizedBox(height: 10.h),
                                RunesButton2(
                                  title: "End Run",
                                  onPress: () async {
                                    final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Are you sure?'),
                                            content: Text(
                                                'This will end the run and delete the rune. Are you sure?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: Text('Yes'),
                                              ),
                                            ],
                                          );
                                        });

                                    if (result == true) {
                                      await _deleteRune(rune['runeId']);
                                    }
                                  },
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever_outlined, size: 70.h),
                        const Center(child: Text('No Runs Created Yet')),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}

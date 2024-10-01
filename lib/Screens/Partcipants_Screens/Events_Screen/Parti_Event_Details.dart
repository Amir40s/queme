import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';

import '../../../Widgets/colors.dart';
import '../../../Widgets/follow_button.dart';
import '../../../Widgets/runes_button.dart';
import '../../../Widgets/runes_button2.dart';
import 'Rune_Details_Screen.dart';

class PartiEventDetails extends StatefulWidget {
  final String eventId; // Add eventId to the constructor
  final String eventName;
  final String eventLocation;
  final String eventStartDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventEndDate;
  const PartiEventDetails({
    required this.eventId,
    required this.eventName,
    required this.eventLocation,
    required this.eventStartDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventEndDate,
});

  @override
  State<PartiEventDetails> createState() => _PartiEventDetailsState();
}

class _PartiEventDetailsState extends State<PartiEventDetails> {
  List<Map<String, dynamic>> runesList = []; // To store runes data
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/').ref();

  @override
  void initState() {
    super.initState();
    _fetchRunes(); // Fetch runes when the screen is initialized
  }

  // Function to fetch runes for the current event
  void _fetchRunes() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid; // Fetch the current user's UID

      // Fetch runes under the specific event for the current user
      _database
          .child("Events")
          .child(widget.eventId) // Correct path to eventId
          .child("Runes")
          .onValue
          .listen((event) {
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> loadedRunes = [];

        if (data != null) {
          data.forEach((key, value) {
            loadedRunes.add({
              'runeId': key,
              'runeName': value['runeName'],
              'runeLocation': value['runeLocation'],
              'runeStartDate': value['runeStartDate'],
              'runeEndDate': value['runeEndDate'],
              'runeStartTime': value['runeStartTime'],
              'runeEndTime': value['runeEndTime'],
            });
          });
        }

        setState(() {
          runesList = loadedRunes;
        });
      });
    }
  }

  // Function to save the event data to Firebase
  Future<void> _followEvent() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        DatabaseReference followingEventsRef = _database.child("Users").child(uid).child("followingEvents").child(widget.eventId);

        await followingEventsRef.set({
          'eventId': widget.eventId,
          'eventName': widget.eventName,
          'eventLocation': widget.eventLocation,
          'eventStartDate': widget.eventStartDate,
        });
        Utils.toastMessage("You are now following this event", Colors.green);
      }
    } on FirebaseException catch (e) {
      Utils.toastMessage("Error: ${e.message}", Colors.red);
    }
  }

  // Function to follow the rune
  Future<void> _followRune(String runeId, String runeName) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        DatabaseReference followingRunesRef = _database.child("Users").child(uid).child("followingRunes").child(runeId);

        await followingRunesRef.set({
          'runeId': runeId,
          'runeName': runeName,
        });
        Utils.toastMessage("You are now following rune $runeName", Colors.green);
      }
    } on FirebaseException catch (e) {
      Utils.toastMessage("Error: ${e.message}", Colors.red);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 20.w, vertical: 30.h),
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
                      padding: const EdgeInsets.all(15.0),
                      child: SvgPicture.asset(
                        'assets/images/back_arrow.svg',
                        height: 24.h,
                        width: 24.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5.h),
                Text(
                  "Event Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Palanquin Dark",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FollowButton(title: "Follow", onPress: (){
                  _followEvent();
                }),
              ],
            ),
            SizedBox(height: 15.h),
            // Displaying event details
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Event Name",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Palanquin Dark',
                ),
              ),
            ),
             SizedBox(height: 5.h),
            TextFormField(
              initialValue: widget.eventName,
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
             SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Starts",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Palanquin Dark',
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        initialValue: widget.eventStartDate,
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
                    ],
                  ),
                ),
                 SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ends",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Palanquin Dark',
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        initialValue: widget.eventEndDate,
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
                    ],
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
            const SizedBox(
              height: 20,
            ),
            Text(
              "Runs",
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Palanquin Dark',
                  color: AppColors.buttonColor),
            ),
             SizedBox(height: 10.h,),
             Divider(
              thickness: 3.w,
              color: AppColors.buttonColor,
            ),
            // Fetch and display runes here
            Expanded(
              child: runesList.isNotEmpty
                  ? ListView.builder(
                itemCount: runesList.length,
                itemBuilder: (context, index) {
                  var rune = runesList[index];
                  return Container(
                    margin:  EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
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
                      padding:  EdgeInsets.all(8.0.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rune['runeName'] ?? 'No name',
                            style: TextStyle(
                              fontSize: 20.h,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                           SizedBox(height: 5.h),
                          Row(
                            children: [
                               Icon(Icons.calendar_month, size: 24.h),
                               SizedBox(width: 5.w),
                              Text("${rune['runeStartDate']} - ${rune['runeStartTime']}",style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 16.sp),),
                              const Spacer(),
                              FollowButton(title: "Follow", onPress:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RuneDetailScreen(
                                  runeId: rune['runeId'],
                                  runeName: rune['runeName'],
                                )));
                              })
                            ],
                          ),
                           SizedBox(height: 5.h),
                          Row(
                            children: [
                               Icon(Icons.location_on_outlined, size: 24.h),
                               SizedBox(width: 5.w),
                              Text(rune['runeLocation'] ?? 'No location',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 16.sp),),
                            ],
                          ), // Row(
                          //   children: [
                          //     const Icon(Icons.timelapse, size: 20),
                          //     const SizedBox(width: 5),
                          //     Text("${rune['runeStartTime']} - ${rune['runeEndTime']}"),
                          //   ],
                          // ),
                           SizedBox(height: 10.h,),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_outlined, size: 24.h),
                  const Center(child: Text('No Runs Created Yet')),
                ],
              ),
            ),
            RoundButton(title: "Follow this Event", onPress: (){
              _followEvent();
            }),
          ],
        ),
      ),
    );
  }
}

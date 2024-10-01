// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:queme/Widgets/round_button.dart';
//
// class FollowingEventsScreen extends StatefulWidget {
//   @override
//   _FollowingEventsScreenState createState() => _FollowingEventsScreenState();
// }
//
// class _FollowingEventsScreenState extends State<FollowingEventsScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _database = FirebaseDatabase.instanceFor(
//       app: Firebase.app(),
//       databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/').ref();
//
//   List<Map<String, dynamic>> _followingEvents = []; // To store followed events
//   bool _isLoading = true; // For loading state
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchFollowingEvents();
//   }
//
//   // Function to fetch followed events from Firebase
//   Future<void> _fetchFollowingEvents() async {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       String uid = currentUser.uid;
//
//       // Fetch following events from the database
//       _database.child("Users").child(uid).child("followingEvents").onValue.listen((event) {
//         Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
//         List<Map<String, dynamic>> loadedEvents = [];
//
//         if (data != null) {
//           data.forEach((key, value) {
//             loadedEvents.add({
//               'eventId': key,
//               'eventName': value['eventName'],
//               'eventLocation': value['eventLocation'],
//               'eventStartDate': value['eventStartDate'],
//             });
//           });
//         }
//
//         setState(() {
//           _followingEvents = loadedEvents;
//           _isLoading = false;
//         });
//       });
//     }
//   }
//
//   // Function to unfollow an event (removing from Firebase)
//   Future<void> _unfollowEvent(String eventId) async {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       String uid = currentUser.uid;
//
//       await _database.child("Users").child(uid).child("followingEvents").child(eventId).remove();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Unfollowed the event')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
//             : _followingEvents.isNotEmpty
//             ? Expanded(
//           child: ListView.builder(
//             itemCount: _followingEvents.length,
//             itemBuilder: (ctx, index) {
//               var event = _followingEvents[index];
//               return GestureDetector(
//                 onTap: () {
//                   // Handle tap on event
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.grey.shade200,
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(8.h),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           event['eventName'],
//                           style: TextStyle(
//                             fontSize: 20.h,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                         SizedBox(height: 5.h),
//                         Row(
//                           children: [
//                             Icon(Icons.calendar_month, size: 24.h),
//                             SizedBox(width: 5.w),
//                             Text("${event['eventStartDate']}",
//                                 style: TextStyle(
//                                     fontSize: 12.h,
//                                     fontWeight: FontWeight.bold)),
//                             const Spacer(),
//                             RoundButton(
//                               title: "Unfollow",
//                               onPress: () {
//                                 _unfollowEvent(event['eventId']);
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 5.h),
//                         Row(
//                           children: [
//                             Icon(Icons.location_on_outlined, size: 24.h),
//                             SizedBox(width: 5.w),
//                             Text(event['eventLocation'],
//                                 style: TextStyle(
//                                     fontSize: 12.h,
//                                     fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                         SizedBox(height: 5.h),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         )
//             : const Center(child: Text('No events found')),
//       ),
//     );
//   }
// }

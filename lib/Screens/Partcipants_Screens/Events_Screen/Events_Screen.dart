import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Widgets/runes_button.dart';

import '../../../Widgets/follow_button.dart';
import 'Parti_Event_Details.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents(); // Fetch events when the page loads
    _searchController.addListener(_filterEvents); // Add listener for search functionality
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  void _filterEvents() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((event) {
        return event['eventName'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  Future<void> _fetchEvents() async {
    _database.child("Events").onValue.listen((event) {
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Map<String, dynamic>> loadedEvents = [];
        data.forEach((key, value) {
          loadedEvents.add({
            'eventId': key,
            'eventName': value['eventName'],
            'eventLocation': value['eventLocation'],
            'eventStartDate': value['eventStartDate'],
            'eventEndDate': value['eventEndDate'],
            'eventStartTime': value['eventStartTime'],
            'eventEndTime': value['eventEndTime'],
          });
        });
        setState(() {
          _events = loadedEvents;
          _filteredEvents = loadedEvents; // Initially, all events are shown
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.only(top: 20.h),
              child: Text(
                "Events",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            // Search bar
            // Container(
            //   height: 55.h,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.5),
            //         spreadRadius: 2,
            //         blurRadius: 7,
            //         offset: const Offset(0, 3),
            //       ),
            //     ],
            //   ),
            //   child: Padding(
            //     padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            //     child: TextFormField(
            //       controller: _searchController,
            //       keyboardType: TextInputType.text,
            //       decoration: InputDecoration(
            //         border: InputBorder.none,
            //         hintText: "Search Events",
            //         hintStyle:  TextStyle(
            //           fontSize: 14.sp,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.grey,
            //           fontFamily: 'Poppins',
            //         ),
            //         suffixIcon:  Icon(Icons.search, size: 24.h),
            //       ),
            //     ),
            //   ),
            // ),
             SizedBox(height: 30.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upcoming Events",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            // Expanded widget to show the list of events
            Expanded(
              child: _filteredEvents.isNotEmpty
                  ? ListView.builder(
                itemCount: _filteredEvents.length,
                itemBuilder: (ctx, index) {
                  var event = _filteredEvents[index];
                  return GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      margin:  EdgeInsets.only(bottom: 20.h),
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
                        padding:  EdgeInsets.all(8.0.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['eventName'],
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                             SizedBox(height: 5.h),
                            Row(
                              children: [
                                 Icon(Icons.calendar_month, size: 24.h),
                                 SizedBox(width: 5.w),
                                Text("${event['eventStartDate']}",style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.bold),),
                                const Spacer(),
                                FollowButton(title: "Follow Event", onPress: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PartiEventDetails(
                                        eventId: event['eventId'] ?? '', // Add default value if null
                                        eventName: event['eventName'] ?? 'Unknown Event', // Default to a non-null string
                                        eventLocation: event['eventLocation'] ?? 'No Location', // Default to a non-null string
                                        eventStartDate: event['eventStartDate'] ?? 'No Start Date', // Default value
                                        eventStartTime: event['eventStartTime'] ?? '', // Default value
                                        eventEndTime: event['eventEndTime'] ?? '', // Default value
                                        eventEndDate: event['eventEndDate'] ?? '', // Default value
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                             SizedBox(height: 5.h),
                            Row(
                              children: [
                                 Icon(Icons.location_on_outlined, size: 24.h),
                                 SizedBox(width: 5.w),
                                Text(event['eventLocation'],style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.bold)),
                              ],
                            ),
                             SizedBox(height: 5.h),
                            // Row(
                            //   children: [
                            //     const Icon(Icons.timelapse, size: 20),
                            //     const SizedBox(width: 5),
                            //     Text("${event['eventStartTime']} - ${event['eventEndTime']}"),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : const Center(child: Text('No events found')),
            ),
             SizedBox(height: 20.h,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ongoing Events",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: _filteredEvents.isNotEmpty
                  ? ListView.builder(
                itemCount: _filteredEvents.length,
                itemBuilder: (ctx, index) {
                  var event = _filteredEvents[index];
                  return GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.h),
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
                        padding: EdgeInsets.all(8.0.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['eventName'],
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                             SizedBox(height: 5.h),
                            Row(
                              children: [
                                 Icon(Icons.calendar_month, size: 24.h),
                                 SizedBox(width: 5.w),
                                Text("${event['eventStartDate']}",style: TextStyle(fontSize:12.sp,fontWeight: FontWeight.bold)),
                                const Spacer(),
                                FollowButton(title: "Follow Event", onPress: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PartiEventDetails(
                                        eventId: event['eventId'] ?? '', // Add default value if null
                                        eventName: event['eventName'] ?? 'Unknown Event', // Default to a non-null string
                                        eventLocation: event['eventLocation'] ?? 'No Location', // Default to a non-null string
                                        eventStartDate: event['eventStartDate'] ?? 'No Start Date', // Default value
                                        eventStartTime: event['eventStartTime'] ?? '', // Default value
                                        eventEndTime: event['eventEndTime'] ?? '', // Default value
                                        eventEndDate: event['eventEndDate'] ?? '', // Default value
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                 Icon(Icons.location_on_outlined, size: 24.h),
                                const SizedBox(width: 5),
                                Text(event['eventLocation'],style: TextStyle(fontSize:12.sp,fontWeight: FontWeight.bold)),
                              ],
                            ),
                             SizedBox(height: 5.h),
                            // Row(
                            //   children: [
                            //     const Icon(Icons.timelapse, size: 20),
                            //     const SizedBox(width: 5),
                            //     Text("${event['eventStartTime']} - ${event['eventEndTime']}"),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : const Center(child: Text('No events found')),
            ),
             SizedBox(height: 20.h,),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Runs your're following",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}

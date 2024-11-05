import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:queme/Screens/Partcipants_Screens/Participent_BottomNav.dart';
import '../../../Widgets/round_button.dart';
import '../../Auth/Login_Screen.dart';
import '../../Notifications/notifications_screen.dart';
import '../Events_Screens/Add_New_Event.dart';
import '../Events_Screens/Event_Details_Screen.dart';

class HostDashboard extends StatefulWidget {
  const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddNewEvent()));
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
                SvgPicture.asset(
                  'assets/images/dog_logo.svg',
                  height: 44.h,
                  width: 44.w,
                ),
                SizedBox(width: 10.w),
                Text(
                  "QUEME",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Palanquin Dark",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsScreen()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(15.0.h),
                      child: SvgPicture.asset(
                        'assets/images/bell.svg',
                        height: 20.h,
                        width: 20.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
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
                padding: const EdgeInsets.only(left: 10),
                child: TextFormField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Events",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                    suffixIcon: Icon(Icons.search, size: 24.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                    currentUser != null
                        ? StreamBuilder(
                            stream: _database
                                .child("Events")
                                .orderByChild("ownerId")
                                .equalTo(currentUser.uid)
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  (snapshot.data!).snapshot.value != null) {
                                Map<dynamic, dynamic> data = (snapshot.data!)
                                    .snapshot
                                    .value as Map<dynamic, dynamic>;

                                List<Map<String, dynamic>> filteredEvents =
                                    data.entries
                                        .map((entry) => {
                                              'eventId': entry.key,
                                              'eventName':
                                                  entry.value['eventName'],
                                              'eventLocation':
                                                  entry.value['eventLocation'],
                                              'eventStartDate':
                                                  entry.value['eventStartDate'],
                                              'eventEndDate':
                                                  entry.value['eventEndDate'],
                                            })
                                        .where((event) {
                                  DateFormat dateFormat =
                                      DateFormat('dd MMM yyyy');
                                  DateTime eventStartDate =
                                      dateFormat.parse(event['eventStartDate']);
                                  DateTime now = DateTime.now();
                                  DateTime today =
                                      DateTime(now.year, now.month, now.day);

                                  return eventStartDate.isAfter(today);
                                }).toList();

                                return filteredEvents.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: filteredEvents.length,
                                        itemBuilder: (ctx, index) {
                                          var event = filteredEvents[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventDetailsScreen(
                                                    eventId:
                                                        event['eventId'] ?? '',
                                                    eventName:
                                                        event['eventName'] ??
                                                            'Unknown',
                                                    eventLocation: event[
                                                            'eventLocation'] ??
                                                        'No Location',
                                                    eventStartDate: event[
                                                            'eventStartDate'] ??
                                                        'No Start Date',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey.shade200,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event['eventName'],
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 20.h),
                                                        SizedBox(width: 5.w),
                                                        Text(
                                                            "${event['eventStartDate']}"),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 20.h),
                                                        SizedBox(width: 5.w),
                                                        Text(
                                                          event[
                                                              'eventLocation'],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(top: 15),
                                        child: Center(
                                            child: Text(
                                                'No upcoming events found')),
                                      );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_forever_outlined,
                                          size: 24.h),
                                      const Text('No Events Created Yet'),
                                    ],
                                  ),
                                );
                              }
                            },
                          )
                        : const Center(
                            child: Text("Please log in to view events"),
                          ),
                    SizedBox(height: 20.h),
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
                    currentUser != null
                        ? StreamBuilder(
                            stream: _database
                                .child("Events")
                                .orderByChild("ownerId")
                                .equalTo(currentUser.uid)
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  (snapshot.data!).snapshot.value != null) {
                                Map<dynamic, dynamic> data = (snapshot.data!)
                                    .snapshot
                                    .value as Map<dynamic, dynamic>;

                                List<Map<String, dynamic>> filteredEvents =
                                    data.entries
                                        .map((entry) => {
                                              'eventId': entry.key,
                                              'eventName':
                                                  entry.value['eventName'],
                                              'eventLocation':
                                                  entry.value['eventLocation'],
                                              'eventStartDate':
                                                  entry.value['eventStartDate'],
                                              'eventEndDate':
                                                  entry.value['eventEndDate'],
                                            })
                                        .where((event) {
                                  DateFormat dateFormat =
                                      DateFormat('dd MMM yyyy');
                                  DateTime eventStartDate =
                                      dateFormat.parse(event['eventStartDate']);
                                  DateTime now = DateTime.now();
                                  DateTime today =
                                      DateTime(now.year, now.month, now.day);
                                  return eventStartDate.year == today.year &&
                                      eventStartDate.month == today.month &&
                                      eventStartDate.day == today.day;
                                }).toList();

                                return filteredEvents.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: filteredEvents.length,
                                        itemBuilder: (ctx, index) {
                                          var event = filteredEvents[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventDetailsScreen(
                                                    eventId:
                                                        event['eventId'] ?? '',
                                                    eventName:
                                                        event['eventName'] ??
                                                            'Unknown',
                                                    eventLocation: event[
                                                            'eventLocation'] ??
                                                        'No Location',
                                                    eventStartDate: event[
                                                            'eventStartDate'] ??
                                                        'No Start Date',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey.shade200,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event['eventName'],
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 20.h),
                                                        SizedBox(width: 5.w),
                                                        Text(
                                                            "${event['eventStartDate']}"),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 20.h),
                                                        SizedBox(width: 5.w),
                                                        Text(
                                                          event[
                                                              'eventLocation'],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(top: 15),
                                        child: Center(
                                            child: Text(
                                                'No ongoing events found')),
                                      );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_forever_outlined,
                                          size: 24.h),
                                      const Text('No Events Created Yet'),
                                    ],
                                  ),
                                );
                              }
                            },
                          )
                        : const Center(
                            child: Text("Please log in to view events"),
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RoundButton(
          title: "Back to participant",
          onPress: () {
            _database.child('Users').child(_auth.currentUser!.uid).update({
              'userType': 'Participant',
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const ParticipentBottomNav()),
            );
          },
        ),
      ),
    );
  }
}

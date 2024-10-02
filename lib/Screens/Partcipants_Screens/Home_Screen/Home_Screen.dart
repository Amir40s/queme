import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Notifications/notifications_screen.dart';
import 'package:queme/Widgets/follow_button.dart';
import 'package:queme/provider/eventProvider.dart';
import '../Events_Screen/Parti_Event_Details.dart';
import '../Events_Screen/Rune_Details_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  void initState() {
    super.initState();
    Provider.of<EventProvider>(context, listen: false).fetchFollowingEventIds();
    Provider.of<EventProvider>(context, listen: false).fetchFollowingRuneIds();
    _searchController.addListener(() {
      setState(() {}); // Triggers the UI update for search functionality
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Consumer<EventProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/dog_logo.svg',
                    height: 44.h,
                    width: 89.36.w,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "QUEME",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Palanquin Dark",
                      fontSize: 20.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // SendNotification()
                      //     .sendNotification('Hello There my name is fahad');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsScreen()),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SvgPicture.asset(
                          'assets/images/bell.svg',
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search bar
              Container(
                height: 48.h,
                width: double.infinity,
                decoration: BoxDecoration(
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
                  padding: EdgeInsets.only(left: 10.w),
                  child: TextFormField(
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Events",
                      hintStyle: TextStyle(
                        fontSize: 15.h,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                      suffixIcon: Icon(Icons.search, size: 24.h),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Upcoming Events",
                          style: TextStyle(
                            fontSize: 16.h,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: _database.child("Events").onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              (snapshot.data! as DatabaseEvent)
                                      .snapshot
                                      .value !=
                                  null) {
                            Map<dynamic, dynamic> data =
                                (snapshot.data! as DatabaseEvent).snapshot.value
                                    as Map<dynamic, dynamic>;

                            List<Map<String, dynamic>> loadedEvents =
                                data.entries
                                    .map((entry) => {
                                          'eventId': entry.key,
                                          'eventName': entry.value['eventName'],
                                          'eventLocation':
                                              entry.value['eventLocation'],
                                          'eventStartDate':
                                              entry.value['eventStartDate'],
                                        })
                                    .toList();

                            // Filter for future events
                            DateFormat dateFormat = DateFormat('dd MMM yyyy');
                            DateTime today = DateTime.now();

                            List<Map<String, dynamic>> futureEvents =
                                loadedEvents.where((event) {
                              DateTime eventStartDate =
                                  dateFormat.parse(event['eventStartDate']);
                              return eventStartDate.isAfter(today);
                            }).toList();

                            // Filter by search term
                            String searchTerm =
                                _searchController.text.toLowerCase();
                            List<Map<String, dynamic>> filteredEvents =
                                futureEvents
                                    .where((event) => event['eventName']
                                        .toString()
                                        .toLowerCase()
                                        .contains(searchTerm))
                                    .toList();

                            return ListView.builder(
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
                                        builder: (context) => PartiEventDetails(
                                          eventId: event['eventId'] ?? '',
                                          eventName: event['eventName'] ??
                                              'Unknown Event',
                                          eventLocation:
                                              event['eventLocation'] ??
                                                  'No Location',
                                          eventStartDate:
                                              event['eventStartDate'] ??
                                                  'No Start Date',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['eventName'],
                                            style: TextStyle(
                                              fontSize: 20.h,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(height: 5.h),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month,
                                                  size: 24.h),
                                              SizedBox(width: 5.w),
                                              Text("${event['eventStartDate']}",
                                                  style: TextStyle(
                                                      fontSize: 12.h,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Spacer(),
                                              FollowButton(
                                                title: provider
                                                        .followingEventIds
                                                        .contains(
                                                            event['eventId'])
                                                    ? "Unfollow"
                                                    : "Follow Event",
                                                onPress: () {
                                                  provider.followingEventIds
                                                          .contains(
                                                              event['eventId'])
                                                      ? provider.unfollowEvent(
                                                          event['eventId'])
                                                      : provider.followEvent(
                                                          event['eventId'],
                                                          event['eventName'],
                                                          event[
                                                              'eventStartDate'],
                                                          event[
                                                              'eventLocation']);
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.h),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  size: 24.h),
                                              SizedBox(width: 5.w),
                                              Text(
                                                event['eventLocation'],
                                                style: TextStyle(
                                                    fontSize: 12.h,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(top: 30.h),
                              child:
                                  const Center(child: Text('No events found')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Runs you're following",
                          style: TextStyle(
                            fontSize: 16.h,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: _database
                            .child("Users")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .child("followingRunes")
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              (snapshot.data! as DatabaseEvent)
                                      .snapshot
                                      .value !=
                                  null) {
                            Map<dynamic, dynamic> data =
                                (snapshot.data! as DatabaseEvent).snapshot.value
                                    as Map<dynamic, dynamic>;

                            List<Map<String, dynamic>> loadedRuns = data.entries
                                .map((entry) => {
                                      'runeId': entry.key,
                                      'runeName': entry.value['runeName'],
                                      'runeStartDate':
                                          entry.value['runeStartDate'],
                                      'runeLocation':
                                          entry.value['runeLocation'],
                                    })
                                .toList();

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: loadedRuns.length,
                              itemBuilder: (ctx, index) {
                                var rune = loadedRuns[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RuneDetailScreen(
                                          runeId: rune['runeId'],
                                          runeName: rune['runeName'],
                                          runeLocation: rune['runeLocation'],
                                          startingDate: rune['runeStartDate'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 20.h),
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
                                      padding: EdgeInsets.all(8.0.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                              _buildRuneDetailRow(
                                                  Icons.calendar_month,
                                                  "${rune['runeStartDate']}"),
                                              SizedBox(height: 5.h),
                                              _buildRuneDetailRow(
                                                  Icons.location_on_outlined,
                                                  rune['runeLocation'] ??
                                                      'No location'),
                                              SizedBox(height: 10.h),
                                            ],
                                          ),
                                          FollowButton(
                                            title: provider.followingRunsIds
                                                    .contains(rune['runeId'])
                                                ? "Unfollow"
                                                : "Follow",
                                            onPress: () {
                                              provider.followingRunsIds
                                                      .contains(rune['runeId'])
                                                  ? provider.unfollowRuns(
                                                      rune['runeId'])
                                                  : provider.followRune(
                                                      rune['runeId'],
                                                      rune['runeName'],
                                                      rune['runeLocation'],
                                                      rune['runeStartDate']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(top: 30.h),
                              child: const Center(child: Text('No runs found')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRuneDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24.h),
        SizedBox(width: 5.w),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ],
    );
  }
}

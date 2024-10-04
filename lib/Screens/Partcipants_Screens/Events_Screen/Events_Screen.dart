import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/provider/eventProvider.dart';
import '../../../Widgets/follow_button.dart';
import 'Parti_Event_Details.dart';
import 'Rune_Details_Screen.dart';

class EventsScreen extends StatelessWidget {
  EventsScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();
  final DatabaseReference _events =
      FirebaseDatabase.instance.ref().child("Events");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventProvider>(builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  "Events",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
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
                      StreamBuilder<DatabaseEvent>(
                        stream: _events.onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Map<dynamic, dynamic>? data = snapshot
                                .data!.snapshot.value as Map<dynamic, dynamic>?;

                            if (data != null) {
                              List<Map<String, dynamic>> events = [];
                              DateFormat dateFormat = DateFormat(
                                  'dd MMM yyyy'); // Format used in Firebase

                              // Current date (today) to compare with
                              DateTime today = DateTime.now();

                              // Filter events that are in the future or tomorrow
                              data.forEach((key, value) {
                                String eventDateString =
                                    value['eventStartDate'];
                                DateTime eventDate =
                                    dateFormat.parse(eventDateString);

                                if (eventDate.isAfter(today)) {
                                  events.add({
                                    'eventId': key,
                                    'eventName': value['eventName'],
                                    'eventLocation': value['eventLocation'],
                                    'eventStartDate': value['eventStartDate'],
                                  });
                                }
                              });

                              return events.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: events.length,
                                      itemBuilder: (ctx, index) {
                                        var event = events[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PartiEventDetails(
                                                  eventId:
                                                      event['eventId'] ?? '',
                                                  eventName:
                                                      event['eventName'] ??
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
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.calendar_month,
                                                          size: 24),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${event['eventStartDate']}",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Spacer(),
                                                      FollowButton(
                                                        title: provider
                                                                .followingEventIds
                                                                .contains(event[
                                                                    'eventId'])
                                                            ? "Unfollow"
                                                            : "Follow Event",
                                                        onPress: () {
                                                          provider.followingEventIds
                                                                  .contains(event[
                                                                      'eventId'])
                                                              ? provider
                                                                  .unfollowEvent(
                                                                      event[
                                                                          'eventId'])
                                                              : provider.followEvent(
                                                                  event[
                                                                      'eventId'],
                                                                  event[
                                                                      'eventName'],
                                                                  event[
                                                                      'eventStartDate'],
                                                                  event[
                                                                      'eventLocation']);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 24),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                          event[
                                                              'eventLocation'],
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Center(
                                          child:
                                              Text('No future events found')),
                                    );
                            } else {
                              return const Center(
                                  child: Text('No events found'));
                            }
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching data'));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
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
                      StreamBuilder<DatabaseEvent>(
                        stream: _events.onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Map<dynamic, dynamic>? data = snapshot
                                .data!.snapshot.value as Map<dynamic, dynamic>?;

                            if (data != null) {
                              List<Map<String, dynamic>> events = [];
                              data.forEach(
                                (key, value) {
                                  String eventDateString =
                                      value['eventStartDate'];
                                  if (eventDateString == Utils().todayDate()) {
                                    events.add(
                                      {
                                        'eventId': key,
                                        'eventName': value['eventName'],
                                        'eventLocation': value['eventLocation'],
                                        'eventStartDate':
                                            value['eventStartDate'],
                                      },
                                    );
                                  }
                                },
                              );

                              return events.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: events.length,
                                      itemBuilder: (ctx, index) {
                                        var event = events[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PartiEventDetails(
                                                  eventId:
                                                      event['eventId'] ?? '',
                                                  eventName:
                                                      event['eventName'] ??
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
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.calendar_month,
                                                          size: 24),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${event['eventStartDate']}",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Spacer(),
                                                      FollowButton(
                                                        title: provider
                                                                .followingEventIds
                                                                .contains(event[
                                                                    'eventId'])
                                                            ? "Unfollow"
                                                            : "Follow Event",
                                                        onPress: () {
                                                          provider.followingEventIds
                                                                  .contains(event[
                                                                      'eventId'])
                                                              ? provider
                                                                  .unfollowEvent(
                                                                      event[
                                                                          'eventId'])
                                                              : provider.followEvent(
                                                                  event[
                                                                      'eventId'],
                                                                  event[
                                                                      'eventName'],
                                                                  event[
                                                                      'eventStartDate'],
                                                                  event[
                                                                      'eventLocation']);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 24),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                          event[
                                                              'eventLocation'],
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Center(
                                          child: Text(
                                              'No events found for today')),
                                    );
                            } else {
                              return const Center(
                                  child: Text('No events found'));
                            }
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching data'));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
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
                              (snapshot.data!).snapshot.value != null) {
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
                                      'eventId': entry.value['eventId'],
                                    })
                                .toList();

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                                          eventId: rune['eventId'] ?? '',
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
                                                      rune['runeId'],
                                                      rune['eventId'])
                                                  : provider.followRune(
                                                      rune['runeId'],
                                                      rune['runeName'],
                                                      rune['runeLocation'],
                                                      rune['runeStartDate'],
                                                      rune['eventId']);
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
                            return const CircularProgressIndicator();
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
          ),
        );
      }),
    );
  }

  Widget _buildRuneDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24.h),
        SizedBox(width: 5.w),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queme/Screens/Notifications/services/fcm_service.dart';
import '../../../Utils/Utils.dart';
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
  const EventDetailsScreen({
    super.key,
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
  List<Map<String, String>> followers = [];
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  @override
  void initState() {
    super.initState();
    fetchFollowersTokens();
    _fetchRunes();
  }

  Future<void> sendNotification(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController notificationC = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Message to event followers'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Message cannot be empty';
                          }
                          return null;
                        },
                        controller: notificationC,
                        decoration: const InputDecoration(labelText: 'Message'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Send'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    Utils.toastMessage(
                        "Message sent to all followers", Colors.green);
                    DatabaseReference newRef = _database
                        .child('Users')
                        .child(_auth.currentUser!.uid)
                        .child('Notifications')
                        .push();

                    for (var e in followers) {
                      _database
                          .child('Users')
                          .child(_auth.currentUser!.uid)
                          .child('Notifications')
                          .child(newRef.key!)
                          .set({
                        'title': '${widget.eventName} Event',
                        'body': notificationC.text.toString(),
                        'read': false,
                        'createdAt': DateTime.now().toString(),
                      });
                      FCMService().sendNotification(
                          e['token']!,
                          '${widget.eventName} Event',
                          notificationC.text.toString());
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void fetchFollowersTokens() async {
    try {
      DatabaseReference followersRef =
          _database.child("Events").child(widget.eventId).child("Followers");

      DataSnapshot snapshot = await followersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> followersMap =
            snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          followersMap.forEach((key, value) {
            String id = value['id'];
            String token = value['token'];
            followers.add({'id': id, 'token': token});
          });
        });
      }
    } catch (e) {
      print("Error fetching followers: $e");
    }
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
          data.forEach(
            (key, value) {
              loadedRunes.add(
                {
                  'runeId': key,
                  'runeName': value['runeName'],
                  'runeLocation': value['runeLocation'],
                  'runeStartDate': value['runeStartDate'],
                  'dogList': value['DogList'] ?? ''
                },
              );
            },
          );
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                IconButton(
                  onPressed: () {
                    sendNotification(context);
                  },
                  icon: const Icon(
                    Icons.notifications,
                  ),
                )
              ],
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        Text(
                          "Event Name:   ",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Palanquin Dark',
                          ),
                        ),
                        Text(
                          widget.eventName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontFamily: 'Palanquin Dark',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    SizedBox(height: 10.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Date:   ",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                            Text(
                              widget.eventStartDate,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Location:   ",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                            Text(
                              widget.eventLocation,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    const Text(
                      "Runs",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Palanquin Dark',
                          color: AppColors.buttonColor),
                    ),
                    SizedBox(height: 10.h),
                    const Divider(
                      thickness: 3,
                      color: AppColors.buttonColor,
                    ),
                    runesList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          Icon(Icons.calendar_month,
                                              size: 24.h),
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
                                          Text(
                                              rune['runeLocation'] ??
                                                  'No location',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      RunesButton(
                                          title: 'Run Details',
                                          onPress: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HostRunsScreen(
                                                  eventId: widget.eventId,
                                                  runeId: rune['runeId'],
                                                  runeName: rune['runeName'],
                                                  date: rune['runeStartDate'],
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
                                                  title: const Text(
                                                      'Are you sure?'),
                                                  content: const Text(
                                                      'This will end the run and delete the rune. Are you sure?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      child: const Text('Yes'),
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

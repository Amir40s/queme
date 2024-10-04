import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Host_Screens/Events_Screens/components/completed_dog_list_widget.dart';
import 'package:queme/Widgets/Not_CheckedIn.dart';
import 'package:queme/Widgets/colors.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/Widgets/round_button2.dart';
import 'package:queme/provider/eventProvider.dart';
import '../../../Utils/Utils.dart';
import '../../../Widgets/Clamed_Button.dart';
import '../../../Widgets/Upcoming_button.dart';
import '../../../Widgets/follow_button.dart';
import 'Claim_Dog_Screen.dart';

class RuneDetailScreen extends StatefulWidget {
  final String runeId;
  final String runeName;
  final String runeLocation;
  final String startingDate;
  final String eventId;
  const RuneDetailScreen(
      {required this.runeId,
      required this.runeName,
      super.key,
      required this.runeLocation,
      required this.startingDate,
      required this.eventId});

  @override
  State<RuneDetailScreen> createState() => _RuneDetailScreenState();
}

class _RuneDetailScreenState extends State<RuneDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> _dogsList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
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
        title: Text(
          widget.runeName,
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Palanquin Dark",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: UpcomingButton(
              title: widget.startingDate == Utils().todayDate()
                  ? "Ongoing"
                  : "Upcoming",
              onPress: () {},
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          labelStyle: TextStyle(
              fontFamily: "Palanquin Dark",
              fontSize: 18,
              fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Running'),
            Tab(text: 'Completed Dogs'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          return StreamBuilder(
                            stream: _database
                                .child("Events")
                                .child(widget.eventId)
                                .child("Runes")
                                .child(widget.runeId)
                                .child('DogList')
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.snapshot.value != null) {
                                List<dynamic> dataList = snapshot
                                    .data!.snapshot.value as List<dynamic>;
                                List<Map<String, dynamic>> dogs =
                                    dataList.asMap().entries.map((entry) {
                                  var dog =
                                      entry.value as Map<dynamic, dynamic>;
                                  return {
                                    'id': entry.key
                                        .toString(), // Use the index as the ID
                                    'breed': dog['breed'],
                                    'competitorName': dog['competitorName'],
                                    'dogName': dog['dogName'],
                                    'ownerName': dog['ownerName'],
                                    'imageUrl': dog['imageUrl'] ?? '',
                                    'claimed': dog['claimed'] ?? '',
                                  };
                                }).toList();

                                return dogs.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: dogs.length,
                                        itemBuilder: (context, index) {
                                          var dog = dogs[index];
                                          return dog['claimed'] == false
                                              ? Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 10.h),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  dog['dogName'] ??
                                                                      'Dog Name',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        "Palanquin Dark",
                                                                    fontSize:
                                                                        18.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5.w),
                                                                dog['imageUrl'] !=
                                                                        ''
                                                                    ? Container(
                                                                        height:
                                                                            34.h,
                                                                        width:
                                                                            34.w,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                NetworkImage(
                                                                              dog['imageUrl'] ?? '',
                                                                            ),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink()
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                dog['ownerName'] !=
                                                                        ''
                                                                    ? Text(
                                                                        dog['ownerName'],
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              "Palanquin Dark",
                                                                          fontSize:
                                                                              16.sp,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                              ],
                                                            ),
                                                            dog['breed'] != ''
                                                                ? Text(
                                                                    "Breed: ${dog['breed'] ?? 'Dog Breed'}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          "Palanquin Dark",
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  )
                                                                : SizedBox
                                                                    .shrink(),
                                                            dog['competitorName'] !=
                                                                    ''
                                                                ? Text(
                                                                    "Competitor #: ${dog['competitorName']}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          "Palanquin Dark",
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  )
                                                                : SizedBox
                                                                    .shrink()
                                                          ],
                                                        ),
                                                        ClamedButton(
                                                          title: "Claim",
                                                          bgColor: AppColors
                                                              .buttonColor,
                                                          textColor: AppColors
                                                              .whiteColor,
                                                          onPress: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ClaimDogScreen(
                                                                  eventId: widget
                                                                      .eventId,
                                                                  runeId: widget
                                                                      .runeId,
                                                                  dogId:
                                                                      dog['id'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : SizedBox.shrink();
                                        },
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 15),
                                        child: Center(
                                            child: Text('No Dogs Found')),
                                      );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_forever_outlined,
                                          size: 24.h),
                                      const Text('No Dogs Found'),
                                    ],
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    RoundButton(
                      onPress: () {
                        provider.followingRunsIds.contains(widget.runeId)
                            ? provider.unfollowRuns(
                                widget.runeId, widget.eventId)
                            : provider.followRune(
                                widget.runeId,
                                widget.runeName,
                                widget.runeLocation,
                                widget.startingDate,
                                widget.eventId);
                      },
                      title: provider.followingRunsIds.contains(widget.runeId)
                          ? "Unfollow the run"
                          : "Follow the run",
                    ),
                  ],
                ),
                Column(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          return StreamBuilder(
                            stream: _database
                                .child("Events")
                                .child(widget.eventId)
                                .child("Runes")
                                .child(widget.runeId)
                                .child('DogList')
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.snapshot.value != null) {
                                List<dynamic> dataList = snapshot
                                    .data!.snapshot.value as List<dynamic>;
                                List<Map<String, dynamic>> dogs = dataList
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      var dog =
                                          entry.value as Map<dynamic, dynamic>;
                                      return {
                                        'id': entry.key.toString(),
                                        'imgUrl': dog['imgUrl'] ?? '',
                                        'breed': dog['breed'],
                                        'competitorName': dog['competitorName'],
                                        'dogName': dog['dogName'],
                                        'ownerName': dog['ownerName'],
                                        'claimed': dog['claimed'] ??
                                            false, // Ensure claimed is a boolean
                                      };
                                    })
                                    .where((dog) => dog['claimed'] == true)
                                    .toList(); // Filter only claimed dogs

                                return dogs.isNotEmpty
                                    ? CompletedDogListWidget(
                                        list: dogs,
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 15),
                                        child: Center(
                                            child: Text('No Dogs Found')),
                                      );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_forever_outlined,
                                          size: 24.h),
                                      const Text('No Dogs Found'),
                                    ],
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    RoundButton(
                      onPress: () {
                        provider.followingRunsIds.contains(widget.runeId)
                            ? provider.unfollowRuns(
                                widget.runeId, widget.eventId)
                            : provider.followRune(
                                widget.runeId,
                                widget.runeName,
                                widget.runeLocation,
                                widget.startingDate,
                                widget.eventId);
                      },
                      title: provider.followingRunsIds.contains(widget.runeId)
                          ? "Unfollow the run"
                          : "Follow the run",
                    ),
                  ],
                ),

                // Padding(
                //   padding:
                //       EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                //   child: Column(
                //     children: [
                //       RoundButton(
                //         title: provider.followingRunsIds.contains(widget.runeId)
                //             ? "Unfollow the run"
                //             : "Follow the run",
                //         onPress: () {
                //           provider.followingRunsIds.contains(widget.runeId)
                //               ? provider.unfollowRuns(widget.runeId)
                //               : provider.followRune(
                //                   widget.runeId,
                //                   widget.runeName,
                //                   widget.runeLocation,
                //                   widget.startingDate);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

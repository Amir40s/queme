import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:queme/Widgets/Not_CheckedIn.dart';
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
  const RuneDetailScreen(
      {required this.runeId,
      required this.runeName,
      super.key,
      required this.runeLocation,
      required this.startingDate});

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
    _tabController = TabController(length: 2, vsync: this); // 2 tabs
    _fetchDogs();
  }

  Future<void> _fetchDogs() async {
    try {
      DatabaseEvent event = await _database.child('ClaimedDogs').once();
      if (event.snapshot.exists) {
        List<Map<String, String>> dogs = [];
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          dogs.add({
            'id': key,
            'name': value['name'] ?? '',
            'breed': value['breed'] ?? '',
            'imageUrl': value['imageUrl'] ?? '',
            'owner': value['owner'] ?? '',
          });
        });

        setState(() {
          _dogsList = dogs;
        });
      }
    } catch (e) {
      print('Error fetching claimed dogs: $e');
    }
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
            fontSize: 20.sp,
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
              fontSize: 18.sp,
              fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Running'),
            Tab(text: 'Completed Dogs'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: TabBarView(
            controller: _tabController,
            children: [
              _dogsList.isEmpty
                  ? Column(
                      children: [
                        Center(
                          child: Text(
                            "No Running Dogs",
                            style: TextStyle(
                              fontFamily: "Palanquin Dark",
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(height: 10.h),
                        RoundButton(title: "Follow the Run", onPress: () {}),
                        SizedBox(height: 10.h),
                        RoundButton2(
                          title: "Claim Your Dog",
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ClainDogScreen()),
                            );
                          },
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _dogsList.length,
                            itemBuilder: (context, index) {
                              final dog = _dogsList[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.shade200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            dog['name'] ?? 'Dog Name',
                                            style: TextStyle(
                                              fontFamily: "Palanquin Dark",
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5.w),
                                          Container(
                                            height: 34.h,
                                            width: 34.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    dog['imageUrl'] ?? ''),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            dog['owner'] ?? 'Owner Name',
                                            style: TextStyle(
                                              fontFamily: "Palanquin Dark",
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          ClamedButton(
                                            title: "Claimed",
                                            onPress: () {
                                              // Claim button functionality
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Breed: ${dog['breed'] ?? 'Dog Breed'}",
                                        style: TextStyle(
                                          fontFamily: "Palanquin Dark",
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Competitor #: ${index + 1}",
                                        style: TextStyle(
                                          fontFamily: "Palanquin Dark",
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        RoundButton(
                          onPress: () {
                            provider.followingRunsIds.contains(widget.runeId)
                                ? provider.unfollowRuns(widget.runeId)
                                : provider.followRune(
                                    widget.runeId,
                                    widget.runeName,
                                    widget.runeLocation,
                                    widget.startingDate);
                          },
                          title:
                              provider.followingRunsIds.contains(widget.runeId)
                                  ? "Unfollow the run"
                                  : "Follow the run",
                        ),
                        SizedBox(height: 10.h),
                        RoundButton2(
                          title: "Claim Your Dog",
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ClainDogScreen()),
                            );
                          },
                        ),
                      ],
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                child: Column(
                  children: [
                    RoundButton(
                      title: provider.followingRunsIds.contains(widget.runeId)
                          ? "Unfollow the run"
                          : "Follow the run",
                      onPress: () {
                        provider.followingRunsIds.contains(widget.runeId)
                            ? provider.unfollowRuns(widget.runeId)
                            : provider.followRune(
                                widget.runeId,
                                widget.runeName,
                                widget.runeLocation,
                                widget.startingDate);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/provider/eventProvider.dart';
import '../../../Widgets/colors.dart';
import '../../../Widgets/follow_button.dart';
import 'Rune_Details_Screen.dart';

class PartiEventDetails extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventLocation;
  final String eventStartDate;

  const PartiEventDetails({
    required this.eventId,
    required this.eventName,
    required this.eventLocation,
    required this.eventStartDate,
  });

  @override
  State<PartiEventDetails> createState() => _PartiEventDetailsState();
}

class _PartiEventDetailsState extends State<PartiEventDetails> {
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

  void _fetchRunes() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _database
          .child("Events")
          .child(widget.eventId)
          .child("Runes")
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> loadedRunes = [];

        if (data != null) {
          data.forEach((key, value) {
            loadedRunes.add({
              'runeId': key,
              'runeName': value['runeName'],
              'runeLocation': value['runeLocation'],
              'runeStartDate': value['runeStartDate'],
              'runeEndDate': value['runeEndDate'],
            });
          });
        }

        setState(() {
          runesList = loadedRunes;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Consumer<EventProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
                  FollowButton(
                    title: provider.followingEventIds.contains(widget.eventId)
                        ? "Unfollow"
                        : "Follow",
                    onPress: () {
                      provider.followingEventIds.contains(widget.eventId)
                          ? provider.unfollowEvent(widget.eventId)
                          : provider.followEvent(
                              widget.eventId,
                              widget.eventName,
                              widget.eventStartDate,
                              widget.eventLocation);
                    },
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              _buildEventDetail("Event Name", widget.eventName),
              SizedBox(height: 10.h),
              _buildEventDetail("Starts", widget.eventStartDate),
              SizedBox(height: 10.h),
              _buildEventDetail("Location", widget.eventLocation),
              const SizedBox(height: 20),
              Text(
                "Runs",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Palanquin Dark',
                  color: AppColors.buttonColor,
                ),
              ),
              SizedBox(height: 10.h),
              Divider(thickness: 3.w, color: AppColors.buttonColor),
              Expanded(
                child: runesList.isNotEmpty
                    ? ListView.builder(
                        itemCount: runesList.length,
                        itemBuilder: (context, index) {
                          final rune = runesList[index];
                          return _buildRuneCard(rune, provider);
                        },
                      )
                    : _buildNoRunsWidget(),
              ),
              RoundButton(
                title: provider.followingEventIds.contains(widget.eventId)
                    ? "Unfollow this Event"
                    : "Follow this Event",
                onPress: () {
                  provider.followingEventIds.contains(widget.eventId)
                      ? provider.unfollowEvent(widget.eventId)
                      : provider.followEvent(widget.eventId, widget.eventName,
                          widget.eventStartDate, widget.eventLocation);
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEventDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Palanquin Dark',
          ),
        ),
        SizedBox(height: 5.h),
        TextFormField(
          initialValue: value,
          style: TextStyle(fontSize: 16.sp, color: Colors.black),
          enabled: false,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuneCard(Map<String, dynamic> rune, EventProvider provider) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                  _buildRuneDetailRow(
                      Icons.calendar_month, "${rune['runeStartDate']}"),
                  SizedBox(height: 5.h),
                  _buildRuneDetailRow(Icons.location_on_outlined,
                      rune['runeLocation'] ?? 'No location'),
                  SizedBox(height: 10.h),
                ],
              ),
              FollowButton(
                title: provider.followingRunsIds.contains(rune['runeId'])
                    ? "Unfollow"
                    : "Follow",
                onPress: () {
                  provider.followingRunsIds.contains(rune['runeId'])
                      ? provider.unfollowRuns(rune['runeId'])
                      : provider.followRune(rune['runeId'], rune['runeName'],
                          rune['runeLocation'], rune['runeStartDate']);
                  // );
                },
              ),
            ],
          ),
        ),
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

  Widget _buildNoRunsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.delete_forever_outlined, size: 24.h),
        const Center(child: Text('No Runs Created Yet')),
      ],
    );
  }
}

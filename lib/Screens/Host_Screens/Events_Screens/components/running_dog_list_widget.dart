import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queme/Screens/Host_Screens/Events_Screens/bark_screen.dart';
import 'package:queme/Widgets/colors.dart';

import '../../../../Widgets/Excel_button.dart';

class RunningDogListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dogList;
  final String eventId, runeId, runeName;
  RunningDogListWidget({
    super.key,
    required this.dogList,
    required this.eventId,
    required this.runeId,
    required this.runeName,
  }) {
    // Initialize the ValueNotifier with the dogList
    _dogListNotifier.value = dogList;
  }

  final ValueNotifier<List<Map<String, dynamic>>> _dogListNotifier =
      ValueNotifier([]);
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _dogListNotifier,
      builder: (context, dogList, _) {
        return ReorderableListView(
          onReorder: (oldIndex, newIndex) {
            // If newIndex is greater than oldIndex, decrease newIndex by 1
            if (newIndex > oldIndex) newIndex -= 1;

            // Move the item in the local list
            final movedItem = dogList.removeAt(oldIndex);
            dogList.insert(newIndex, movedItem);

            // Update the order in Firebase
            _updateOrderInFirebase(dogList, eventId, runeId);

            // Notify listeners about the change
            _dogListNotifier.value = List.from(dogList);
          },
          children: dogList.asMap().entries.map((e) {
            final breed = e.value['breed'];
            final competitor = e.value['competitorName'];
            final dogName = e.value['dogName'];
            final owner = e.value['ownerName'];
            final dogId = e.value['id'];
            final checkedIn = e.value['checkedIn'];

            return RunningDogWidget(
              key: ValueKey(dogId), // Use a unique key for each item
              dogName: dogName,
              owner: owner,
              breed: breed,
              competitor: competitor,
              id: dogId,
              checkedIn: checkedIn,
              eventId: eventId,
              runeId: runeId,
              runeName: runeName,
            );
          }).toList(),
        );
      },
    );
  }

  // Method to update order in Firebase
  void _updateOrderInFirebase(List<Map<String, dynamic>> updatedDogList,
      String eventId, String runeId) {
    for (int index = 0; index < updatedDogList.length; index++) {
      final dogId = updatedDogList[index]['id'];
      _database
          .child('Events')
          .child(eventId)
          .child('Runes')
          .child(runeId)
          .child('DogList')
          .child(dogId)
          .update({
        'order': index,
      });
    }
  }
}

class RunningDogWidget extends StatefulWidget {
  const RunningDogWidget({
    super.key,
    required this.dogName,
    required this.owner,
    required this.breed,
    required this.competitor,
    required this.id,
    required this.checkedIn,
    required this.eventId,
    required this.runeId,
    required this.runeName,
  });

  final dynamic dogName;
  final dynamic owner;
  final dynamic breed;
  final dynamic competitor;
  final dynamic id;
  final dynamic checkedIn;
  final String eventId, runeId, runeName;

  @override
  State<RunningDogWidget> createState() => _RunningDogWidgetState();
}

class _RunningDogWidgetState extends State<RunningDogWidget> {
  bool showDetail = false;
  Timer? _timer; // Declare a Timer
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showDetail = !showDetail;

          if (showDetail) {
            // Start the timer when the detail is shown
            _startTimer();
          } else {
            // Cancel the timer if the detail is collapsed
            _cancelTimer();
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffE9E9E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: showDetail
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _database
                              .child('Events')
                              .child(widget.eventId)
                              .child('Runes')
                              .child(widget.runeId)
                              .child('DogList')
                              .child(widget.id)
                              .update({
                            'checkedIn':
                                !widget.checkedIn, // Toggle checkedIn state
                          });
                          setState(() {
                            showDetail = !showDetail;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              widget.checkedIn == true
                                  ? 'Unchecked'
                                  : 'Checked in',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.green[700],
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                        width: 20.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarkScreen(
                                dogName: widget.dogName,
                                ownerName: widget.owner ?? '',
                                eventId: widget.eventId,
                                runeId: widget.runeId,
                                runeName: widget.runeName,
                              ),
                            ),
                          );
                          setState(() {
                            showDetail = !showDetail;
                          });
                        },
                        child: Column(
                          children: [
                            SizedBox(
                              height: 25.h,
                              width: 25.w,
                              child: SvgPicture.asset(
                                'assets/images/dog.svg',
                                color: AppColors.buttonColor,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Bark',
                              style: TextStyle(
                                color: AppColors.buttonColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                        width: 20.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          _database
                              .child('Events')
                              .child(widget.eventId)
                              .child('Runes')
                              .child(widget.runeId)
                              .child('DogList')
                              .child(widget.id)
                              .update({
                            'checkedIn': true,
                            'claimed': true,
                          });
                          setState(() {
                            showDetail = !showDetail;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xff4CAF50),
                                shape: BoxShape.circle,
                              ),
                              height: 25.h,
                              width: 25.w,
                              child: SvgPicture.asset(
                                'assets/images/tick.svg',
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Complete',
                              style: TextStyle(
                                color: Color(0xff4CAF50),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Palanquin Dark',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.dogName,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      widget.owner != ''
                          ? Text(
                              'Owner: ${widget.owner}',
                              style: const TextStyle(fontSize: 15),
                            )
                          : const SizedBox.shrink(),
                      widget.breed != ''
                          ? Text(
                              'Breed: ${widget.breed}',
                              style: const TextStyle(fontSize: 14),
                            )
                          : const SizedBox.shrink(),
                      widget.competitor != ''
                          ? Text(
                              'Competitor #:${widget.competitor}',
                              style: const TextStyle(fontSize: 14),
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                  widget.checkedIn == true
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              'Checked in',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green[700],
                                  fontFamily: 'Palanquin Dark'),
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xffEED9BB),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Not Yet Checked In',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffFF9800),
                                  fontFamily: 'Palanquin Dark'),
                            ),
                          ),
                        )
                ],
              ),
      ),
    );
  }

  void _startTimer() {
    // Cancel any existing timer
    _cancelTimer();
    _timer = Timer(Duration(seconds: 4), () {
      setState(() {
        showDetail = false; // Collapse the widget after 5 seconds
      });
    });
  }

  void _cancelTimer() {
    _timer?.cancel(); // Cancel the timer if it exists
  }

  @override
  void dispose() {
    _cancelTimer(); // Ensure the timer is canceled when disposing
    super.dispose();
  }
}

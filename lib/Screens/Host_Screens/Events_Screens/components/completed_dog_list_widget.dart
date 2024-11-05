import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:queme/Widgets/colors.dart';

class CompletedDogListWidget extends StatelessWidget {
  const CompletedDogListWidget({
    super.key,
    required this.list,
    this.isEdit = false,
    required this.eventId,
    required this.runeId,
  });
  final List<Map<String, dynamic>> list;
  final bool isEdit;
  final String eventId, runeId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: list.asMap().entries.map(
          (e) {
            final name = e.value['dogName'];
            final img = e.value['imgUrl'];
            final owner = e.value['ownerName'];
            final dogId = e.value['id'];
            return CompletedDogWidget(
              name: name,
              img: img,
              owner: owner,
              isEdit: isEdit,
              eventId: eventId,
              runeId: runeId,
              dogId: dogId,
            );
          },
        ).toList(),
      ),
    );
  }
}

class CompletedDogWidget extends StatelessWidget {
  CompletedDogWidget({
    super.key,
    required this.name,
    required this.img,
    required this.owner,
    required this.isEdit,
    required this.eventId,
    required this.runeId,
    required this.dogId,
  });

  final dynamic name;
  final dynamic img;
  final dynamic owner;
  final bool isEdit;
  final String eventId, runeId, dogId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Name:  ',
                  style: TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                TextSpan(text: name),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          img != ''
              ? Container(
                  height: 32.h,
                  width: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: NetworkImage(img ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          SizedBox(width: 15.w),
          owner != ''
              ? Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Owner:  ',
                        style: TextStyle(
                            color: AppColors.buttonColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      TextSpan(text: owner),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          Spacer(),
          isEdit
              ? PopupMenuButton(
                  position: PopupMenuPosition.under,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  itemBuilder: (BuildContext context) {
                    return ['Back to running']
                        .map(
                          (e) => PopupMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList();
                  },
                  onSelected: (value) {
                    changeDogStatus();
                  },
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  void changeDogStatus() {
    _database
        .child('Events')
        .child(eventId)
        .child('Runes')
        .child(runeId)
        .child('DogList')
        .child(dogId)
        .update({
      'completed': false,
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Screens/Notifications/notifications_screen.dart';

Widget buildNotificationIcon() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return StreamBuilder(
    stream: FirebaseDatabase.instance
        .ref('Users/$uid/Notifications')
        .orderByChild('read')
        .equalTo(false)
        .onValue,
    builder: (context, snapshot) {
      int unreadCount = 0;
      if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
        Map data = snapshot.data!.snapshot.value as Map;
        unreadCount = data.length;
      }

      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(),
                ),
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
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

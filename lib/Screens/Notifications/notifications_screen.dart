import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Utils/Utils.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final auth = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    "Notifications",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Palanquin Dark",
                      fontSize: 17.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Expanded(
                  child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('Users')
                    .child(auth!.uid)
                    .child('Notifications')
                    .onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData &&
                      !snapshot.hasError &&
                      snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic> notificationsMap =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List notificationsList = notificationsMap.entries.toList();

                    return ListView.builder(
                      itemCount: notificationsList.length,
                      padding: EdgeInsets.only(top: 30.h),
                      itemBuilder: (context, index) {
                        var notification = notificationsList[index].value;
                        String title = notification['title'] ?? "No title";
                        String body = notification['body'] ?? "No body";
                        String createdAt = Utils().getTimeAgo(
                          DateTime.parse(
                            notification['createdAt'],
                          ),
                        );

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.h),
                                  height: 45.h,
                                  width: 45.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFFECCC),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/images/announcement.svg',
                                    color: Color(0xffFF7900),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                color: Color(0xff240046),
                                                fontFamily: "Palanquin Dark",
                                                fontSize: 18.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              body,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: "Palanquin Dark",
                                                fontSize: 16.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        createdAt,
                                        style: TextStyle(
                                          color: Color(0xffAAAFB6),
                                          fontFamily: "Palanquin Dark",
                                          fontSize: 16.h,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Divider(
                                color: Color(0xffE5E5E5),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text("No notifications available"));
                  }
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Utils/Utils.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final auth = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    markNotificationsAsRead();
  }

  void markNotificationsAsRead() {
    FirebaseDatabase.instance
        .ref('Users/${auth!.uid}/Notifications')
        .orderByChild('read')
        .equalTo(false)
        .once()
        .then(
      (DatabaseEvent event) {
        final snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach(
            (key, value) {
              FirebaseDatabase.instance
                  .ref('Users/${auth!.uid}/Notifications/$key')
                  .update({'read': true});
            },
          );
        }
      },
    );
  }

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

                    // Convert the map entries to a list
                    List notificationsList = notificationsMap.entries.toList();

                    // Sort the notifications by 'createdAt' in descending order
                    notificationsList.sort((a, b) {
                      DateTime dateA = DateTime.parse(a.value['createdAt']);
                      DateTime dateB = DateTime.parse(b.value['createdAt']);
                      return dateB.compareTo(dateA); // Newest first
                    });

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
                                    color: const Color(0xffFF7900),
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
                                                color: const Color(0xff240046),
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
                                          color: const Color(0xffAAAFB6),
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
                              child: const Divider(
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

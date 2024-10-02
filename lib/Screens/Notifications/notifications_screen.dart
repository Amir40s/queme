import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

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
                child: ListView.builder(
                  itemCount: 4,
                  padding: EdgeInsets.only(top: 30.h),
                  itemBuilder: (context, index) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Run details",
                                          style: TextStyle(
                                            color: Color(0xff240046),
                                            fontFamily: "Palanquin Dark",
                                            fontSize: 18.h,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "The run has been started, please visit the ",
                                          maxLines: 1,
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
                                    "1 min ago",
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

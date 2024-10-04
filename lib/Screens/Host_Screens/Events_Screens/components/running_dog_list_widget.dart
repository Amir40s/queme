import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Widgets/Excel_button.dart';

class RunningDogListWidget extends StatelessWidget {
  const RunningDogListWidget({super.key, required this.dogList});
  final List<Map<String, dynamic>> dogList;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: dogList.asMap().entries.map((e) {
          final breed = e.value['breed'];
          final competitor = e.value['competitorName'];
          final dogName = e.value['dogName'];
          final owner = e.value['ownerName'];
          return Container(
            margin: EdgeInsets.only(top: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffE9E9E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dogName,
                          style: TextStyle(fontSize: 18),
                        ),
                        // SizedBox(width: 5.w),
                        // Container(
                        //   height: 28.h,
                        //   width: 30.w,
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey,
                        //     borderRadius: BorderRadius.circular(5),
                        //     image: DecorationImage(
                        //       image: NetworkImage(dog['imageUrl'] ?? ''),
                        //       fit: BoxFit.cover,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    owner != ''
                        ? Text(
                            'Owner: $owner',
                            style: TextStyle(fontSize: 15),
                          )
                        : SizedBox.shrink(),
                    owner != ''
                        ? Text(
                            'Breed: $breed',
                            style: TextStyle(fontSize: 14),
                          )
                        : SizedBox.shrink(),
                    competitor != ''
                        ? Text(
                            'Competitor #:$competitor',
                            style: TextStyle(fontSize: 14),
                          )
                        : SizedBox.shrink()
                  ],
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10.w),
                //   decoration: BoxDecoration(
                //     color: Colors.green[100],
                //     borderRadius: BorderRadius.circular(5),
                //   ),
                //   height: size.height * 0.039,
                //   child: Center(
                //     child: Text(
                //       'Checked in',
                //       style: TextStyle(
                //           fontSize: 14.sp,
                //           fontWeight: FontWeight.w700,
                //           color: Colors.green[700],
                //           fontFamily: 'Palanquin Dark'),
                //     ),
                //   ),
                // ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Color(0xffEED9BB),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
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
          );
        }).toList(),
      ),
    );
  }
}

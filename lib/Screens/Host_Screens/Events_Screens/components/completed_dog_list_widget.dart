import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:queme/Widgets/colors.dart';

class CompletedDogListWidget extends StatelessWidget {
  const CompletedDogListWidget({super.key, required this.list});
  final List<Map<String, dynamic>> list;

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
            return Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
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
                            : SizedBox.shrink(),
                        SizedBox(width: 15.w),
                        owner != ''
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
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
                            : SizedBox.shrink()
                      ],
                    ),
                    Container(
                      height: 1,
                      color: AppColors.buttonColor,
                      width: double.infinity,
                    ),
                  ],
                ));
          },
        ).toList(),
      ),
    );
  }
}

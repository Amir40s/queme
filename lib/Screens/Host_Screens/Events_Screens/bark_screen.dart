import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/colors.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/Widgets/round_button2.dart';
import 'package:intl/intl.dart';

class BarkScreen extends StatefulWidget {
  const BarkScreen(
      {super.key,
      required this.dogName,
      required this.ownerName,
      required this.eventId,
      required this.runeId,
      required this.runeName});
  final String dogName, ownerName, eventId, runeId, runeName;

  @override
  State<BarkScreen> createState() => _BarkScreenState();
}

class _BarkScreenState extends State<BarkScreen> {
  List<Map<String, String>> followers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController msgController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  void fetchFollowersTokens() async {
    try {
      DatabaseReference followersRef = _database
          .child('Events')
          .child(widget.eventId)
          .child("Runes")
          .child(widget.runeId)
          .child("Followers");

      DataSnapshot snapshot = await followersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> followersMap =
            snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          followersMap.forEach((key, value) {
            String id = value['id'];
            String token = value['token'];
            followers.add({'id': id, 'token': token});
          });
        });
      }
    } catch (e) {
      print("Error fetching followers: $e");
    }
  }

  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  @override
  void initState() {
    fetchFollowersTokens();
    nameController.text = widget.dogName;
    ownerController.text = widget.ownerName ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Form(
            key: _formKey,
            child: Column(
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
                      "Bark-Custom Message",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Palanquin Dark",
                        fontSize: 20.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Text(
                      "Dog Name:   ",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                    Text(
                      widget.runeName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: 'Palanquin Dark',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.ownerName != ''
                        ? Row(
                            children: [
                              Text(
                                "Owner name:   ",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Palanquin Dark',
                                ),
                              ),
                              Text(
                                widget.ownerName,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'Palanquin Dark',
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink()
                  ],
                ),
                SizedBox(height: 15.h),
                CustomTextField(
                  label: "Message",
                  controller: msgController,
                  textInputAction: TextInputAction.next,
                  validator: validateNotEmpty,
                  maxLines: 5,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        msgController.text = '4 dogs away';
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.buttonColor),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '4 dogs away +',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.buttonColor,
                            fontFamily: 'Palanquin Dark',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: () {
                        msgController.text = '8 dogs away';
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.buttonColor),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '8 dogs away +',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.buttonColor,
                            fontFamily: 'Palanquin Dark',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                RoundButton(
                  title: "Send Message",
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      // Get current user ID
                      User? currentUser = _auth.currentUser;
                      if (currentUser != null) {
                        String uid = currentUser.uid;

                        Utils.toastMessage(
                            "Message sent successfully", Colors.green);
                        Navigator.pop(context);

                        DatabaseReference newRef = _database
                            .child('Users')
                            .child(_auth.currentUser!.uid)
                            .child('Notifications')
                            .push();

                        for (var e in followers) {
                          _database
                              .child('Users')
                              .child(_auth.currentUser!.uid)
                              .child('Notifications')
                              .child(newRef.key!)
                              .set({
                            'title': '${widget.runeName} Run',
                            'body':
                                '${widget.dogName} is ${msgController.text}',
                            'createdAt': DateTime.now().toString(),
                          });
                        }

                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(height: 10.h),
                RoundButton2(
                  title: "Cancel",
                  onPress: () {
                    Get.back();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Palanquin Dark',
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: true,
          onTap: onTap,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 16.sp),
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.symmetric(
            //     vertical: size.height * 0.020, horizontal: 10),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.date_range, size: 24.h),
            ),
            border: const OutlineInputBorder(),
            hintText: "Choose $label",
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onTap,
  ) {
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
          controller: controller,
          focusNode: focusNode,
          readOnly: true,
          onTap: onTap,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 16.sp),
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.symmetric(
            //     vertical: size.height * 0.02, horizontal: 10),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Icon(Icons.timelapse, size: 24.h),
            ),
            border: const OutlineInputBorder(),
            hintText: "Choose $label",
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final int? maxLines;
  final String? Function(String?, String)? validator; // Optional validator

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    required this.textInputAction,
    this.maxLines,
    this.validator, // Make the validator optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          maxLines: maxLines ?? 1,
          controller: controller,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Enter $label",
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          // Use the validator only if it's provided
          validator:
              validator != null ? (value) => validator!(value, label) : null,
          textInputAction: textInputAction,
        ),
      ],
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../Utils/Utils.dart';
import '../../../Widgets/round_button.dart';
import '../../../Widgets/round_button2.dart';

class CreateRunesScreen extends StatefulWidget {
  final String eventId; // Add eventId to the ructor

  const CreateRunesScreen({required this.eventId, super.key}); // Constructor

  @override
  State<CreateRunesScreen> createState() => _CreateRunesScreenState();
}

class _CreateRunesScreenState extends State<CreateRunesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  final FocusNode startDateFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();

  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
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
                          padding: EdgeInsets.all(15.0.w),
                          child: SvgPicture.asset(
                            'assets/images/back_arrow.svg',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Text(
                      "Add new run",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Palanquin Dark",
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildTextField(
                  "Run Name",
                  nameController,
                  nameFocusNode,
                  TextInputAction.next,
                  validateNotEmpty,
                ),
                SizedBox(height: 10.h),
                _buildTextField(
                  "Run Location",
                  locationController,
                  locationFocusNode,
                  TextInputAction.next,
                  validateNotEmpty,
                ),
                SizedBox(height: 10.h),
                _buildDateField(
                  "Run Date",
                  startDateController,
                  startDateFocusNode,
                  () => _selectDate(context, startDateController),
                ),
                SizedBox(height: 20.h),
                RoundButton(
                  title: "Create New Run",
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      User? currentUser = _auth.currentUser;
                      if (currentUser != null) {
                        String uid = currentUser.uid;
                        String runeId = _database.child("Runes").push().key!;

                        Map<String, String> runeData = {
                          'runeName': nameController.text,
                          'runeLocation': locationController.text,
                          'runeStartDate': startDateController.text,
                          'eventId': widget.eventId,
                        };

                        // Save rune under the current user's event
                        _database
                            .child("Users")
                            .child(uid)
                            .child("Events")
                            .child(widget.eventId)
                            .child("Runes")
                            .child(runeId)
                            .set(runeData)
                            .then((_) {
                          // ALSO save rune under global Events node for all users
                          _database
                              .child("Events")
                              .child(widget.eventId)
                              .child("Runes")
                              .child(runeId)
                              .set(runeData)
                              .then((_) {
                            Utils.toastMessage(
                                "Rune created successfully", Colors.green);
                            Navigator.pop(context);

                            // Optionally clear the form fields
                            nameController.clear();
                            locationController.clear();
                            startDateController.clear();
                          }).catchError((error) {
                            Utils.toastMessage(
                                "Failed to create public rune: $error",
                                Colors.red);
                          });
                        }).catchError((error) {
                          Utils.toastMessage(
                              "Failed to create rune: $error", Colors.red);
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 10.h),
                RoundButton2(
                  title: "Cancel",
                  onPress: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    TextInputAction textInputAction,
    String? Function(String?, String) validator,
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
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 16.sp),
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.symmetric(
            //     vertical: size.height * 0.020, horizontal: 10),
            border: const OutlineInputBorder(),
            hintText: "Enter $label",
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          validator: (value) => validator(value, label),
          textInputAction: textInputAction,
        ),
      ],
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
            //     vertical: size.height * 0.020, horizontal: 10),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 10.w),
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
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16.sp),
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.symmetric(
            //     vertical: size.height * 0.020, horizontal: 10),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Icon(Icons.timelapse, size: 24.h),
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
}

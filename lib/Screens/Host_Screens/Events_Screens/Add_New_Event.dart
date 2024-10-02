import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/Widgets/round_button2.dart';
import 'package:intl/intl.dart';

class AddNewEvent extends StatefulWidget {
  const AddNewEvent({super.key});

  @override
  State<AddNewEvent> createState() => _AddNewEventState();
}

class _AddNewEventState extends State<AddNewEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController =
      TextEditingController(); // Start date
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
        print('Selected Date: ${controller.text}'); // Add this line to debug
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
                      "Add new event",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Palanquin Dark",
                        fontSize: 20.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildTextField(
                  "Event Name",
                  nameController,
                  nameFocusNode,
                  TextInputAction.next,
                  validateNotEmpty,
                ),
                SizedBox(height: 10.h),
                _buildTextField(
                  "Event Location",
                  locationController,
                  locationFocusNode,
                  TextInputAction.next,
                  validateNotEmpty,
                ),
                SizedBox(height: 10.h),
                _buildDateField(
                  "Event Start Date",
                  startDateController,
                  startDateFocusNode,
                  () => _selectDate(context, startDateController),
                ),
                SizedBox(height: 30.h),
                RoundButton(
                  title: "Create New Event",
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      // Get current user ID
                      User? currentUser = _auth.currentUser;
                      if (currentUser != null) {
                        String uid = currentUser.uid;

                        // Generate a unique event ID
                        String eventId = _database.child("Events").push().key!;

                        // Create event data
                        Map<String, String> eventData = {
                          'eventName': nameController.text,
                          'eventLocation': locationController.text,
                          'eventStartDate': startDateController.text,
                        };

                        // Save event under current user's UID
                        _database
                            .child("Users")
                            .child(uid)
                            .child("Events")
                            .child(eventId)
                            .set(eventData)
                            .then((_) {
                          // ALSO save the event under global Events node for all users
                          _database
                              .child("Events")
                              .child(eventId)
                              .set(eventData)
                              .then((_) {
                            Utils.toastMessage(
                                "Event created successfully", Colors.green);
                            Navigator.pop(context);

                            // Optionally clear the form fields
                            nameController.clear();
                            locationController.clear();
                            startDateController.clear();
                          }).catchError((error) {
                            Utils.toastMessage(
                                "Failed to create public event: $error",
                                Colors.red);
                          });
                        }).catchError((error) {
                          Utils.toastMessage(
                              "Failed to create event: $error", Colors.red);
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
              fontWeight: FontWeight.bold,
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

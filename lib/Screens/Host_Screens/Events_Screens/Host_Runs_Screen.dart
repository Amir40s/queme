import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import '../../../Widgets/Excel_button.dart';
import '../../../Widgets/Upcoming_button.dart';

class HostRunsScreen extends StatefulWidget {
  final String eventId;
  final String runeId;
  final String runeName; // Add runeId and runeName to the constructor

  const HostRunsScreen({
    Key? key,
    required this.eventId,
    required this.runeId,
    required this.runeName,
  }) : super(key: key);

  @override
  State<HostRunsScreen> createState() => _HostRunsScreenState();
}

class _HostRunsScreenState extends State<HostRunsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs
  }

  // Function to upload Excel file and parse data
  Future<void> _pickAndUploadExcel() async {
    try {
      // Pick an Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        print("File picked: ${result.files.single.path}");
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        Sheet sheet = excel.tables[excel.tables.keys.first]!;
        print("Sheet rows: ${sheet.rows.length}");

        List<Map<String, dynamic>> dogList = [];

        for (var row in sheet.rows.skip(1)) {
          var dogData = {
            "dogName": row[0]?.value ?? "",
            "breed": row[1]?.value ?? "",
            "age": row[2]?.value ?? "",
          };
          print("Parsed row: $dogData");
          dogList.add(dogData);
        }

        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          String uid = currentUser.uid;
          DatabaseReference ref = _database
              .child('Users')
              .child(uid)
              .child('Events')
              .child(widget.eventId)
              .child('Runes')
              .child(widget.runeId)
              .child('DogList');

          print("Uploading to Firebase...");
          await ref.set(dogList);
          print("Upload completed");
          Utils.toastMessage("Uploaded Successfully", Colors.green);
        }
      } else {
        Utils.toastMessage("Upload Failed", Colors.red);
      }
    } catch (e) {
      print("Error: $e");
      Utils.toastMessage("An error occurred: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SvgPicture.asset(
                'assets/images/back_arrow.svg',
                height: 24.h,
                width: 24.w,
              ),
            ),
          ),
        ),
        title: Text(
          widget.runeName,
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Palanquin Dark",
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: UpcomingButton(title: "Upcoming", onPress: () {}),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          labelStyle: TextStyle(
              fontSize: 16.sp,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'Running'),
            Tab(text: 'Completed Dogs'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Running Tab Content
            Stack(
              children: [
                Center(
                    child: Text(
                  "No Dogs Running",
                  style: TextStyle(fontSize: 16.sp),
                )),
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: ExcelButton(
                    title: "Add Excel File",
                    onPress:
                        _pickAndUploadExcel, // Call the function on button press
                  ),
                ),
              ],
            ),
            // Completed Dogs Tab Content
            Center(
                child: Text(
              "Dogs Completed List",
              style: TextStyle(fontSize: 16.sp),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

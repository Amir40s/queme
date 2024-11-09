import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/Widgets/round_button2.dart';
import 'package:uuid/uuid.dart';

import '../../../Widgets/Doted_Container.dart';
import '../../../Widgets/colors.dart';
import '../../../Widgets/follow_button.dart';
import 'Claim_Successfully.dart';

class ClaimDogScreen extends StatefulWidget {
  const ClaimDogScreen({
    super.key,
    required this.eventId,
    required this.runeId,
    required this.dogId,
    required this.dogName,
    required this.competitorNo,
  });

  final String eventId, runeId, dogId, dogName, competitorNo;

  @override
  State<ClaimDogScreen> createState() => _ClaimDogScreenState();
}

class _ClaimDogScreenState extends State<ClaimDogScreen> {
  final bool _isLoading = false;
  List<Map<String, String>> _dogsList = [];
  TextEditingController dogNameController = TextEditingController();
  TextEditingController dogBreedController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  void initState() {
    super.initState();
  }

  // Method to add a new dog
  Future<void> _addDog(BuildContext context) async {
    XFile? image;
    String imageUrl = '';
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage the state within the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Dog Picture'),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      setState(() {
                        isLoading = false;
                      });

                      if (image != null) {
                        setState(() {});
                      }
                    },
                  ),
                  if (image != null) Image.file(File(image!.path), height: 100),
                  if (isLoading) // Display loading indicator if isLoading is true
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text('Please Wait'),
                      ],
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Claim'),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    String dogId = const Uuid().v4();
                    String uid = _auth.currentUser!.uid;
                    String? imageUrl;

                    if (image != null) {
                      imageUrl = await Utils()
                          .uploadFileToCloudinary(image!.path, context);
                    }

                    await _database
                        .child('Users')
                        .child(uid)
                        .child('MyDogs')
                        .child(dogId)
                        .set({
                      'name': widget.dogName,
                      'imageUrl': imageUrl,
                    });
                    _claimDog(widget.dogId, imageUrl ?? '');

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to add a new dog
  Future<void> _claimDogWidget(BuildContext context, String dogImage) async {
    XFile? image;
    String imageUrl = '';
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage the state within the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Claim Dog'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dogImage != '' && image == null)
                    Image.network(
                      dogImage,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  if (image != null) Image.file(File(image!.path), height: 100),
                  if (isLoading) // Display loading indicator if isLoading is true
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text('Please Wait'),
                      ],
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Dog Picture'),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      setState(() {
                        isLoading = false;
                      });

                      if (image != null) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Claim'),
                  onPressed: () async {
                    if (image == null && dogImage.isEmpty) {
                      Utils.toastMessage('Dog image is required', Colors.red);
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    if (image != null) {
                      imageUrl = await Utils()
                          .uploadFileToCloudinary(image!.path, context);
                    }

                    _claimDog(widget.dogId, imageUrl);

                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

// Method to claim the dog
  Future<void> _claimDog(String dogId, String imageUrl) async {
    String uid = _auth.currentUser!.uid;
    final userData = await getCurrentUserData();

    try {
      await _database
          .child('Events')
          .child(widget.eventId)
          .child('Runes')
          .child(widget.runeId)
          .child('DogList')
          .child(widget.dogId)
          .update(
        {
          'claimed': true,
          'ownerName': userData?['name'] ?? '',
          'imageUrl': imageUrl,
        },
      );
      await _database.child('ClaimedDogs').push().set(
        {
          'claimed': true,
          'ownerName': userData?['name'] ?? '',
          'dogName': widget.dogName,
          'imageUrl': imageUrl,
          'competitorName': widget.competitorNo
        },
      );
      Get.back();
      Get.to(() => ClaimSuccfullyScreen(
            dogName: widget.dogName,
          ));
    } catch (e) {
      // Handle error, you can also show a message to the user if needed
      Utils.toastMessage("Failed to claim dog", Colors.red);
      print('Error claiming dog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
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
                        padding: const EdgeInsets.all(15.0),
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
                    "Claim Your Dog",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Palanquin Dark",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Text(
                    "Dog Name:   ",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Palanquin Dark',
                    ),
                  ),
                  Text(
                    widget.dogName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Palanquin Dark',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  _addDog(context);
                },
                child: DottedBorderContainer(
                  height: 80.h,
                  width: 342.w,
                  borderColor: Colors.black,
                  strokeWidth: 2.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        "Upload photo (optional)",
                        style: TextStyle(
                          fontSize: 14.h,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              RoundButton2(
                  title: "Cancel",
                  onPress: () {
                    Navigator.pop(context);
                  }),
              SizedBox(
                height: 10.h,
              ),
              RoundButton(
                title: "Claim",
                onPress: () {
                  _claimDog(widget.eventId, '');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

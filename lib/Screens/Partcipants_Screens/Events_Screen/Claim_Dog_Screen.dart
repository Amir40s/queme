import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/Widgets/round_button2.dart';
import 'package:uuid/uuid.dart';

import '../../../Widgets/Doted_Container.dart';
import '../../../Widgets/colors.dart';
import '../../../Widgets/follow_button.dart';
import '../../../Widgets/runes_button.dart';
import 'Claim_Successfully.dart';

class ClainDogScreen extends StatefulWidget {
  const ClainDogScreen({super.key});

  @override
  State<ClainDogScreen> createState() => _ClainDogScreenState();
}

class _ClainDogScreenState extends State<ClainDogScreen> {
  bool _isLoading = false;
  List<Map<String, String>> _dogsList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchDogs(_auth.currentUser!.uid);
  }

  Future<void> _fetchDogs(String uid) async {
    DatabaseEvent event =
        await _database.child('Users').child(uid).child('MyDogs').once();
    if (event.snapshot.exists) {
      List<Map<String, String>> dogs = [];
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        dogs.add({
          'id': key,
          'name': value['name'] ?? '',
          'breed': value['breed'] ?? '',
          'imageUrl': value['imageUrl'] ?? '',
        });
      });

      setState(() {
        _dogsList = dogs;
      });
    }
  }

  // Method to add a new dog
  Future<void> _addDog(BuildContext context) async {
    TextEditingController dogNameController = TextEditingController();
    TextEditingController dogBreedController = TextEditingController();
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
              title: const Text('Add Dog'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dogNameController,
                    decoration: const InputDecoration(labelText: 'Dog Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dogBreedController,
                    decoration: const InputDecoration(labelText: 'Dog Breed'),
                  ),
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
                  child: const Text('Save'),
                  onPressed: () async {
                    if (dogNameController.text.isNotEmpty &&
                        dogBreedController.text.isNotEmpty &&
                        image != null) {
                      setState(() {
                        isLoading =
                            true; // Show loading indicator when save starts
                      });

                      // Upload image to Firebase Storage and get the URL
                      String dogId = const Uuid().v4();
                      String uid = _auth.currentUser!.uid;
                      Reference ref = _storage.ref().child('dogs/$uid/$dogId');
                      await ref.putFile(File(image!.path));
                      imageUrl = await ref.getDownloadURL();

                      // Save dog data to Firebase Realtime Database
                      await _database
                          .child('Users')
                          .child(uid)
                          .child('MyDogs')
                          .child(dogId)
                          .set({
                        'name': dogNameController.text,
                        'breed': dogBreedController.text,
                        'imageUrl': imageUrl,
                      });

                      setState(() {
                        _dogsList.add({
                          'id': dogId,
                          'name': dogNameController.text,
                          'breed': dogBreedController.text,
                          'imageUrl': imageUrl,
                        });
                        isLoading =
                            false; // Hide loading indicator when save completes
                      });

                      // Reload the dog list to reflect the new addition
                      await _fetchDogs(uid);

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to edit a dog's name and picture
  Future<void> _editDog(BuildContext context, String dogId, String currentName,
      String currentImageUrl, String currentBreed) async {
    TextEditingController dogNameController =
        TextEditingController(text: currentName);
    TextEditingController dogBreedController =
        TextEditingController(text: currentBreed);
    XFile? newImage;
    String newImageUrl = currentImageUrl;
    String newBreed = currentBreed;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog when clicking outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Dog'),
              content: isLoading // Show CircularProgressIndicator when loading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          Text("Saving..."),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: dogNameController,
                          decoration:
                              const InputDecoration(labelText: 'Dog Name'),
                        ),
                        TextField(
                          controller: dogBreedController,
                          decoration:
                              const InputDecoration(labelText: 'Dog Breed'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('Upload New Picture'),
                          onPressed: () async {
                            newImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (newImage != null) {
                              setState(() {});
                            }
                          },
                        ),
                        if (newImage != null)
                          Image.file(File(newImage!.path), height: 100)
                        else
                          Image.network(currentImageUrl, height: 100),
                      ],
                    ),
              actions: isLoading
                  ? [] // No actions while loading
                  : <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Save'),
                        onPressed: () async {
                          setState(() {
                            isLoading = true; // Show loading spinner
                          });

                          if (newImage != null) {
                            // Upload new image to Firebase Storage
                            String uid = _auth.currentUser!.uid;
                            Reference ref =
                                _storage.ref().child('dogs/$uid/$dogId');
                            await ref.putFile(File(newImage!.path));
                            newImageUrl = await ref.getDownloadURL();
                          }

                          // Update dog data in Firebase Realtime Database
                          await _database
                              .child('Users')
                              .child(_auth.currentUser!.uid)
                              .child('MyDogs')
                              .child(dogId)
                              .update({
                            'name': dogNameController.text,
                            'breed': dogBreedController.text,
                            'imageUrl': newImageUrl,
                          });

                          // Reload the dog list to reflect the updated data
                          await _fetchDogs(_auth.currentUser!.uid);

                          setState(() {
                            isLoading = false;
                          });

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

// Method to claim the dog
  Future<void> _claimDog(
      String dogId, String dogName, String dogBreed, String imageUrl) async {
    String uid = _auth.currentUser!.uid;

    try {
      // Update the 'claimed' field to true in the 'MyDogs' node for the current user
      await _database
          .child('Users')
          .child(uid)
          .child('MyDogs')
          .child(dogId)
          .update({
        'claimed': true,
      });

      // Add the dog to the 'ClaimedDogs' node with the provided details
      await _database.child('ClaimedDogs').child(dogId).set({
        'owner': _auth.currentUser!.displayName ?? '',
        'name': dogName,
        'breed': dogBreed,
        'imageUrl': imageUrl,
        'claimedBy': uid, // Optional: Add the user ID who claimed the dog
      });
      Utils.toastMessage("Dog claimed successfully", Colors.green);
      // After successfully claiming, navigate to ClaimSuccessfullyScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClaimSuccfullyScreen()),
      );
    } catch (e) {
      // Handle error, you can also show a message to the user if needed
      Utils.toastMessage("Failed to claim dog", Colors.red);
      print('Error claiming dog: $e');
    }
  }

  Widget _buildDogsList() {
    return _dogsList.isEmpty
        ? const Center(child: Text("No dogs to see"))
        : _isLoading
            ? const Center(child: Text("Please Wait"))
            : Column(
                children: _dogsList.map((dog) {
                  return Padding(
                    padding: EdgeInsets.all(8.0.h),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ListTile(
                            leading: dog['imageUrl'] == null
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Image.network(
                                    dog['imageUrl']!,
                                    width: 70.w,
                                    height: 70.h,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                            title: Text(
                              dog['name']!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                  fontSize: 16.sp),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 225.w,
                          top: 25.h,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.red),
                            onPressed: () {
                              _editDog(context, dog['id']!, dog['name']!,
                                  dog['imageUrl']!, dog['breed']!);
                            },
                          ),
                        ),
                        Positioned(
                          left: 225.w,
                          top: 20.h,
                          child: FollowButton(
                            title: "Claim",
                            onPress: () {
                              _claimDog(dog['id']!, dog['name']!, dog['breed']!,
                                  dog['imageUrl']!); // Claim the dog by updating the database
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
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
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Dogs",
                  style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(height: 20.h),
              _buildDogsList(),
              SizedBox(height: 20.h),
              Divider(color: AppColors.buttonColor, thickness: 3.h),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upload Your Dog",
                  style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              DottedBorderContainer(
                height: 80.h,
                width: 342.w,
                borderColor: Colors.black,
                strokeWidth: 2.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        _addDog(context);
                      },
                      child: SvgPicture.asset('assets/images/upload.svg',
                          height: 28.h, width: 28.h, color: Colors.black),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "Upload your dog picture",
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
              SizedBox(
                height: 20.h,
              ),
              RoundButton2(
                  title: "Cancel",
                  onPress: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

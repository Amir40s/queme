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

class ClaimDogScreen extends StatefulWidget {
  const ClaimDogScreen(
      {super.key,
      required this.eventId,
      required this.runeId,
      required this.dogId});

  final String eventId, runeId, dogId;

  @override
  State<ClaimDogScreen> createState() => _ClaimDogScreenState();
}

class _ClaimDogScreenState extends State<ClaimDogScreen> {
  bool _isLoading = false;
  List<Map<String, String>> _dogsList = [];
  TextEditingController dogNameController = TextEditingController();
  TextEditingController dogBreedController = TextEditingController();
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
    XFile? image;
    String imageUrl = '';
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();
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
                  Form(
                    key: formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a dog name';
                        }
                        return null;
                      },
                      controller: dogNameController,
                      decoration: const InputDecoration(labelText: 'Dog Name'),
                    ),
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
                      if (formKey.currentState!.validate()) {
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
                          'name': dogNameController.text,
                          'breed': dogBreedController.text,
                          'imageUrl': imageUrl,
                        });

                        setState(() {
                          _dogsList.add({
                            'id': dogId,
                            'name': dogNameController.text,
                            'breed': dogBreedController.text,
                            'imageUrl': imageUrl ?? '',
                          });
                          isLoading = false;
                        });

                        await _fetchDogs(uid);
                        Navigator.of(context).pop();
                      }
                    }),
              ],
            );
          },
        );
      },
    );
  }

  // Method to add a new dog
  Future<void> _claimDogWidget(
      BuildContext context, String name, String dogImage, String dogID) async {
    XFile? image;
    String imageUrl = '';
    bool isLoading = false;
    final nameC = TextEditingController();
    nameC.text = name;
    final formKey = GlobalKey<FormState>();
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
                  Form(
                    key: formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a dog name';
                        }
                        return null;
                      },
                      controller: nameC,
                      decoration: const InputDecoration(labelText: 'Dog Name'),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      String dogId = const Uuid().v4();
                      String uid = _auth.currentUser!.uid;
                      String imageUrl = '';

                      if (image != null) {
                        imageUrl = await Utils()
                            .uploadFileToCloudinary(image!.path, context);
                      }

                      await _claimDog(dogId, nameC.text,
                          imageUrl.isNotEmpty ? imageUrl : dogImage);

                      Utils.toastMessage(
                          "Dog claimed successfully", Colors.green);
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClaimSuccfullyScreen()),
                      );
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
                            newImageUrl = await Utils().uploadFileToCloudinary(
                                newImage!.path, context);
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
  Future<void> _claimDog(String dogId, String dogName, String imageUrl) async {
    String uid = _auth.currentUser!.uid;

    try {
      _database
          .child('Events')
          .child(widget.eventId)
          .child('Runes')
          .child(widget.runeId)
          .child('DogList')
          .child(widget.dogId)
          .update(
        {
          'claimed': true,
          'dogName': dogName,
          'imageUrl': imageUrl,
        },
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
                children: _dogsList.map(
                  (dog) {
                    return Padding(
                      padding: EdgeInsets.all(8.0.h),
                      child: Stack(
                        children: [
                          ClipRRect(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (dog['imageUrl'] != '')
                                  Image.network(
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
                                Text(
                                  dog['name']!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                      fontSize: 16.sp),
                                ),
                                FollowButton(
                                  title: "Claim",
                                  onPress: () {
                                    // _claimDog(
                                    //     dog['id']!, dog['name']!, dog['breed']!);
                                    _claimDogWidget(
                                      context,
                                      dog['name']!,
                                      dog['imageUrl']!,
                                      dog['id']!,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
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
                        "Upload your dog",
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
            ],
          ),
        ),
      ),
    );
  }
}

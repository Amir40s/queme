import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Host_Screens/Host_Dashboard/host_bottom_nav.dart';
import 'package:queme/Screens/Host_Screens/Payments_Screens/Payment_Plans_Screen.dart';
import 'package:queme/provider/eventProvider.dart';
import 'package:uuid/uuid.dart';
import 'package:queme/Widgets/round_button.dart';
import '../../../Utils/Utils.dart';
import '../../../Widgets/Unfollow_Button.dart';
import '../../../Widgets/colors.dart';
import '../../Auth/Login_Screen.dart';
import '../../Host_Screens/Host_Dashboard/Host_Dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _profileImageUrl = 'assets/images/women1.png'; // Default profile image
  String _userType = 'Participant'; // Default profile image
  bool _isLoading = false;
  List<Map<String, String>> _dogsList = [];
  List<Map<String, dynamic>> _followingEvents = []; // To store followed events
  List<Map<String, dynamic>> _followingRuns = []; // To store followed runs

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
    _fetchDogs(_auth.currentUser!.uid);
    _editProfileImage();
    _fetchFollowingEvents();
    _fetchFollowingRuns();
  }

// Function to fetch user data from Firebase
  Future<void> _fetchFollowingRuns() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      _database
          .child("Users")
          .child(uid)
          .child("followingRunes")
          .onValue
          .listen((event) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> loadedRuns = [];

        if (data != null) {
          data.forEach((key, value) {
            loadedRuns.add({
              'runId': key, // Adjusted to match your structure
              'runName': value['runeName'],
            });
          });
          print("Fetched runs: $loadedRuns"); // Debugging
        } else {
          print("No following runs found."); // Debugging
        }

        setState(() {
          _followingRuns = loadedRuns;
          _isLoading = false;
        });
      });
    } else {
      print("No current user found."); // Debugging
    }
  }

  // Function to fetch followed events from Firebase
  Future<void> _fetchFollowingEvents() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Fetch following events from the database
      _database
          .child("Users")
          .child(uid)
          .child("followingEvents")
          .onValue
          .listen((event) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        List<Map<String, dynamic>> loadedEvents = [];

        if (data != null) {
          data.forEach((key, value) {
            loadedEvents.add({
              'eventId': key,
              'eventName': value['eventName'],
              'eventLocation': value['eventLocation'],
              'eventStartDate': value['eventStartDate'],
            });
          });
        }

        setState(() {
          _followingEvents = loadedEvents;
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _unfollowRuns(String eventId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        await _database
            .child("Users")
            .child(uid)
            .child("followingRunes")
            .child(eventId)
            .remove();
      } on FirebaseException catch (e) {
        Utils.toastMessage("Error: ${e.message}", Colors.red);
      }
    }
  }

  // Function to unfollow an event (removing from Firebase)
  Future<void> _unfollowEvent(String eventId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      try {
        await _database
            .child("Users")
            .child(uid)
            .child("followingEvents")
            .child(eventId)
            .remove();
      } on FirebaseException catch (e) {
        Utils.toastMessage("Error: ${e.message}", Colors.red);
      }
    }
  }

  Future<void> _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      _emailController.text = currentUser.email ?? '';
      _nameController.text = currentUser.displayName ?? '';

      // Fetch additional data from Realtime Database
      DatabaseEvent event = await _database.child('Users').child(uid).once();
      if (event.snapshot.exists) {
        Map data = event.snapshot.value as Map;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _userType = data['userType'] ?? '';
          _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
        });

        // Fetch dogs
        await _fetchDogs(uid);
      }
    }
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
                    if (dogNameController.text.isNotEmpty && image != null) {
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
                        'imageUrl': imageUrl,
                      });

                      setState(() {
                        _dogsList.add({
                          'id': dogId,
                          'name': dogNameController.text,
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
      String currentImageUrl) async {
    TextEditingController dogNameController =
        TextEditingController(text: currentName);
    XFile? newImage;
    String newImageUrl = currentImageUrl;
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

  // Method to edit the user's profile picture
  Future<void> _editProfileImage() async {
    XFile? image;
    bool isUploading = false; // New state to track uploading

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Profile Picture'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text('Upload from Camera'),
                    onPressed: () async {
                      image = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      setState(
                          () {}); // Update the dialog UI to show the selected image
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Upload from Gallery'),
                    onPressed: () async {
                      image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      setState(
                          () {}); // Update the dialog UI to show the selected image
                    },
                  ),
                  const SizedBox(height: 10),
                  // Display the selected image
                  if (image != null)
                    Image.file(
                      File(image!.path),
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 10),
                  // Show CircularProgressIndicator if uploading
                  if (isUploading)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text('Uploading...'),
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
                    if (image != null) {
                      setState(() {
                        isUploading = true; // Start loading indicator
                      });

                      String uid = _auth.currentUser!.uid;
                      Reference ref =
                          _storage.ref().child('profileImages/$uid');
                      await ref.putFile(File(image!.path));
                      String newImageUrl = await ref.getDownloadURL();

                      // Update profile image URL in Realtime Database
                      await _database.child('Users').child(uid).update({
                        'profileImageUrl': newImageUrl,
                      });

                      // Update the local UI on the profile page
                      setState(() {
                        _profileImageUrl = newImageUrl;
                        isUploading = false; // Stop loading indicator
                      });

                      Navigator.of(context)
                          .pop(); // Close dialog after upload completes

                      // Call setState in the profile page to update the image
                      setState(() {
                        _profileImageUrl = newImageUrl;
                      });
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
                                  dog['imageUrl']!);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
  }

  // Helper function to build text fields for display only
  Widget _buildTextField(
      TextEditingController controller, VoidCallback onEdit) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            style: TextStyle(fontSize: 16.sp, color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ],
    );
  }

  Future<void> _logout() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Are you sure want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, String field) async {
    TextEditingController controller =
        (field == 'name') ? _nameController : _emailController;
    TextEditingController tempController =
        TextEditingController(text: controller.text);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${field == 'name' ? 'Name' : 'Email'}'),
          content: TextField(
            controller: tempController,
            decoration:
                InputDecoration(labelText: field == 'name' ? 'Name' : 'Email'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (tempController.text != controller.text) {
                  await _updateUserData(field, tempController.text);
                  setState(() {
                    controller.text = tempController.text;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserData(String field, String value) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Update Firebase Realtime Database
      try {
        await _database.child('Users').child(uid).update({field: value});
        print('Database updated successfully for $field with $value');
      } catch (e) {
        print('Failed to update database: $e');
      }

      // Update email in Firebase Authentication
      if (field == 'email') {
        try {
          await currentUser.updateEmail(value);
          print('Email updated successfully');
        } catch (e) {
          print('Failed to update email: $e');
        }
      }
    } else {
      print('No current user found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: _logout,
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.logout, color: AppColors.buttonColor),
                    onPressed: _logout, // Logout button
                  ),
                  const Text("Logout",
                      style: TextStyle(color: AppColors.buttonColor)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: _profileImageUrl.contains('assets')
                        ? Image.asset(_profileImageUrl,
                            width: 140.w, height: 140.h)
                        : Image.network(
                            _profileImageUrl,
                            width: 140.w,
                            height: 140.h,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 38.h,
                      ),
                      onPressed: _editProfileImage,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(_nameController.text,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Name",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                  _nameController, () => _showEditDialog(context, 'name')),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Email",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                  _emailController, () => _showEditDialog(context, 'email')),
              _userType == 'Participant'
                  ? SizedBox(height: 20.h)
                  : const SizedBox.shrink(),
              _userType == 'Participant'
                  ? RoundButton(
                      title: "Upgrade To Host",
                      onPress: () {
                        Provider.of<EventProvider>(context, listen: false)
                            .changeUserType(_userType == 'Participant'
                                ? 'Host'
                                : 'Participant');

                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const PaymentPlansScreen()),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
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
              // ElevatedButton.icon(
              //   onPressed: () => _addDog(context),
              //   icon: const Icon(Icons.add, color: Colors.white),
              //   label: Text("Add Dogs",
              //       style: TextStyle(
              //           fontSize: 16.sp,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white)),
              //   style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.buttonColor),
              // ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Events Following",
                  style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator while fetching data
                  : _followingEvents.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap:
                              true, // Ensures it fits within the available space
                          itemCount: _followingEvents.length,
                          itemBuilder: (ctx, index) {
                            var event = _followingEvents[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle tap on event
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            event['eventName'],
                                            style: TextStyle(
                                              fontSize: 20.h,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_month,
                                                      size: 20.h),
                                                  SizedBox(width: 5.w),
                                                  Text(
                                                    "${event['eventStartDate']}",
                                                    style: TextStyle(
                                                      fontSize: 12.h,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      size: 24.h),
                                                  SizedBox(width: 5.w),
                                                  Text(
                                                    event['eventLocation'],
                                                    style: TextStyle(
                                                      fontSize: 12.h,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.h),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: UnfollowButton(
                                          title: "Unfollow",
                                          onPress: () {
                                            Provider.of<EventProvider>(context,
                                                    listen: false)
                                                .unfollowEvent(
                                                    event['eventId']);
                                            _unfollowEvent(event['eventId']);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('No events found')),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Runs Following",
                  style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _followingRuns.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _followingRuns.length,
                          itemBuilder: (ctx, index) {
                            var run = _followingRuns[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle tap on run
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            run['runName'],
                                            style: TextStyle(
                                              fontSize: 20.h,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: UnfollowButton(
                                          title: "Unfollow",
                                          onPress: () {
                                            Provider.of<EventProvider>(context,
                                                    listen: false)
                                                .unfollowRuns(run['runId']);
                                            _unfollowRuns(run['runId']);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('No runs found')),
              SizedBox(
                height: 5.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

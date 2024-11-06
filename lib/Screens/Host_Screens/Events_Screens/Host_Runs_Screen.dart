import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:queme/Screens/Host_Screens/Events_Screens/components/completed_dog_list_widget.dart';
import 'package:queme/Screens/Host_Screens/Events_Screens/components/running_dog_list_widget.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/colors.dart';
import '../../../Widgets/Excel_button.dart';

class HostRunsScreen extends StatefulWidget {
  final String eventId;
  final String runeId;
  final String runeName;
  final String date;

  const HostRunsScreen({
    super.key,
    required this.eventId,
    required this.runeId,
    required this.runeName,
    required this.date,
  });

  @override
  State<HostRunsScreen> createState() => _HostRunsScreenState();
}

class _HostRunsScreenState extends State<HostRunsScreen>
    with SingleTickerProviderStateMixin {
  final dogNameC = TextEditingController();
  final dogBreedC = TextEditingController();
  final dogOwnerC = TextEditingController();
  final dogCompetitorC = TextEditingController();
  List<Map<String, String>> followers = [];
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/',
  ).ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchFollowersTokens();
  }

  Future<void> sendNotification(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController notificationC = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Message to run followers'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Message cannot be empty';
                          }
                          return null;
                        },
                        controller: notificationC,
                        decoration: const InputDecoration(labelText: 'Message'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Send'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    Utils.toastMessage(
                        "Message sent to all followers", Colors.green);
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
                        'body': notificationC.text.toString(),
                        'createdAt': DateTime.now().toString(),
                      });
                    }

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

  Future<void> _pickAndUploadExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        Sheet sheet = excel.tables[excel.tables.keys.first]!;
        List<Map<String, dynamic>> dogList = [];

        for (var row in sheet.rows.skip(1)) {
          var dogData = {
            "competitorName": row[0]?.value?.toString() ?? "",
            "dogName": row[1]?.value?.toString() ?? "",
            "ownerName": row[2]?.value?.toString() ?? "",
            "breed": row[3]?.value?.toString() ?? "",
            "claimed": false,
            "checkedIn": false,
            "createdAt": DateTime.now().toString(),
          };
          dogList.add(dogData);
        }

        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          String uid = currentUser.uid;

          for (var dogData in dogList) {
            DatabaseReference ref = _database
                .child('Users')
                .child(uid)
                .child('Events')
                .child(widget.eventId)
                .child('Runes')
                .child(widget.runeId)
                .child('DogList')
                .push(); // Creates a new unique document for each dog

            DatabaseReference refEvent = _database
                .child('Events')
                .child(widget.eventId)
                .child('Runes')
                .child(widget.runeId)
                .child('DogList')
                .push(); // Creates a new unique document for each dog

            await ref.set(dogData);
            await refEvent.set(dogData);
          }

          Utils.toastMessage("Uploaded Successfully", Colors.green);
        }
      } else {
        Utils.toastMessage("Upload Failed", Colors.red);
      }
    } catch (e) {
      Utils.toastMessage("An error occurred: $e", Colors.red);
    }
  }

  Future<void> addDog(BuildContext context) async {
    // Reference to the DogList node
    DatabaseReference refEvent = _database
        .child('Events')
        .child(widget.eventId)
        .child('Runes')
        .child(widget.runeId)
        .child('DogList');

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Dog'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                        controller: dogNameC,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dogOwnerC,
                      decoration: const InputDecoration(labelText: 'Owner'),
                    ),
                    TextField(
                      controller: dogBreedC,
                      decoration: const InputDecoration(labelText: 'Breed'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dogCompetitorC,
                      decoration:
                          const InputDecoration(labelText: 'Competitor#'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    // Create a new unique document for each dog
                    DatabaseReference newDogRef = refEvent.push();

                    Map<String, dynamic> newDog = {
                      'dogName': dogNameC.text,
                      'ownerName': dogOwnerC.text ?? '',
                      'breed': dogBreedC.text ?? '',
                      'competitorName': dogCompetitorC.text ?? '',
                      'claimed': false,
                      'checkedIn': false,
                      "createdAt": DateTime.now().toString(),
                    };

                    // Save the new dog data
                    await newDogRef.set(newDog);

                    // Clear the form fields
                    dogNameC.clear();
                    dogOwnerC.clear();
                    dogBreedC.clear();
                    dogCompetitorC.clear();

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
          IconButton(
            onPressed: () {
              sendNotification(context);
            },
            icon: const Icon(
              Icons.notifications,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          labelStyle: const TextStyle(
              fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.bold),
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
            Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return StreamBuilder(
                        stream: _database
                            .child("Events")
                            .child(widget.eventId)
                            .child("Runes")
                            .child(widget.runeId)
                            .child('DogList')
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.snapshot.value != null) {
                            Map<dynamic, dynamic> dataMap = snapshot
                                .data!.snapshot.value as Map<dynamic, dynamic>;

                            // Convert the Map to a List
                            List<Map<String, dynamic>> dogs = dataMap.entries
                                .map((entry) {
                                  var dog = entry.value;
                                  return {
                                    'id': entry
                                        .key, // Use Firebase's unique key as the dog's ID
                                    'breed': dog['breed'],
                                    'competitorName': dog['competitorName'],
                                    'dogName': dog['dogName'],
                                    'ownerName': dog['ownerName'],
                                    'claimed': dog['claimed'] ?? false,
                                    'checkedIn': dog['checkedIn'] ?? false,
                                    'completed': dog['completed'] ?? false,
                                    'order': dog['order'] ?? 0,
                                  };
                                })
                                .where((dog) =>
                                    dog['completed'] ==
                                    false) // Filter only dogs not claimed
                                .toList();

                            // Sort the list based on the order
                            dogs.sort(
                                (a, b) => a['order'].compareTo(b['order']));

                            return dogs.isNotEmpty
                                ? RunningDogListWidget(
                                    dogList: dogs,
                                    eventId: widget.eventId,
                                    runeId: widget.runeId,
                                    runeName: widget.runeName,
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(top: 15),
                                    child: Center(child: Text('No Dogs Found')),
                                  );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_forever_outlined,
                                      size: 24.h),
                                  const Text('No Dogs Found'),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                ExcelButton(
                  title: "Add Excel File",
                  onPress: _pickAndUploadExcel,
                ),
                SizedBox(height: 10.h),
                ExcelButton(
                  title: "Add Dog",
                  color: AppColors.buttonColor,
                  onPress: () {
                    addDog(context);
                  },
                ),
              ],
            ),

            Builder(
              builder: (context) {
                return StreamBuilder(
                  stream: _database
                      .child("Events")
                      .child(widget.eventId)
                      .child("Runes")
                      .child(widget.runeId)
                      .child('DogList')
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.snapshot.value != null) {
                      // Cast snapshot value to Map instead of List
                      Map<dynamic, dynamic> dataMap = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;

                      // Convert the map to a list of dogs
                      List<Map<String, dynamic>> dogs = dataMap.entries
                          .map((entry) {
                            var dog = entry.value as Map<dynamic, dynamic>;
                            return {
                              'id': entry
                                  .key, // Firebase's unique key as the dog's ID
                              'breed': dog['breed'],
                              'competitorName': dog['competitorName'],
                              'dogName': dog['dogName'],
                              'ownerName': dog['ownerName'],
                              'imgUrl': dog['imgUrl'] ??
                                  '', // Handle missing image URLs
                              'claimed': dog['claimed'] ?? false,
                              'completed': dog['completed'] ?? false,
                            };
                          })
                          .where((dog) =>
                              dog['completed'] ==
                              true) // Filter dogs that are claimed
                          .toList();
                      return dogs.isNotEmpty
                          ? CompletedDogListWidget(
                              list: dogs,
                              isEdit: true,
                              eventId: widget.eventId,
                              runeId: widget.runeId,
                            )
                          : const Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Center(
                                child: Text('No Dogs Found'),
                              ),
                            );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_forever_outlined, size: 24.h),
                            const Text('No Dogs Found'),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
            // Stack(
            //   children: [
            //     // const CompletedDogListWidget(),
            //     // Positioned(
            //     //   bottom: 30.h,
            //     //   left: 0,
            //     //   right: 0,
            //     //   child: ExcelButton(
            //     //     title: "End the Event",
            //     //     borderColor: AppColors.buttonColor,
            //     //     onPress: _pickAndUploadExcel,
            //     //   ),
            //     // ),
            //   ],
            // ),
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

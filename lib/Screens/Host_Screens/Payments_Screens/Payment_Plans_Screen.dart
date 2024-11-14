import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import '../../../Widgets/colors.dart';
import 'Purchase_Plan_Screen.dart';

class PaymentPlansScreen extends StatefulWidget {
  const PaymentPlansScreen({super.key});

  @override
  State<PaymentPlansScreen> createState() => _PaymentPlansScreenState();
}

class _PaymentPlansScreenState extends State<PaymentPlansScreen> {
  Map<String, dynamic> userData = {};
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  void _navigateToPurchasePlan(PackageModel package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchasePlanScreen(
          package: package,
        ),
      ),
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    userData = await getCurrentUserData() ?? {};
    setState(() {});
  }

  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();
  @override
  Widget build(BuildContext context) {
    final isFreeTrialUsed = userData['freeTrialUsed'] ?? false;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 20.w),
                    Text(
                      "Plans",
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
                StreamBuilder<List<PackageModel>>(
                  stream: packagesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No packages available.');
                    } else {
                      final packages = snapshot.data!;
                      return Column(
                        children: packages.map(
                          (package) {
                            return isFreeTrialUsed && package.renewal == 'Free'
                                ? const SizedBox.shrink()
                                : package.renewal != userData['planType']
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.grey.shade300,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25.h,
                                                vertical: 10.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${package.title} (${package.renewal})',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "Poppins",
                                                    fontSize: 24.sp,
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                Text(
                                                  package.description,
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Event Amount",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: "Poppins",
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                    Text(
                                                      package.price == "Free"
                                                          ? 'Free'
                                                          : "\$${package.price}",
                                                      style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 20.sp,
                                                        color: AppColors
                                                            .buttonColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15),
                                                  child: RoundButton(
                                                    title:
                                                        userData['planType'] ==
                                                                package.renewal
                                                            ? "View"
                                                            : "Select Plan",
                                                    onPress: () async {
                                                      if (userData[
                                                              'planType'] ==
                                                          package.renewal) {
                                                        Get.bottomSheet(
                                                          ViewMemberShip(
                                                            userData: userData,
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      _navigateToPurchasePlan(
                                                          package);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                          },
                        ).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<PackageModel>> packagesStream() {
    return _databaseRef.child('Packages').onValue.map(
      (event) {
        final packagesMap =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        final packagesList = packagesMap.entries.map(
          (entry) {
            return PackageModel.fromMap(
              entry.key,
              Map<String, dynamic>.from(entry.value),
            );
          },
        ).toList();

        return packagesList;
      },
    );
  }
}

class PackageModel {
  final String id;
  final String title;
  final String description;
  final String price;
  final String renewal;
  final String eventsCount;

  PackageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.eventsCount,
    required this.renewal,
  });

  factory PackageModel.fromMap(String id, Map<String, dynamic> map) {
    return PackageModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      eventsCount: map['eventsCount'] ?? '',
      renewal: map['renewal'] ?? '',
    );
  }
}

class ViewMemberShip extends StatelessWidget {
  const ViewMemberShip({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Plan End Date:   ",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Palanquin Dark',
                    ),
                  ),
                  Text(
                    formatDate(userData['planEndDate']),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Palanquin Dark',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    "Events Count Remaining:   ",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Palanquin Dark',
                    ),
                  ),
                  Text(
                    userData['eventCount'],
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Palanquin Dark',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    DateFormat dateFormat = DateFormat('dd MMM yyyy');
    return dateFormat.format(dateTime);
  }
}

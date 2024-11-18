import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:queme/Screens/Host_Screens/Payments_Screens/Payment_Plans_Screen.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import '../../../Widgets/colors.dart';
import 'Purchase_Plan_Screen.dart';

class AdminPaymentPlanScreen extends StatefulWidget {
  const AdminPaymentPlanScreen({super.key});

  @override
  State<AdminPaymentPlanScreen> createState() => _AdminPaymentPlanScreenState();
}

class _AdminPaymentPlanScreenState extends State<AdminPaymentPlanScreen> {
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

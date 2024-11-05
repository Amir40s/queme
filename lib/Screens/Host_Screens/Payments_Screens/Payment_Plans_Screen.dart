import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:queme/Screens/Host_Screens/Host_Dashboard/host_bottom_nav.dart';
import 'package:queme/Utils/Utils.dart';
import 'package:queme/Widgets/round_button.dart';
import 'package:queme/provider/eventProvider.dart';
import '../../../Widgets/colors.dart';
import 'Purchase_Plan_Screen.dart';

class PaymentPlansScreen extends StatefulWidget {
  const PaymentPlansScreen({super.key});

  @override
  State<PaymentPlansScreen> createState() => _PaymentPlansScreenState();
}

class _PaymentPlansScreenState extends State<PaymentPlansScreen> {
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

  final DatabaseReference _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://queme-f9d7f-default-rtdb.firebaseio.com/')
      .ref();
  @override
  Widget build(BuildContext context) {
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
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.grey.shade300,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.h, vertical: 10.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.title,
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Event Amount",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                              color: AppColors.buttonColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: RoundButton(
                                          title: "Select Plan",
                                          onPress: () async {
                                            final currentUser = FirebaseAuth
                                                .instance.currentUser;
                                            if (package.price == "Free") {
                                              _database
                                                  .child('Users')
                                                  .child(currentUser!.uid)
                                                  .update({
                                                'freeTrial': 'true',
                                                'freeTrialStart':
                                                    DateTime.now().toString(),
                                              });
                                              final data = await Provider.of<
                                                          EventProvider>(
                                                      context,
                                                      listen: false)
                                                  .getCurrentUserData();
                                              Provider.of<EventProvider>(
                                                      context,
                                                      listen: false)
                                                  .addPayment(
                                                      package,
                                                      data['name'],
                                                      data['profileImageUrl'] ??
                                                          '');

                                              Utils.toastMessage(
                                                  'Free trial started',
                                                  Colors.green);
                                              Provider.of<EventProvider>(
                                                      context,
                                                      listen: false)
                                                  .changeUserType('Host');
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HostBottomNav(),
                                                ),
                                              );
                                              return;
                                            }
                                            _navigateToPurchasePlan(package);
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

  PackageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  factory PackageModel.fromMap(String id, Map<String, dynamic> map) {
    return PackageModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
    );
  }
}

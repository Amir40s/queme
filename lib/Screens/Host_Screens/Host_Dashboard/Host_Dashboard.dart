import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Widgets/round_button.dart';
import '../../Auth/Login_Screen.dart';
import '../Events_Screens/Add_New_Event.dart';
import '../Events_Screens/Event_Details_Screen.dart';


class HostDashboard extends StatefulWidget {
   const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://queme-app-3e7ae-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents(); // Fetch events when the page loads
    _searchController.addListener(_filterEvents); // Add listener for search functionality
  }

  Future<void> _fetchEvents() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      _database.child("Users")
          .child(uid).child("Events")
          .onValue.listen((event) {
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          List<Map<String, dynamic>> loadedEvents = [];
          data.forEach((key, value) {
            loadedEvents.add({
              'eventId': key,
              'eventName': value['eventName'],
              'eventLocation': value['eventLocation'],
              'eventStartDate': value['eventStartDate'],
              'eventEndDate': value['eventEndDate'],
              'eventStartTime': value['eventStartTime'],
              'eventEndTime': value['eventEndTime'],
            });
          });
          setState(() {
            _events = loadedEvents;
            _filteredEvents = loadedEvents; // Initially, all events are shown
          });
        }
      });
    }
  }

  void _filterEvents() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((event) {
        return event['eventName'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  // Function to log out the user
  Future<void> _logout() async {
    await _auth.signOut();
    // Navigate back to the login screen after signing out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  const AddNewEvent()));
        },
        backgroundColor: Colors.red,
        shape:  const CircleBorder(),
        child:  const Center(child: Icon(Icons.add)),
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/dog_logo.svg',
                  height: 44.h,
                  width: 44.w,
                ),
                 SizedBox(width: 10.w),
                 Text(
                  "QUEME",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Palanquin Dark",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding:  EdgeInsets.all(15.0.h),
                    child: SvgPicture.asset(
                      'assets/images/bell.svg',
                      height: 20.h,
                      width: 20.w,
                    ),
                  ),
                ),
              ],
            ),
             SizedBox(height: 20.h),
            Container(
              height: 48.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5.sp),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset:  const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextFormField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration:  InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Events",
                    hintStyle:  TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                    suffixIcon:  Icon(Icons.search, size: 24.h),
                  ),
                ),
              ),
            ),
             SizedBox(height: 30.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upcoming Events",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: _filteredEvents.isNotEmpty
                  ? ListView.builder(
                itemCount: _filteredEvents.length,
                itemBuilder: (ctx, index) {
                  var event = _filteredEvents[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(
                            eventId: event['eventId'] ?? '', // Add default value if null
                            eventName: event['eventName'] ?? 'Unknown Event', // Default to a non-null string
                            eventLocation: event['eventLocation'] ?? 'No Location', // Default to a non-null string
                            eventStartDate: event['eventStartDate'] ?? 'No Start Date', // Default value
                            eventStartTime: event['eventStartTime'] ?? '', // Default value
                            eventEndTime: event['eventEndTime'] ?? '', // Default value
                            eventEndDate: event['eventEndDate'] ?? '', // Default value
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin:  EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset:  Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['eventName'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                             SizedBox(height: 5.h),
                            Row(
                              children: [
                                 Icon(Icons.calendar_month, size: 20.h),
                                 SizedBox(width: 5.w,),
                                Text("${event['eventStartDate']} - ${event['eventEndDate']}"),
                              ],
                            ),
                             SizedBox(height: 5.h),
                            Row(
                              children: [
                                 Icon(Icons.location_on_outlined, size: 20.h),
                                 SizedBox(width: 5.w,),
                                Text(event['eventLocation']),
                              ],
                            ),
                             SizedBox(height: 5.h),
                            Row(
                              children: [
                                 Icon(Icons.timelapse, size: 20.h),
                                 SizedBox(width: 5.w,),
                                Text("${event['eventStartTime']} - ${event['eventEndTime']}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  :Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_outlined, size: 24.h),
                   Center(child: Text('No Events Created Yet')),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(10.0),
        child: RoundButton(
          title: "Logout",
          onPress: () {
            _logout();
          },
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Auth/Login_Screen.dart';
import 'Events_Screen/Events_Screen.dart';
import 'Home_Screen/Home_Screen.dart';
import 'Profile_Screen/Profile_Screen.dart'; // Assuming you have the LoginScreen

// Main Participant Bottom Navigation Bar screen
class ParticipentBottomNav extends StatefulWidget {
  const ParticipentBottomNav({super.key});

  @override
  State<ParticipentBottomNav> createState() => _ParticipentBottomNavState();
}

class _ParticipentBottomNavState extends State<ParticipentBottomNav> {
  int _selectedIndex = 0; // Index to track the selected tab

  // List of widgets to navigate between different tabs
  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const EventsScreen(),
    const ProfileScreen(),
  ];

  // Handle the bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to get the appropriate icon based on selection
  Widget _getIcon(String assetPath, bool isSelected) {
    return isSelected
        ? Container(
            height: 36.h,
            width: 88.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(
                assetPath,
                height: 24.h, // Adjust the icon size if necessary
                width: 24.w,
                color: Colors.red, // Change color based on selected state
              ),
            ),
          )
        : SvgPicture.asset(
            assetPath,
            height: 24.h, // Adjust the icon size if necessary
            width: 24.w,
            color: Colors.black, // Change color based on selected state
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: _screens[_selectedIndex], // Display the corresponding screen
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[300], // Background color for the BottomNavigationBar
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _getIcon('assets/images/home.svg', _selectedIndex == 0), // Check if Home is selected
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _getIcon('assets/images/events.svg', _selectedIndex == 1), // Check if Events is selected
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: _getIcon('assets/images/profile.svg', _selectedIndex == 2), // Check if Profile is selected
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Currently selected index
        selectedItemColor: Colors.red, // Color for the selected item
        unselectedItemColor: Colors.black, // Color for unselected items
        onTap: _onItemTapped, // Handle item tap
      ),
    );
  }
}

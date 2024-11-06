import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Partcipants_Screens/Profile_Screen/Profile_Screen.dart';
import '../Payments_Screens/Payment_Plans_Screen.dart';
import 'Host_Dashboard.dart';

// Main Participant Bottom Navigation Bar screen
class HostBottomNav extends StatefulWidget {
  const HostBottomNav({super.key});

  @override
  State<HostBottomNav> createState() => _HostBottomNavState();
}

class _HostBottomNavState extends State<HostBottomNav> {
  int _selectedIndex = 0; // Index to track the selected tab

  // List of widgets to navigate between different tabs
  static final List<Widget> _screens = <Widget>[
    const HostDashboard(),
    const PaymentPlansScreen(),
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
              child: SizedBox(
                child: SvgPicture.asset(
                  assetPath,
                  height: 24.h, // Adjust the icon size if necessary
                  width: 24.w,
                  color: Colors.red, // Change color based on selected state
                ),
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
        backgroundColor:
            Colors.grey[300], // Background color for the BottomNavigationBar
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _getIcon('assets/images/home.svg',
                _selectedIndex == 0), // Check if Home is selected
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _getIcon('assets/images/plans.svg',
                _selectedIndex == 1), // Check if Events is selected
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: _getIcon('assets/images/profile.svg',
                _selectedIndex == 2), // Check if Profile is selected
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

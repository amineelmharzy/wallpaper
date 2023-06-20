import 'package:flutter/material.dart';
import '../main.dart';

class BottomNavbar extends StatefulWidget {
  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: (int) {},
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  CustomBottomNavigationBar(
      {required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(3.0),
        topRight: Radius.circular(3.0),
      ),
      child: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
        currentIndex: currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.indigo[600], // Color for the selected item
        unselectedItemColor: Colors.white, // Color for the unselected items
        items: [
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(top: 12),
              child: Icon(Icons.home, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(top: 12),
              child: Icon(Icons.auto_awesome_mosaic_rounded, size: 30),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(top: 12),
              child: Icon(Icons.favorite, size: 30),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

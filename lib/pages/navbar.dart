// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:matibabu/pages/history.dart';
import 'package:matibabu/pages/home.dart';
import 'package:matibabu/pages/profile.dart';
import 'package:matibabu/pages/search.dart';

class BottomBarScreen extends StatefulWidget {
  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List<Map<String, Widget>> _pages = [];
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _pages = [
      {
        'page': home(),
      },
      {
        'page': Search(),
      },
      {
        'page': history(),
      },
      {
        'page': profile(),
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 0.01,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: kBottomNavigationBarHeight * 0.98,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              onTap: _selectPage,
              unselectedItemColor: Colors.black,
              selectedItemColor: Colors.white,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                    backgroundColor: Color.fromRGBO(43, 147, 128, 20)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                    backgroundColor: Color.fromRGBO(43, 147, 128, 20)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.medical_services),
                    label: 'History',
                    backgroundColor: Color.fromRGBO(43, 147, 128, 20)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                    backgroundColor: Color.fromRGBO(43, 147, 128, 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

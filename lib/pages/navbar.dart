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
        'page': search(),
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
          // color: Colors.white,
          shape: CircularNotchedRectangle(),
          notchMargin: 0.01,
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: kBottomNavigationBarHeight * 0.98,
            // color: Colors.green,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                onTap: _selectPage,
                backgroundColor: Colors.green,
                unselectedItemColor: Colors.black,
                selectedItemColor: Colors.purple,
                currentIndex: _selectedPageIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home'.toString(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'search'.toString(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.medical_services),
                    label: 'History'.toString(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile'.toString(),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

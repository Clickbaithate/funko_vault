// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:funko_vault/data/colors.dart';
import 'package:funko_vault/screens/folder.dart';
import 'package:funko_vault/screens/home.dart';
import 'package:funko_vault/screens/liked.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {

  int _currentPageIndex = 1;
  bool _isContentVisible = false;

  final List<Widget> _screens = [
    FolderPage(),
    HomePage(),
    LikedPage(),
  ];

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isContentVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0, 
        duration: Duration(seconds: 1),
        child: IndexedStack(
          index: _currentPageIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0, 
        duration: Duration(seconds: 1),
        child: Container(
          margin: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: blackColor,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              indicatorShape: CircleBorder(),
            ),
            child: NavigationBar(
              selectedIndex: _currentPageIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              indicatorColor: Colors.transparent,
              onDestinationSelected: (index) => setState(() => _currentPageIndex = index),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined, color: biegeColor.withOpacity(0.3), size: 40),
                  selectedIcon: Icon(Icons.folder, color: biegeColor, size: 40),
                  label: "Folders Page",
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: blueColor.withOpacity(0.3), size: 40),
                  selectedIcon: Icon(Icons.home, color: blueColor, size: 40),
                  label: "Home Page",
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_outline, color: redColor.withOpacity(0.3), size: 40),
                  selectedIcon: Icon(Icons.favorite, color: redColor, size: 40),
                  label: "Liked Page",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

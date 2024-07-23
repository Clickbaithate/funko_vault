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

  final List<Widget> _screens = [
    FolderPage(),
    HomePage(),
    LikedPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentPageIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: blackColor,
              blurRadius: 10,
              offset: Offset(0, 4)
            )
          ]
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            indicatorShape: CircleBorder()
          ),
          child: NavigationBar(
            selectedIndex: _currentPageIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: Colors.transparent,
            onDestinationSelected: (index) => setState(() => _currentPageIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.folder_outlined, color: grayColor, size: 40),
                selectedIcon: Icon(Icons.folder, color: biegeColor, size: 40),
                label: "Folders Page",
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: grayColor, size: 40),
                selectedIcon: Icon(Icons.home, color: blueColor, size: 40),
                label: "Home Page",
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline, color: grayColor, size: 40),
                selectedIcon: Icon(Icons.favorite, color: redColor, size: 40),
                label: "Liked Page",
              )
            ],
          ),
        ),
      )
    );
  }
}

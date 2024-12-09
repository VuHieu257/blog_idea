import 'package:blog_idea_app/screens/account/my_account.dart';
import 'package:blog_idea_app/screens/home/home/home.dart';
import 'package:blog_idea_app/screens/home/trending/trending.dart';
import 'package:blog_idea_app/screens/login/sign_in.dart';
import 'package:blog_idea_app/service/get_x/get_x.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../view/view_create.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({
    super.key,
  });

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  final UserDataController userDataController = Get.put(UserDataController());
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TabBarHome(),
    const TrendingScreen(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedIndex == 1
          ? ViewCreateBlogIdea(
              id: "${userDataController.id}",
              idUser: "idUser",
              name: "${userDataController.displayName}",
              description: "",
              postsId: '',
              imgPost: '',
              likeNumer: 0,
              statusViewCreateBlogIdea: false,
            )
          : _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 10,
              color: Colors.black54,
            ),
          ],
        ),
        child: GNav(
          color: Colors.grey[800],
          activeColor: Colors.blue,
          hoverColor: Colors.blue.shade100,
          tabBackgroundColor: Colors.blue.shade100.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          duration: const Duration(milliseconds: 800),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              // iconMarket
              icon: Icons.add_circle_outline,
              text: 'Article',
            ),
            GButton(
              icon: Icons.supervised_user_circle_outlined,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

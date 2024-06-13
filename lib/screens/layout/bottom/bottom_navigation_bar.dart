import 'package:blog_idea_app/screens/account/my_account.dart';
import 'package:blog_idea_app/screens/home/home/home.dart';
import 'package:blog_idea_app/screens/home/trending/trending.dart';
import 'package:blog_idea_app/screens/login/sign_in.dart';
import 'package:blog_idea_app/service/get_x/get_x.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({
    super.key,
  });

  @override
  State<BottomNavigationBarWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {


  final UserDataController userDataController = Get.put(UserDataController());
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Styles.nearlyWhite,
          title: const Text("B-Idea",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 30),),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  _showPopupMenu(context, details.globalPosition,"${userDataController.displayName}");
                },
                child: const Icon(Icons.settings,size: 30,),
              ),
            ),],
          bottom: TabBar(
            dividerColor: Styles.defaultLightGreyColor,
            indicatorColor: Styles.defaultBlueColor,
            labelColor: Styles.defaultBlueColor,
            tabs: const [
              Tab(icon: Icon(Icons.home,size: 30,)),
              Tab(icon: Icon(Icons.local_fire_department,size: 30)),
              Tab(icon: Icon(Icons.account_circle,size: 30)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const HomeScreen(),
            const TrendingScreen(),
            AccountPage(id:"${userDataController.id}"),
          ],
        ),
      ),
    );
  }
  void _showPopupMenu(BuildContext context, Offset position,String name) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(child: InkWell(onTap: () {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen(),));
          // userDataController.updateUserData("","","");
        },
          child:Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 5,),
              Text(name),
              const Divider(),
            ],
          ),)),
        PopupMenuItem(child: InkWell(onTap: () {
          FirebaseAuth.instance.signOut();
         Get.offAll(const SignInScreen(),);
          // userDataController.updateUserData("","","");
        },
          child: const Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 5,),
              Text("LogOut"),
            ],
          ),)),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        if (value == 'edit') {
          print('Edit option selected');
        } else if (value == 'delete') {
          print('Delete option selected');
        }
      }
    });
  }
}

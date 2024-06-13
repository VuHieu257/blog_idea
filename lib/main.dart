import 'package:blog_idea_app/screens/layout/bottom/bottom_navigation_bar.dart';
import 'package:blog_idea_app/screens/login/sign_in.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get/get_navigation/src/root/get_material_app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  options: kIsWeb ||Platform.isAndroid?
  await Firebase.initializeApp(
    // name:"b-idea-b5e02",
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAa58C3JobxigKYnj-kfdDztCOZc-ycCQE',
          appId: '1:966122516663:android:670e20e49319be6a325d32',
          messagingSenderId: '966122516663',
          projectId: 'b-idea-b5e02',
          storageBucket: "b-idea-b5e02.appspot.com"
      )) :
  await Firebase.initializeApp();
  // await AuthService().signInUserAnon();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Styles.nearlyWhite,
        useMaterial3: true,
      ),
      home: const SignInScreen(),
      // home: const BottomNavigationBarWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}


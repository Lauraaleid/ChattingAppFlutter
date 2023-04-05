
import 'package:chat_app_flutter/Screens/Login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Screens/Home/home_screen.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // now writing code that will check if the user is logged in or not.
  // depending in that the respective screen will open.
  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      //returning HomeScreen
      return HomeScreen();
    } else {
      //returning LoginScreen
      return LogInScreen();
    }
  }
}
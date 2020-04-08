import 'package:flutter/material.dart';
import 'package:i_am_rich/services/auth_service.dart';
import 'root_page.dart';
import 'package:provider/provider.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(new Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: new MaterialApp(
//          theme: ThemeData(
//            brightness: Brightness.light,
//            primaryColor: Colors.red,
//          ),
//          darkTheme: ThemeData(
//            brightness: Brightness.dark,
//          ),
          title: 'NightWatch',
          debugShowCheckedModeBanner: false,
          home: new RootPage(auth: new AuthService())),
    );
  }
}
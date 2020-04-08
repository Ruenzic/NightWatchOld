import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MapState();
  }
}

class _MapState extends State<MapView> {
  //  @override

  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final firebaseUser = Provider.of<FirebaseUser>(context);
    if (user != null){
      print('provider user map page');
      print(user.userName);
    }

    if (firebaseUser != null){
      print('provider firebase user map page');
      print(firebaseUser.uid);
    }



    return Container();
  }

}
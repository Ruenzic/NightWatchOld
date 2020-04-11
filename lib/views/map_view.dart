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

    if (user == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (user.watchGroupId == null) {
        return Column(
          children: <Widget>[
            Center(
              child: showImage(),
            ),
            Center(
              child: Text(
                'You don\'t belong to any watch group',
                style: new TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          ],
        );
      } else {
        return Text('would show map here');
      }
    }
  }

  Widget showImage() {
    return Column(
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/no_group.png',
            width: 150,
          ),
        ),
      ],
    );
  }
}











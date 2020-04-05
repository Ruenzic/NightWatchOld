import 'package:flutter/material.dart';
import 'authentication.dart';

class ProfileView extends StatefulWidget {
  ProfileView({this.auth, this.userId, this.logoutCallback});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _ProfileState();

}

class _ProfileState extends State<ProfileView> {
  //  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: showLogoutButton(),
    );
  }

  Widget showLogoutButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: new Text('Logout',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: signOut,
        ),
      ),
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

}


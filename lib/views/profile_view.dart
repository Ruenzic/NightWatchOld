import 'package:flutter/material.dart';
import 'package:i_am_rich/services/auth_service.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/services/user_service.dart';

class ProfileView extends StatefulWidget {
  ProfileView({this.auth, this.userId, this.logoutCallback, this.user});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final User user;

  @override
  State<StatefulWidget> createState() => new _ProfileState();
}

class _ProfileState extends State<ProfileView> {
  //  @override
  Widget build(BuildContext context) {
    return StreamProvider<DocumentSnapshot>.value(
      value: UserService().user,
      child: Scaffold(
        backgroundColor: Color.fromARGB(1, 114, 114, 132),
        body: Stack(
          children: <Widget>[
            showProfile(),
          ],
        ),
      ),
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

  Widget showProfilePicture() {
    return Center(
      child: Container(
        width: 160.0,
        height: 160.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/default_profile_picture.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(90.0),
          border: Border.all(
            color: Colors.white,
            width: 5.0,
          ),
        ),
      ),
    );
  }

  Widget showUserName() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: Center(
        child: getUserName(),
      ),
    );
  }

//  getUserName() {
////    UserService(userId: widget.userId).getData();
//    return 'test';
//  }

  Widget getUserName() {
//    return new StreamBuilder(
//      stream: UserService(userId: widget.userId).user,
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return new Text(
//            "Loading..",
//            style: TextStyle(
//                fontWeight: FontWeight.bold,
//                color: Colors.white,
//                fontSize: 25.0),
//          );
//        }
//        var userDocument = snapshot.data;
//        return new Text(
//          userDocument["name"],
//          style: TextStyle(
//              fontWeight: FontWeight.bold,
//              color: Colors.white,
//              fontSize: 25.0),
//        );
//      });

    return new FutureBuilder(
      future: UserService(userId: widget.userId).getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return new Text(
            "Loading..",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 25.0),
          );
        }
        var userDocument = snapshot.data;
        return new Text(
          userDocument["name"],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25.0),
        );
      });
  }

  showProfile() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          showProfilePicture(),
          showUserName(),
          showLogoutButton(),
        ],
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

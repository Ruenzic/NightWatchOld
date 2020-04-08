import 'package:flutter/material.dart';
import 'package:i_am_rich/services/auth_service.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/services/user_service.dart';

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
    User user = Provider.of<User>(context);

      return Stack(
        children: <Widget>[
          showProfile(user),
        ],
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
          color: Color.fromRGBO(254,109,64,1),
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
            color: Colors.blueGrey[900],
            width: 3.0,
          ),
        ),
      ),
    );
  }

  Widget showUserName(User user) {
    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Text(
            "Loading..",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25.0),
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Text(
            user.userName,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25.0),
          ),
        ),
      );
    }
  }

//  Widget getUserName() {
//
//    return new FutureBuilder(
//      future: UserService(userId: widget.userId).getData(),
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
//  }

  showProfile(User user) {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          showProfilePicture(),
          showUserName(user),
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

import 'package:flutter/material.dart';
import 'package:i_am_rich/views/login_view.dart';
import 'package:i_am_rich/services/auth_service.dart';
import 'package:i_am_rich/views/tabs_view.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:provider/provider.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId;
  String _watchGroupId;
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _watchGroupId = user?.displayName;
          _user = user;
        }
        authStatus =
        user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
        _watchGroupId = user.displayName;
        _user = user;
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
      _watchGroupId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final firebaseUser = Provider.of<FirebaseUser>(context);

    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginView(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          print(_userId);
          print(_watchGroupId);
          return new TabsView(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
            watchGroupId: _watchGroupId,
//            user: getUser(_userId)
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }

//  User getUser(String userId) async {
//    User user =  await UserService(userId: userId).userFromData();
//    return user;
//  }
}
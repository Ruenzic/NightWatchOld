import 'package:flutter/material.dart';
import 'package:i_am_rich/views/home_view.dart';
import 'schedule_view.dart';
import 'package:i_am_rich/views/map_view.dart';
import 'package:i_am_rich/views/profile_view.dart';
import 'package:i_am_rich/views/login_view.dart';
import 'dart:async';
import 'package:i_am_rich/services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:i_am_rich/models/watchgroup.dart';
import 'package:i_am_rich/services/watchgroup_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:i_am_rich/services/schedule_service.dart';

class TabsView extends StatefulWidget {
  TabsView({Key key, this.auth, this.userId, this.logoutCallback, this.watchGroupId})
    : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String watchGroupId;

  @override
  State<StatefulWidget> createState() => new _TabsState();

}

class _TabsState extends State<TabsView> {
//  @override

  int _currentIndex = 0;
  Widget _currentView = HomeView();

  Widget build(BuildContext context) {

    final firebaseUser = Provider.of<FirebaseUser>(context);
//    print(firebaseUser);
    return MultiProvider(
        providers: [
          StreamProvider<User>.value(value: UserService(userId: widget.userId).user),
          StreamProvider<WatchGroup>.value(value: WatchGroupService(watchGroupId: firebaseUser.displayName).watchGroup),
          StreamProvider<List<Timeslot>>.value(value: ScheduleService(watchGroupId: firebaseUser.displayName).timeSlots),
        ],

//    return StreamProvider<User>.value(
//      value: UserService(userId: widget.userId).user,
      child: Scaffold(
        appBar: AppBar(
          title: Text('NightWatch'),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: _currentView,
        backgroundColor: Color.fromRGBO(247, 247, 247, 1),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: Text('Home'),
              backgroundColor: Colors.blueGrey[900],
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today),
              title: Text('Schedule'),
              backgroundColor: Colors.blueGrey[900],
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.map),
              title: Text('Map'),
              backgroundColor: Colors.blueGrey[900],
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.account_circle),
              title: Text('Profile'),
              backgroundColor: Colors.blueGrey[900],
            ),
          ],
        ),
      ),
    );
  }


  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0: {
          return _currentView = HomeView();
        }
        case 1: {
          return _currentView =  ScheduleView();
        }
        case 2: {
          return _currentView =  MapView();
        }
        case 3: {
          return _currentView =  ProfileView(auth: widget.auth, userId: widget.userId, logoutCallback: widget.logoutCallback);
        }
        default: {
          return _currentView = LoginView();
        }
      }
    });
  }

}
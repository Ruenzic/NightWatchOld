import 'package:flutter/material.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:i_am_rich/services/user_service.dart';

class HomeView extends StatefulWidget {
  HomeView({this.userId});

  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<HomeView> {
  //  @override

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
         new FutureBuilder(
          future: UserService(userId: widget.userId).getData(),
          builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var userDocument = snapshot.data;
            return showJoinCreate(userDocument["watchGroupId"]);
        }
    )
      ],
    );
  }

  Widget showJoinCreate(String watchGroupId) {
    if (watchGroupId != null && watchGroupId.length > 0) {
      return Center(
        child: new Text(
         'Already in a watchgroup with id ${watchGroupId}'
        ),


      );
    }
    else if (watchGroupId == null || watchGroupId.length == 0) {
      return Center(
        child: new Text(
            'Join an Existing Watch Group or Create 1'
        ),


      );
    } else {
      return new Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }


}








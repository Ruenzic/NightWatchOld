import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:i_am_rich/models/watchgroup.dart';
import 'package:i_am_rich/models/timeslot.dart';

class ScheduleView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScheduleState();
  }
}

class _ScheduleState extends State<ScheduleView> {
  //  @override

  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    WatchGroup watchGroup = Provider.of<WatchGroup>(context);

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
        return Column(
          children: <Widget>[
            showTimeslots(watchGroup: watchGroup),
          ],
        );
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

  Widget showTimeslots({watchGroup: WatchGroup}) {
    List<Timeslot> timeslots = watchGroup.timeslots;
    // show list of timeslots or return text saying no timeslots
    if (timeslots.length == 0) {
      return Text(
        'No Timeslots added',
        overflow: TextOverflow.clip,
        textAlign: TextAlign.left,
        style: new TextStyle(
          fontSize: 20.0,
          color: new Color(0xFF212121),
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Heading
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0)),
            elevation: 4.0,
            child: Container(
              alignment: Alignment.center,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    ' Start',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  Text(
                    '           End',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  Text(
                    '     People',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                ],
              ),
            ),
            color: Colors.white,
          ),
          SizedBox(
            height: 20.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: new List.generate(
              timeslots.length,
              (i) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                        child: new RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 4.0,
                          onPressed: () {
                            print('do nothing');
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  timeslots.elementAt(i).startTime,
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                                Text(
                                  timeslots.elementAt(i).endTime,
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                                Text(
                                  timeslots.elementAt(i).numberUsers.toString(),
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 10,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
//                          removeTimeSlot(i);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Icon(
                            Icons.not_interested,
                            color: Colors.red,
                          ),
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

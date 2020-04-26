import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:i_am_rich/models/watchgroup.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/services/watchgroup_service.dart';
import 'package:i_am_rich/services/schedule_service.dart';

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
            showTimeslots(),
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

  Timeslot _timeSlotFromFirestore(DocumentSnapshot timeSlot) {
    return timeSlot != null
        ? Timeslot(
            startTime: timeSlot['startTime'],
            endTime: timeSlot['endTime'],
            numberUsers: timeSlot['numberUsers'],
            id: timeSlot.documentID,
            signups: timeSlot['signups'],
          )
        : null;
  }

  Widget showTimeslots() {
//    List<Timeslot> timeslots = Provider.of<List<Timeslot>>(context, listen: true);
    User user = Provider.of<User>(context);
    final firebaseUser = Provider.of<FirebaseUser>(context, listen: false);

    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('watchGroups')
            .document(user.watchGroupId)
            .collection('timeslots')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text("There are no timeslots");
          List<Timeslot> timeslots = snapshot.data.documents
              .map((DocumentSnapshot doc) => _timeSlotFromFirestore(doc))
              .toList();

          print(timeslots.first.signups['date']);
          print(getWeekDates());

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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        timeslots
                                            .elementAt(i)
                                            .numberUsers
                                            .toString(),
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
                          showScheduleButton(timeslot: timeslots.elementAt(i), date: currentDate(), userId: firebaseUser.uid, watchGroupId: firebaseUser.displayName),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget showScheduleButton({timeslot: Timeslot, date: String, userId: String, watchGroupId: String}) {
    ScheduleService scheduleService = ScheduleService(userId: userId, watchGroupId: watchGroupId);

    if (timeslot.signups != null && timeslot.signups[date] != null && timeslot.signups[date].contains(userId)) {
      return ButtonTheme(
        minWidth: 10,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),
          elevation: 4.0,
          onPressed: () {
            scheduleService.removeSignup(date: date, timeSlotId: timeslot.id);
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
      );
    }
    else{
      return ButtonTheme(
        minWidth: 10,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)),
          elevation: 4.0,
          onPressed: () {
            scheduleService.createSignup(date: date, timeSlotId: timeslot.id);
          },
          child: Container(
            alignment: Alignment.center,
            height: 50.0,
            child: Icon(
              Icons.add_circle,
              color: Colors.green,
            ),
          ),
          color: Colors.white,
        ),
      );
    }
  }

  currentDate() {
    return DateTime.now().toString().split(' ')[0];
  }

  getWeekDates() {
    var today = new DateTime.now();
    List dates = [];
    dates.add(today.toString().split(' ')[0]);

    for (var i = 1; i <= 6; i++) {
      var nextDate = today.add((new Duration(days: i)));
      dates.add(nextDate.toString().split(' ')[0]);
    }
    return dates;
  }


}

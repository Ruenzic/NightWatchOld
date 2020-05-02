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

  var _day = 0;

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
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              showTimeslots(),
            ],
          ),
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
    List weekDays = getWeekDates();
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

//          print(timeslots.first.signups['date']);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    showPreviousDay(weekdays: weekDays, day: _day),
                    showSelectedDay(weekdays: weekDays, day: _day),
                    showNextDay(weekdays: weekDays, day: _day),
                  ],
                ),
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
                                        getNumberSignups(
                                                timeslot:
                                                    timeslots.elementAt(i),
                                                date: weekDays[_day]
                                                    .toString()
                                                    .split(' ')[0]) +
                                            '/' +
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
                          showScheduleButton(
                              timeslot: timeslots.elementAt(i),
                              date: weekDays[_day].toString().split(' ')[0],
                              userId: firebaseUser.uid,
                              watchGroupId: firebaseUser.displayName),
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

  // Show a button showing previous or nothing if selected day is current date
  Widget showPreviousDay({weekdays: List, day: num}) {
    if (day > 0) {
      return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        elevation: 4.0,
        child: Text(
          '< ' + getShortWeekDay(dayOfWeek: weekdays[day - 1].weekday),
          style: TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        onPressed: previousDay,
      );
    } else {
//      return Expanded(child: SizedBox());
    return Container(height: 0, width: 0,);
    }
  }

  // Show next or nothing if end of week days
  Widget showNextDay({weekdays: List, day: num}) {
    if (day < 6) {
      return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        elevation: 4.0,
        child: Text(
          getShortWeekDay(dayOfWeek: weekdays[day + 1].weekday) + ' >',
          style: TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        onPressed: nextDay,
      );
    } else {
//      return Expanded(child: SizedBox());
      return Container(height: 0, width: 0,);
    }
  }

  // Show the day the user is viewing, 'Today' or 'Monday 18-07'
  Widget showSelectedDay({weekdays: List, day: num}) {
    var current = '';
    if (weekdays[day].toString().split(' ')[0] == currentDate()) {
      current = 'Today';
    } else {
      current = getShortWeekDay(dayOfWeek: weekdays[day].weekday);
      current += ' ${weekdays[day].day}-${weekdays[day].month}';
    }

    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      elevation: 4.0,
      child: Text(
        current,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
      ),
    );
  }

  // Return the string day of week from int
  getWeekDay({dayOfWeek: num}) {
    if (dayOfWeek == 1) {
      return 'Monday';
    } else if (dayOfWeek == 2) {
      return 'Tuesday';
    } else if (dayOfWeek == 3) {
      return 'Wednesday';
    } else if (dayOfWeek == 4) {
      return 'Thursday';
    } else if (dayOfWeek == 5) {
      return 'Friday';
    } else if (dayOfWeek == 6) {
      return 'Saturday';
    } else if (dayOfWeek == 7) {
      return 'Sunday';
    }
  }

  // Return the short string day of week from int
  getShortWeekDay({dayOfWeek: num}) {
    if (dayOfWeek == 1) {
      return 'Mon';
    } else if (dayOfWeek == 2) {
      return 'Tue';
    } else if (dayOfWeek == 3) {
      return 'Wed';
    } else if (dayOfWeek == 4) {
      return 'Thu';
    } else if (dayOfWeek == 5) {
      return 'Fri';
    } else if (dayOfWeek == 6) {
      return 'Sat';
    } else if (dayOfWeek == 7) {
      return 'Sun';
    }
  }

  getNumberSignups({timeslot: Timeslot, date: String}) {
    if (timeslot.signups != null && timeslot.signups[date] != null) {
      return timeslot.signups[date].length.toString();
    } else {
      return '0';
    }
  }

  Widget showScheduleButton(
      {timeslot: Timeslot,
      date: String,
      userId: String,
      watchGroupId: String}) {
    ScheduleService scheduleService =
        ScheduleService(userId: userId, watchGroupId: watchGroupId);

    if (timeslot.signups != null &&
        timeslot.signups[date] != null &&
        timeslot.signups[date].contains(userId)) {
      return ButtonTheme(
        minWidth: 10,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
    } else if (timeslot.signups != null &&
        timeslot.signups[date] != null &&
        timeslot.signups[date].contains(userId) == false &&
        int.parse(getNumberSignups(timeslot: timeslot, date: date)) <
            timeslot.numberUsers) {
      return ButtonTheme(
        minWidth: 10,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
    } else if (timeslot.signups == null || timeslot.signups[date] == null) {
      return ButtonTheme(
        minWidth: 10,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
    } else {
      return ButtonTheme(
        minWidth: 10,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          elevation: 4.0,
          child: Container(
            alignment: Alignment.center,
            height: 50.0,
            child: Icon(
              Icons.cancel,
              color: Colors.grey,
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
    dates.add(today);

    for (var i = 1; i <= 6; i++) {
      var nextDate = today.add((new Duration(days: i)));
      dates.add(nextDate);
    }
    return dates;
  }

  nextDay() {
    if (_day < 7) {
      setState(() {
        _day += 1;
      });
    }
  }

  previousDay() {
    if (_day > 0) {
      setState(() {
        _day -= 1;
      });
    }
  }
}

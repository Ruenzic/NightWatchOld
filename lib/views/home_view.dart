import 'package:flutter/material.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:geocoder/geocoder.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
//import 'package:i_am_rich/widgets/custom_picker_widget.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:i_am_rich/services/watchgroup_service.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

const kGoogleApiKey = "AIzaSyCv7unpr2HHILYfIZewVa4IvV8sApUs8OQ";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class _HomeState extends State<HomeView> {
//  @override

  bool _showCreateForm = false;
  final _formKey = new GlobalKey<FormState>();
  String _name;
  bool _isPrivate = false;
  var _formPage = 1;
  String _location_name;
  double _location_latitude;
  double _location_longitude;

  String _start_time = "Not set";
  String _end_time = "Not set";
  var _number_users = 2;
  bool _showTimeslotForm = false;

  bool _showFormError = false;
  List <String> _formErrors = [];

  var _daysOfWeek = {
    'monday': true,
    'tuesday': true,
    'wednesday': true,
    'thursday': true,
    'friday': true,
    'saturday': true,
    'sunday': true,
  };
  List<Timeslot> _timeslots = [];

  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final firebaseUser = Provider.of<FirebaseUser>(context);

    if (user == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (user.watchGroupId != null && user.watchGroupId.length > 0) {
        // Show content if the user has chosen a watch group
        return new Container(
          height: 0.0,
          width: 0.0,
        );
      } else {
        // Show content if the user hasn't chosen a watch group
        if (!_showCreateForm) {
          return Center(
            child: Column(children: <Widget>[
              welcomeHeading(),
              showJoinButton(),
              showCreateButton(),
            ]),
          );
        } else {
          return showForm();
        }
      }
    }
  }

  Widget showForm() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Form(key: _formKey, child: showFormStep()),
    );
  }

  Widget showFormStep() {
    if (_formPage == 1) {
      return new ListView(
        shrinkWrap: true,
        children: <Widget>[
          showNameInput(),
          showLocationInput(),
          SizedBox(
            height: 20.0,
          ),
          showFormErrors(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              showCancelFormButton(),
              showNextButton(),
            ],
          ),
        ],
      );
    } else if (_formPage == 2) {
      return new ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(
            'On which days of the week do you operate?',
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: new Color(0xFF212121),
            ),
          ),
          monday(),
          tuesday(),
          wednesday(),
          thursday(),
          friday(),
          saturday(),
          sunday(),
          SizedBox(
            height: 20.0,
          ),
          showFormErrors(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              showPreviousButton(),
              showNextButton(),
            ],
          ),
        ],
      );
    } else if (_formPage == 3) {
      if (_showTimeslotForm) {
        return Column(
          children: <Widget>[
            showTimeslotForm(),
          ],
        );
      } else {
        return Column(
          children: <Widget>[
            showTimeslots(),
            viewTimeslotFormButton(),
            SizedBox(
              height: 20.0,
            ),
            showFormErrors(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                showPreviousButton(),
                showCreateWatchGroupButton(),
              ],
            ),
          ],
        );
      }
    } else {
      return Container(
        height: 0,
        width: 0,
      );
    }
  }

  Widget showCreateWatchGroupButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 4.0,
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text(
            'Create',
            style: new TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: createWatchGroup,
        ),
      ),
    );
  }

  createWatchGroup(){
    // create watchgroup, get back an id then update the user object with the watchgroup id
    // this should then trigger the listener to take us out the form to the home page
    final firebaseUser = Provider.of<FirebaseUser>(context, listen: false);
    print('would create watch group');
    WatchGroupService watchGroupService = WatchGroupService(userId: firebaseUser.uid);
    watchGroupService.createWatchGroup(_name, _timeslots, _location_name, _location_latitude, _location_longitude, _daysOfWeek);
  }

  Widget showTimeslots() {
    // show list of timeslots or return text saying no timeslots
    if (_timeslots.length == 0) {
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
                borderRadius: BorderRadius.circular(5.0)),
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
              _timeslots.length,
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
                                  _timeslots.elementAt(i).startTime,
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                                Text(
                                  _timeslots.elementAt(i).endTime,
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                                Text(
                                  _timeslots
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
                    ButtonTheme(
                      minWidth: 10,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
                          removeTimeSlot(i);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Icon(
                            Icons.delete,
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

  removeTimeSlot(int i) {
    setState(() {
      _timeslots.removeAt(i);
    });
  }

  Widget showFormErrors(){
    if (_showFormError){
      return Column(
        children: new List.generate(
          _formErrors.length,
          (i) =>
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Text(
                _formErrors.elementAt(i),
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
            ),
          ),
        )
      );
    }
    else{
      return Container(
        height: 0,
        width: 0,
      );
    }
  }

  Widget viewTimeslotFormButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          shape: CircleBorder(),
          elevation: 4.0,
          color: Colors.teal,
          child: new Icon(Icons.add, color: Colors.white),
          onPressed: viewTimeslotForm,
        ),
      ),
    );
  }

  viewTimeslotForm() {
    setState(() {
      // Empty form errors array so we remove the 'No timeslots added' error after user goes to add form
      _formErrors = [];
      _showFormError = false;
      _showTimeslotForm = true;
    });
  }

  Widget showTimeslotForm() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Add Timeslot',
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: new Color(0xFF212121),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showTimePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true, onConfirm: (time) {
                      print('confirm $time');
                      if (time.minute.toString() == "0" && time.hour.toString() == '0') {
                        _start_time = '${time.hour}0 : ${time.minute}0';
                      }
                      else if (time.minute.toString() == "0") {
                        _start_time = '${time.hour} : ${time.minute}0';
                      }
                      else if (time.hour.toString() == "0") {
                        _start_time = '${time.hour}0 : ${time.minute}';
                      }
                      else {
                        _start_time = '${time.hour} : ${time.minute}';
                      }
//                      validateTimeSlot(_start_time, _end_time);
                      setState(() {
                        _formErrors.remove('Start time not set');
                        if (_formErrors.length == 0){
                          _showFormError = false;
                        }
                      });
                    },
                        currentTime: DateTime.parse("1969-07-20 20:00:00Z"),
                        locale: LocaleType.en);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Start  ",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                size: 18.0,
                                color: Colors.teal,
                              ),
                              Text(
                                " $_start_time",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "  Change",
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
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showTimePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true, onConfirm: (time) {
                      print('confirm $time');
                      if (time.minute.toString() == "0" && time.hour.toString() == '0') {
                        _end_time = '${time.hour}0 : ${time.minute}0';
                      }
                      else if (time.minute.toString() == "0") {
                        _end_time = '${time.hour} : ${time.minute}0';
                      }
                      else if (time.hour.toString() == "0") {
                        _end_time = '${time.hour}0 : ${time.minute}';
                      }
                      else {
                        _end_time = '${time.hour} : ${time.minute}';
                      }
//                      validateTimeSlot(_start_time, _end_time);
                      setState(() {
                        _formErrors.remove('End time not set');
                        if (_formErrors.length == 0){
                          _showFormError = false;
                        }
                      });
                    },
                        currentTime: getEndTime(),
                        locale: LocaleType.en);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "End  ",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                size: 18.0,
                                color: Colors.teal,
                              ),
                              Text(
                                " $_end_time",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Number of watchmen',
                overflow: TextOverflow.clip,
                textAlign: TextAlign.left,
                style: new TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
              new DropdownButton<int>(
                items: <int>[1, 2, 3, 4].map((int value) {
                  return new DropdownMenuItem<int>(
                    value: value,
                    child: new Text(value.toString()),
                  );
                }).toList(),
                value: _number_users,
                hint: Text(_number_users.toString()),
                onChanged: (value) {
                  setState(() {
                    _number_users = value;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        showFormErrors(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            showCancelTimeslotButton(),
            showAddTimeslotButton(),
          ],
        ),
      ],
    );
  }

  DateTime getEndTime(){
    var hour = _start_time.split(':')[0];
    print(hour);
    if (hour == '23'){
      hour = '00';
    }
    else{
      hour = (int.parse(hour) + 1).toString();
      print(hour);
    }
    return DateTime.parse("1969-07-20 ${hour}:00:00Z");
  }

  Widget monday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['monday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['monday'] = value;
              });
            }),
        Text(
          'Monday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget tuesday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['tuesday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['tuesday'] = value;
              });
            }),
        Text(
          'Tuesday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget wednesday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['wednesday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['wednesday'] = value;
              });
            }),
        Text(
          'Wednesday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget thursday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['thursday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['thursday'] = value;
              });
            }),
        Text(
          'Thursday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget friday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['friday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['friday'] = value;
              });
            }),
        Text(
          'Friday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget saturday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['saturday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['satuday'] = value;
              });
            }),
        Text(
          'Saturday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget sunday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _daysOfWeek['sunday'],
            onChanged: (value) {
              setState(() {
                _daysOfWeek['sunday'] = value;
              });
            }),
        Text(
          'Sunday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
              color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ],
    );
  }

  Widget welcomeHeading() {
    return Center(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to NightWatch',
                  style: new TextStyle(
                    fontSize: 25.0,
                    color: new Color(0xFF212121),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Would you like to join an existing neighbourhood watch group or create a new one?',
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: new Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showJoinButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          elevation: 4.0,
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Join',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: joinExisting,
        ),
      ),
    );
  }

  Widget showCreateButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 4.0,
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text(
            'Create',
            style: new TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: showCreateForm,
        ),
      ),
    );
  }

  Widget showNextButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 4.0,
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text(
            'Next',
            style: new TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: nextFormStep,
        ),
      ),
    );
  }

  Widget showAddTimeslotButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 4.0,
          color: Colors.teal,
          child: new Text(
            'Add',
            style: new TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: addTimeSlot,
        ),
      ),
    );
  }

  Widget showCancelTimeslotButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.teal, width: 1, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Colors.white,
          child: new Text(
            'Cancel',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.teal,
            ),
          ),
          onPressed: cancelCreatTimeslot,
        ),
      ),
    );
  }

  Widget cancelCreatTimeslot() {
    setState(() {
      _showFormError = false;
      _formErrors = [];
      _showTimeslotForm = false;
      _start_time = "Not set";
      _end_time = "Not set";
      _number_users = 2;
    });
  }

  Widget showPreviousButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Color.fromRGBO(254, 109, 64, 1), width: 1, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Colors.white,
          child: new Text(
            'Previous',
            style: new TextStyle(
              fontSize: 20.0,
              color: Color.fromRGBO(254, 109, 64, 1),
            ),
          ),
          onPressed: previousFormStep,
        ),
      ),
    );
  }

  addTimeSlot() {
    if (validateTimeSlot(_start_time, _end_time)) {
      print('adding timeslot');
      Timeslot _timeslot = Timeslot(
          startTime: _start_time,
          endTime: _end_time,
          numberUsers: _number_users);

      _timeslots.add(_timeslot);

      setState(() {
        _showTimeslotForm = false;
        _start_time = "Not set";
        _end_time = "Not set";
        _number_users = 2;
      });
    }
  }

  validateTimeSlot(String startTime, String endTime){
    if (startTime != 'Not set' && endTime != 'Not set'){
      if (startTime != endTime){
        setState(() {
          _formErrors = [];
          _showFormError = false;
        });
        return true;
      }
      else{
        setState(() {
          _formErrors = [];
          _showFormError = true;
          _formErrors.add('Start time is the same as the end time');
          return false;
        });
      }
    }
    else{
      setState(() {
        _formErrors = [];
        _showFormError = true;
        if (startTime == 'Not set'){
          _formErrors.add('Start time not set');
        }
        if (endTime == 'Not set'){
          _formErrors.add('End time not set');
        }
        return false;
      });
    }
  }

  nextFormStep() {
    if (validateFormStep(_formPage)){
      setState(() {
        _formPage += 1;
//        validateFormStep(_formPage);
      });
    }
  }

  bool validateFormStep(int step) {
    _formErrors = [];
    switch (step) {
      case 1:
        {
          if (_name == null || _name == '') {
            // name error
            setState(() {
              _formErrors.add('Missing name field');
              _showFormError = true;
            });
          }
          if (_location_name == null || _location_name == '') {
            // location error
            setState(() {
              _formErrors.add('Missing location');
              _showFormError = true;
            });
          }
          if ((_location_name != null && _location_name != '') && (_name != null && _name != '')) {
            setState(() {
              _showFormError = false;
              _formErrors = [];
            });
          }
          return (_formErrors.length == 0);
        }
      case 2:
        {
          if (!_daysOfWeek['monday'] && !_daysOfWeek['tuesday'] && !_daysOfWeek['wednesday'] && !_daysOfWeek['thursday'] && !_daysOfWeek['friday'] && !_daysOfWeek['saturday'] && !_daysOfWeek['sunday']){
            setState(() {
              _showFormError = true;
              _formErrors.add('No days selected');
            });
          }
          else if (_daysOfWeek['monday'] && _daysOfWeek['tuesday'] && _daysOfWeek['wednesday'] && _daysOfWeek['thursday'] && _daysOfWeek['friday'] && _daysOfWeek['saturday'] && _daysOfWeek['sunday']){

            setState(() {
              _showFormError = false;
              _formErrors = [];
            });
          }
          return (_formErrors.length == 0);
        }
      case 3:
        {
          if (_timeslots.length == 0){
            setState(() {
              _showFormError = true;
              _formErrors.add('No timeslots added');
            });
          }
          else{
            setState(() {
              _showFormError = false;
              _formErrors = [];
            });
          }

          return (_formErrors.length == 0);
        }
    }
  }

  previousFormStep() {
    setState(() {
      _formPage -= 1;
      validateFormStep(_formPage);
    });
  }

  Widget showCancelFormButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Color.fromRGBO(254, 109, 64, 1),
                width: 1,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Colors.white,
          child: new Text(
            'Cancel',
            style: new TextStyle(
              fontSize: 20.0,
              color: Color.fromRGBO(254, 109, 64, 1),
            ),
          ),
          onPressed: cancelCreateForm,
        ),
      ),
    );
  }

  Widget showCreateFormButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text(
            'Create',
            style: new TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: showCreateForm,
        ),
      ),
    );
  }

  joinExisting() {
    print('join');
  }

  showCreateForm() {
    setState(() {
      _showCreateForm = true;
    });
  }

  cancelCreateForm() {
    setState(() {
      _showCreateForm = false;
      _showTimeslotForm = false;
      _start_time = "Not set";
      _end_time = "Not set";
      _number_users = 2;
      _timeslots = [];
      _formErrors = [];
      _showFormError = false;
      _name = '';
      _location_name = '';
      _location_longitude = null;
      _location_latitude = null;
      _daysOfWeek = {
        'monday': true,
        'tuesday': true,
        'wednesday': true,
        'thursday': true,
        'friday': true,
        'saturday': true,
        'sunday': true,
      };

    });
  }

  Widget showNameInput() {
    return Column(
      children: <Widget>[
        Text(
          'Give your Neightbourhood Watch Group a name so others can find it',
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: new TextFormField(
            maxLines: 1,
            autofocus: false,
            initialValue: _name,
            decoration: new InputDecoration(
//              focusedBorder: OutlineInputBorder(
//                borderSide: BorderSide(color: Colors.black, width: 2.0),
//              ),
//              enabledBorder: OutlineInputBorder(
//                borderSide: BorderSide(color: Colors.black, width: 2.0),
//              ),
              hintText: 'Name',
              icon: new Icon(
                Icons.security,
                color: Color.fromRGBO(254, 109, 64, 1),
              ),
            ),
            onChanged: (value) => formNameError(value),
            validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
            onSaved: (value) => _name = value.trim(),
          ),
        ),
      ],
    );
  }

  formNameError(String name){
    setState(() {
      _name = name;
    });
    if (name != null && name != ''){
      setState(() {
        _formErrors.remove('Missing name field');
        if (_formErrors.length == 0){
          _showFormError = false;
        }
      });
    }
    else{
      setState(() {
        _formErrors.add('Missing name field');
        _showFormError = true;
      });
    }

  }

  Widget showLocationInput() {
    if (_location_name == null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: Text(
              'In what area is your neighbourhood watch?',
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: RaisedButton(
                onPressed: () async {
                  Prediction p = await PlacesAutocomplete.show(
                      context: context, apiKey: kGoogleApiKey);
                  displayPrediction(p);
                },
                child: Text('Find address'),
              )),
        ],
      );
    } else if (_location_name != null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: Text(
              'In what area is your neighbourhood watch?',
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                child: Text(
                  _location_name,
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: RaisedButton(
                    onPressed: () async {
                      Prediction p = await PlacesAutocomplete.show(
                          context: context, apiKey: kGoogleApiKey);
                      displayPrediction(p);
                    },
                    child: Text('Change address'),
                  )),
            ],
          ),
        ],
      );
    }
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

//      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      setState(() {
        _formErrors.remove('Missing location');
        if (_formErrors.length == 0){
          _showFormError = false;
        }
        _location_latitude = lat;
        _location_longitude = lng;
        _location_name = p.description;
      });

      print(_location_latitude);
      print(_location_longitude);
      print(_location_name);
    }
  }

  showPrivateSwitch() {
    if (_isPrivate == null) {
      return Container(height: 0.0, width: 0.0);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: Column(
        children: <Widget>[
          Text(
            'Making your group private will prevent others from being able to find it',
            style: new TextStyle(
              fontSize: 18.0,
//            color: Colors.black,
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                'Private',
                style: new TextStyle(
                  fontSize: 18.0,
//            color: Colors.black,
                ),
              ),
              Switch(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

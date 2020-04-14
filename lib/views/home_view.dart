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

  bool _monday = true;
  bool _tuesday = true;
  bool _wednesday = true;
  bool _thursday = true;
  bool _friday = true;
  bool _saturday = true;
  bool _sunday = true;

  String _start_time = "Not set";
  String _end_time = "Not set";

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
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Slot Start Time',
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontSize: 15.0,
                        color: new Color(0xFF212121),
                      ),
                    ),
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
                        _start_time = '${time.hour} : ${time.minute}';
                        setState(() {});
                      },
                          currentTime: DateTime.parse("1969-07-20 20:30:00Z"),
                          locale: LocaleType.en);
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
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
                              )
                            ],
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Slot End Time',
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                        fontSize: 15.0,
                        color: new Color(0xFF212121),
                      ),
                    ),
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
                        _end_time = '${time.hour} : ${time.minute}';
                        setState(() {});
                      },
                          currentTime: DateTime.parse("1969-07-20 20:30:00Z"),
                          locale: LocaleType.en);
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
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
                              )
                            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              showPreviousButton(),
              showNextButton(),
            ],
          ),
        ],
      );
    } else {
      return Container(
        height: 0,
        width: 0,
      );
    }
  }

  Widget monday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _monday,
            onChanged: (value) {
              setState(() {
                _monday = value;
              });
            }),
        Text(
          'Monday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget tuesday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _tuesday,
            onChanged: (value) {
              setState(() {
                _tuesday = value;
              });
            }),
        Text(
          'Tuesday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget wednesday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _wednesday,
            onChanged: (value) {
              setState(() {
                _wednesday = value;
              });
            }),
        Text(
          'Wednesday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget thursday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _thursday,
            onChanged: (value) {
              setState(() {
                _thursday = value;
              });
            }),
        Text(
          'Thursday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget friday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _friday,
            onChanged: (value) {
              setState(() {
                _friday = value;
              });
            }),
        Text(
          'Friday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget saturday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _saturday,
            onChanged: (value) {
              setState(() {
                _saturday = value;
              });
            }),
        Text(
          'Saturday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget sunday() {
    return Row(
      children: <Widget>[
        Checkbox(
            value: _sunday,
            onChanged: (value) {
              setState(() {
                _sunday = value;
              });
            }),
        Text(
          'Sunday',
          overflow: TextOverflow.clip,
          textAlign: TextAlign.left,
          style: new TextStyle(
            fontSize: 15.0,
            color: new Color(0xFF212121),
          ),
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
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
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
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Create',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
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
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Next',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: nextFormStep,
        ),
      ),
    );
  }

  Widget showPreviousButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Previous',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: previousFormStep,
        ),
      ),
    );
  }

  nextFormStep() {
    setState(() {
      _formPage += 1;
    });
  }

  previousFormStep() {
    setState(() {
      _formPage -= 1;
    });
  }

  Widget showCancelFormButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Color.fromRGBO(254, 109, 64, 1),
                width: 1,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.white,
          child: new Text('Cancel',
              style: new TextStyle(
                  fontSize: 20.0, color: Color.fromRGBO(254, 109, 64, 1))),
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
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color.fromRGBO(254, 109, 64, 1),
          child: new Text('Create',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
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
            validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
            onSaved: (value) => _name = value.trim(),
          ),
        ),
      ],
    );
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
                    fontSize: 15.0,
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

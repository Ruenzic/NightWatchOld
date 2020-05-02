import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:i_am_rich/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_am_rich/models/watchgroup.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:i_am_rich/services/watchgroup_service.dart';

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MapState();
  }
}

class _MapState extends State<MapView> {
  //  @override

//  Completer<GoogleMapController> _controller = Completer();

  static LatLng _center;

  final Set<Marker> _markers = {};

  LatLng _lastMapPosition = _center;

  MapType _currentMapType = MapType.normal;

  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final firebaseUser = Provider.of<FirebaseUser>(context);
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
        _center = LatLng(watchGroup.latitude, watchGroup.longitude);
        BorderRadiusGeometry radius = BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        );
        return SlidingUpPanel(
          color: Colors.transparent,
          boxShadow: [
            new BoxShadow(
              color: Colors.transparent,
              blurRadius: 10.0,
            ),
          ],
          panel: _floatingPanel(),
          collapsed: _floatingCollapsed(),
          body: Center(
            child: Stack(
              children: <Widget>[
                GoogleMap(
//              onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton(
                      onPressed: () => print('button pressed'),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.pin_drop, size: 36.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Widget _floatingCollapsed() {
    return Container(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              actionButton(),
              Text(
                "Swipe up for more details",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingPanel() {
    User user = Provider.of<User>(context);
    final firebaseUser = Provider.of<FirebaseUser>(context, listen: false);
    WatchGroup watchGroup = Provider.of<WatchGroup>(context);
//    List<Timeslot> activeTimeslots =
//        getActiveTimeslots(timeslots: watchGroup.timeslots);

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

          List<Timeslot> activeTimeslots =
              getActiveTimeslots(timeslots: timeslots);

          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20.0,
                    color: Colors.grey,
                  ),
                ]),
            margin: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Current Timeslots',
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  children: new List.generate(
                    activeTimeslots.length,
                    (i) => Column(
                      children: <Widget>[
                        Text(activeTimeslots[i].startTime +
                            ' - ' +
                            activeTimeslots[i].endTime,
                          style: new TextStyle(
                            fontSize: 17.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),),
                        Column(
                          children: new List.generate(
                            activeTimeslots[i].signups[getCurrentDate()].length,
                            (j) => Column(children: <Widget>[
                              userNameFromID(
                                  userId: activeTimeslots[i]
                                      .signups[getCurrentDate()][j]),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
//                Center(
//                  child: Text(
//                      "show current timeslot bracket - and who should be on watch and if they are currently on watch or not, later show call button to call each user on watch"),
//                ),
              ],
            ),
          );
        });
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

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

//  void _onMapCreated(GoogleMapController controller) {
//    _controller.complete(controller);
//  }

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

  getCurrentTime() {
    var now = new DateTime.now();
//    return now.hour.toString() + ':' + now.minute.toString();
    return '20:30';
  }

  getCurrentDate() {
    var now = new DateTime.now();
    return now.toString().split(' ')[0];
  }

  List<Timeslot> getActiveTimeslots({List timeslots}) {
    var currentTimeHour = int.parse(getCurrentTime().split(':')[0]);
    var currentTimeMinute = int.parse(getCurrentTime().split(':')[1]);
    List<Timeslot> currentTimeslots = [];
    timeslots.forEach((timeslot) => {
//          if (currentTimeHour > int.parse(timeslot.startTime.split(' : ')[0]) &&
//              currentTimeHour < int.parse(timeslot.endTime.split(' : ')[0]) &&
//              currentTimeMinute >
//                  int.parse(timeslot.startTime.split(' : ')[1]) &&
//              currentTimeMinute < int.parse(timeslot.endTime.split(' : ')[1]))
          if (DateTime.parse(
                      '1974-03-20 ${currentTimeHour}:${currentTimeMinute}:00.000')
                  .isAfter(DateTime.parse(
                      '1974-03-20 ${timeslot.startTime.split(' : ')[0]}:${timeslot.startTime.split(' : ')[1]}:00.000')) &&
              DateTime.parse(
                      '1974-03-20 ${currentTimeHour}:${currentTimeMinute}:00.000')
                  .isBefore(DateTime.parse(
                      '1974-03-20 ${timeslot.endTime.split(' : ')[0]}:${timeslot.endTime.split(' : ')[1]}:00.000')))
            {currentTimeslots.add(timeslot)}
        });
    return currentTimeslots;
  }

  Widget userNameFromID({userId: String}) {
    UserService userService = new UserService(userId: userId);

    return FutureBuilder<User>(
        future: userService.userFromData(), //returns bool
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // YOUR CUSTOM CODE GOES HERE
            if (snapshot.data.onWatch != null &&
                snapshot.data.onWatch == true) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(snapshot.data.userName,
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),),
                  Text(
                    'Online',
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(snapshot.data.userName,
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),),
                  Text(
                    'Offline',
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              );
            }
          } else {
            return new CircularProgressIndicator();
          }
        });
  }

  // Call start watch on the userservice and the watchgroup service
  startWatch() {
    final user = Provider.of<FirebaseUser>(context, listen: false);
    UserService userService = new UserService(userId: user.uid);
    WatchGroupService watchGroupService =
        new WatchGroupService(userId: user.uid, watchGroupId: user.displayName);

    setState(() {
      userService.startWatch();
      watchGroupService.startWatch();
    });

  }

  // Call stop watch on the userservice and the watchgroup service
  stopWatch() {
    final user = Provider.of<FirebaseUser>(context, listen: false);
    UserService userService = new UserService(userId: user.uid);
    WatchGroupService watchGroupService =
        new WatchGroupService(userId: user.uid, watchGroupId: user.displayName);

    setState(() {
      userService.stopWatch();
      watchGroupService.stopWatch();
    });

  }

  Widget showStartWatchButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//      child: SizedBox(
//        height: 40.0,
        child: new RaisedButton(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.teal, width: 1, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Colors.white,
          child: new Text(
            'Start Watch',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.teal,
            ),
          ),
          onPressed: startWatch,
        ),
//      ),
    );
  }

  Widget showStopWatchButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//      child: SizedBox(
//        height: 40.0,
      child: new RaisedButton(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.redAccent, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Colors.white,
        child: new Text(
          'Stop Watch',
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.redAccent,
          ),
        ),
        onPressed: stopWatch,
      ),
//      ),
    );
  }

  Widget actionButton(){
    final user = Provider.of<User>(context);
    if (user.onWatch == null || !user.onWatch){
      return showStartWatchButton();
    }
    else{
      return showStopWatchButton();
    }
  }
}

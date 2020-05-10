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
import 'package:location/location.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';


class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MapState();
  }
}

class _MapState extends State<MapView> {
  //  @override


  GoogleMapController _controller;

  // the user's initial location and current location
  // as it moves
  LocationData currentLocation;

  // wrapper around the location API
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  StreamSubscription _locationSubscription;

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
              onMapCreated: (GoogleMapController controller){
                _controller = controller;
              },
                  markers: Set.of((marker != null) ? [marker] : []),
//                  circles: Set.of((circle != null) ? [circle] : []),
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
                      onPressed: () => trackUser(),
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

  void trackUser() async {
    try {

      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      print(location.toString());

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }


      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
          //  [TODO]
          // When we update the current users location here, we need to save write this to firebase
          // Probably just updating a variable, (or possibly in future, storing all the locations so later can generate a watch route)
          // Once we have 1 user writing and sending, can work on another user being able to just listen to firebase and draw markers
          // Need to look into user having full control of map, with a center button appearing if they move it like google maps does
          // store under users_on_watch[]
          // change string to a key and store {id: firebase_id, name: user_name, location: {latitude: 0, longitude: 0, heading: 0, accuracy: 0}}
          // When we do startWatch() we need to first get user current location then create the entry in watchgroup
          // So we can pass the other params with it
          // Then just update it on onLocationChanged

          print(newLocalData);
          final user = Provider.of<FirebaseUser>(context, listen: false);
          UserService userService = new UserService(userId: user.uid);
          WatchGroupService watchGroupService =
          new WatchGroupService(userId: user.uid, watchGroupId: user.displayName);
          watchGroupService.updateUserPosition(newLocalData.latitude, newLocalData.longitude, newLocalData.heading, newLocalData.accuracy);

        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

//  @override
//  void initState() {
//    super.initState();
//
//    // create an instance of Location
//    location = new Location();
//
//    // subscribe to changes in the user's location
//    // by "listening" to the location's onLocationChanged event
//    location.onLocationChanged.listen((LocationData cLoc) {
//      // cLoc contains the lat and long of the
//      // current user's position in real time,
//      // so we're holding on to it
//      currentLocation = cLoc;
////      updatePinOnMap();
//    });
//    // set the initial location
//    setInitialLocation();
//  }
//
//  void setInitialLocation() async {
//    // set the initial location by pulling the user's
//    // current location from the location's getLocation()
//    currentLocation = await location.getLocation();
//
//  }

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
                Text('Swipe down to close'),
                Text(
                  'Current Timeslots',
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                showActiveTimeslots(activeTimeslots: activeTimeslots),
//                Center(
//                  child: Text(
//                      "show current timeslot bracket - and who should be on watch and if they are currently on watch or not, later show call button to call each user on watch"),
//                ),
              ],
            ),
          );
        });
  }

  Widget showActiveTimeslots({activeTimeslots: List}) {
    if (activeTimeslots != null && activeTimeslots.length > 0) {
      return Column(
        children: new List.generate(
          activeTimeslots.length,
          (i) => Column(
            children: <Widget>[
              Text(
                activeTimeslots[i].startTime +
                    ' - ' +
                    activeTimeslots[i].endTime,
                style: new TextStyle(
                  fontSize: 17.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              showSignedUpUsers(timeslot: activeTimeslots[i]),
            ],
          ),
        ),
      );
    } else {
      return Text(
        'No active timeslots',
        style: new TextStyle(
          fontSize: 17.0,
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  Widget showSignedUpUsers({timeslot: Timeslot}) {
    if (timeslot.signups != null &&
        timeslot.signups[getCurrentDate()] != null &&
        timeslot.signups[getCurrentDate()].length > 0) {
      return Column(
        children: new List.generate(
          timeslot.signups[getCurrentDate()].length,
          (j) => Column(children: <Widget>[
            userNameFromID(userId: timeslot.signups[getCurrentDate()][j]),
          ]),
        ),
      );
    } else {
      return Text(
        'No users signed up',
        style: new TextStyle(
          fontSize: 17.0,
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }
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
                  Text(
                    snapshot.data.userName,
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  Text(
                    snapshot.data.userName,
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
  startWatch() async {
    final user = Provider.of<FirebaseUser>(context, listen: false);
    UserService userService = new UserService(userId: user.uid);
    WatchGroupService watchGroupService =
    new WatchGroupService(userId: user.uid, watchGroupId: user.displayName);

    var location = await _locationTracker.getLocation();
//    print(location.latitude.toString() + ' '  + location.longitude.toString() + ' ' + location.heading.toString() + ' ' + location.accuracy.toString());

    if (location.latitude != null && location.longitude != null){
      setState(() {
        userService.startWatch();
        watchGroupService.startWatch(location.latitude, location.longitude, location.heading, location.accuracy);
      });
      trackUser();
    }
    else{
      //[TODO] show error message to user saying cant get location
    }

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
      marker = null;
      circle = null;
    });
    _locationSubscription.cancel();

  }

  Widget showStartWatchButton() {
    //[TODO] Dont show start watch button if user isnt signed up for watch session
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

  Widget actionButton() {
    final user = Provider.of<User>(context);
    if (user.onWatch == null || !user.onWatch) {
      return showStartWatchButton();
    } else {
      return showStopWatchButton();
    }
  }
}

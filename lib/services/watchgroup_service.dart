import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:i_am_rich/models/watchgroup.dart';

class WatchGroupService{
  WatchGroupService({ this.userId, this.watchGroupId });

  // collection reference
  final CollectionReference watchGroupCollection = Firestore.instance.collection('watchGroups');

  final String userId;
  final String watchGroupId;

  Future createWatchGroup(String name, List<Timeslot> timeslots, String location, double latitude, double longitude, var daysOfWeek) async {
    DocumentReference docRef = await watchGroupCollection.add({
      'name': name,
      'admin': userId,
      'isPrivate': true,
      'timeslots': timeslots.map((e) => e.toJson()).toList(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'daysOfWeek': daysOfWeek
    });
    // Add the timeslots
    timeslots.forEach((element) => {
      watchGroupCollection.document(docRef.documentID).collection('timeslots').add({
        'startTime': element.startTime,
        'endTime': element.endTime,
        'numberUsers': element.numberUsers
      })
    });

    UserService(userId: userId).updateUserWatchGroup(docRef.documentID);
    return docRef.documentID;
  }

  WatchGroup _watchGroupFromFirestore(DocumentSnapshot watchGroup){
    print(watchGroup['timeslots']);
    return watchGroup != null ? WatchGroup(name: watchGroup['name'], users: watchGroup['users'], adminId: watchGroup['admin'], isPrivate: watchGroup['isPrivate'], location: watchGroup['location'], timeslots: List<Timeslot>.from((watchGroup['timeslots'].map((e) => Timeslot(startTime: e['startTime'], endTime: e['endTime'], numberUsers: e['numberUsers'], id: '', signups: e['signups']))).toList()), daysOfWeek: new Map<String, bool>.from(watchGroup['daysOfWeek']), latitude: watchGroup['latitude'], longitude: watchGroup['longitude']): null;
  }

  // get watchgroup stream
  Stream<WatchGroup> get watchGroup {
    return watchGroupCollection.document(watchGroupId).snapshots().map((DocumentSnapshot watchGroup) => _watchGroupFromFirestore(watchGroup));
  }


  // add user id to array in the watchgroup
  startWatch(double latitude, double longitude, double heading, double accuracy) async{
    UserService userService = new UserService(userId: userId);
    String userName;
    await userService.userFromData().then((value) => print(
      userName = value.userName
    ));

    await watchGroupCollection.document(watchGroupId).updateData({
      'users_on_watch': FieldValue.arrayUnion([
        {'id': userId, 'name': userName, 'location': {'latitude': latitude, 'longitude': longitude, 'heading': heading, 'accuracy': accuracy}}
      ])
    });
  }

  // remove user id from array in the watchgroup
  stopWatch() async{
//    await watchGroupCollection.document(watchGroupId).updateData({
//      'users_on_watch': FieldValue.arrayRemove([userId])
//    });

    Firestore.instance.runTransaction((transaction) =>
      transaction.get(watchGroupCollection.document(watchGroupId)).then((value) => {
        transaction.update(watchGroupCollection.document((watchGroupId)), removeUserOnWatch(value.data))
      })
    );
  }

  updateUserPosition(double latitude, double longitude, double heading, double accuracy) async{
    Firestore.instance.runTransaction((transaction) =>
        transaction.get(watchGroupCollection.document(watchGroupId)).then((value) => {
          transaction.update(watchGroupCollection.document((watchGroupId)), changePosition(value.data, latitude, longitude, heading, accuracy))
        })
    );
  }

  Map changePosition(watchGroup, double latitude, double longitude, double heading, double accuracy){
    watchGroup['users_on_watch'].forEach((element) {
      if (element['id'] == userId){
        element['location']['latitude'] = latitude;
        element['location']['longitude'] = longitude;
        element['location']['heading'] = heading;
        element['location']['accuracy'] = accuracy;
      }
    });
    return watchGroup;
  }

  Map removeUserOnWatch(value){
    List<Map> users_on_watch_new = List();
    List users_on_watch = value['users_on_watch'];

    users_on_watch.forEach((element) {
      users_on_watch_new.add(element);
    });

    var toRemove = [];

    users_on_watch_new.forEach((element) {
      if (element['id'] == userId){
        toRemove.add(element);
      }
    });
    users_on_watch_new.removeWhere( (e) => toRemove.contains(e));

    value['users_on_watch'] = users_on_watch_new;
    return value;
  }




}












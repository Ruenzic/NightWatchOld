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
    return watchGroup != null ? WatchGroup(name: watchGroup['name'], users: watchGroup['users'], adminId: watchGroup['admin'], isPrivate: watchGroup['isPrivate'], location: watchGroup['location'], timeslots: List<Timeslot>.from((watchGroup['timeslots'].map((e) => Timeslot(startTime: e['startTime'], endTime: e['endTime'], numberUsers: e['numberUsers']))).toList()), daysOfWeek: new Map<String, bool>.from(watchGroup['daysOfWeek']), latitude: watchGroup['latitude'], longitude: watchGroup['longitude']): null;
  }

  // get user stream
  Stream<WatchGroup> get watchGroup {
    return watchGroupCollection.document(watchGroupId).snapshots().map((DocumentSnapshot watchGroup) => _watchGroupFromFirestore(watchGroup));
  }




}












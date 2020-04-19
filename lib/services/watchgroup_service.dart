import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:i_am_rich/services/user_service.dart';

class WatchGroupService{
  WatchGroupService({ this.userId });

  // collection reference
  final CollectionReference watchGroupCollection = Firestore.instance.collection('watchGroups');

  final String userId;

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
//    docRef.updateData({'timeslots': timeslots});
    UserService(userId: userId).updateUserWatchGroup(docRef.documentID);
    return docRef.documentID;
  }




}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/models/timeslot.dart';
import 'package:i_am_rich/services/user_service.dart';
import 'package:i_am_rich/models/watchgroup.dart';

class ScheduleService{
  ScheduleService({ this.userId, this.watchGroupId });

  final CollectionReference watchGroupCollection = Firestore.instance.collection('watchGroups');


  final String userId;
  final String watchGroupId;


  Timeslot _timeSlotFromFirestore(DocumentSnapshot timeSlot){
    return timeSlot != null ? Timeslot(startTime: timeSlot['startTime'], endTime: timeSlot['endTime'], numberUsers: timeSlot['numberUsers'], id: timeSlot.documentID): null;
  }

  // get timeslots stream
  Stream<List<Timeslot>> get timeSlots {
    return (watchGroupCollection.document(watchGroupId).collection('timeslots').snapshots().map((QuerySnapshot qSnap) => qSnap.documents.map((DocumentSnapshot doc) => _timeSlotFromFirestore(doc)).toList()).first.asStream());
  }

  // Sign up to a timeslot
  Future createSignup({date: String, timeSlotId: String}) async {
//    await watchGroupCollection.document(watchGroupId).collection('signups').document(date).updateData({
//      timeSlotId: FieldValue.arrayUnion([userId])
//    });

    await watchGroupCollection.document(watchGroupId).collection('timeslots').document(timeSlotId).updateData({
      'signups.${date}': FieldValue.arrayUnion([userId])
    });
  }

  // Remove a timeslot signup
  Future removeSignup({date: String, timeSlotId: String}) async {

    await watchGroupCollection.document(watchGroupId).collection('timeslots').document(timeSlotId).updateData({
      'signups.${date}': FieldValue.arrayRemove([userId])
    });
  }


  currentDate(){
    print(DateTime.now().toString().split(' ')[0]);
  }

}












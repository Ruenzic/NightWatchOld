import 'package:cloud_firestore/cloud_firestore.dart';

class WatchGroupService{
  WatchGroupService({ this.userId });

  // collection reference
  final CollectionReference watchGroupCollection = Firestore.instance.collection('watchGroups');

  final String userId;

  Future updateWatchGroup(String name, List<String> users, bool isPrivate) async {
    return await watchGroupCollection.add({
      'name': name,
      'admin': userId,
      'users': users,
      'isPrivate': isPrivate
    });
  }




}
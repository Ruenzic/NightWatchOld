import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/models/user.dart';

class UserService{
  UserService({ this.userId });

  // collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');

  final String userId;

  Future updateUserName(String name) async {
    return await userCollection.document(userId).setData({
      'name': name
    });
  }

  Future updateUserWatchGroup(String id) async {
    return await userCollection.document(userId).setData({
      'watchGroup': id
    });
  }

  // get user stream
  Stream<DocumentSnapshot> get user {
    return userCollection.document(userId).snapshots();
  }

  Future getData() async {
    return await userCollection.document(userId).get();
  }

  Future<User> userFromData() async {
    DocumentSnapshot userRef = await userCollection.document(userId).get();
    User userInfo = new User(
        userId: userRef.data["userId"],
        userName: userRef.data["userName"],
        watchGroupId: userRef.data["watchGroupId"]
    );

    return userInfo;


    return await userCollection.document(userId).get().then((DocumentSnapshot snapshot) {
      return new User(
          userId: snapshot.data["userId"],
          userName: snapshot.data["userName"],
          watchGroupId: snapshot.data["watchGroupId"]
      );
    });
  }

}
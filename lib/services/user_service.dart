import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_am_rich/models/user.dart';

class UserService{
  UserService({ this.userId });

  // collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');

  final String userId;

  Future updateUserName(String name) async {
    return await userCollection.document(userId).updateData({
      'name': name
    });
  }

  Future updateUserWatchGroup(String id) async {
    return await userCollection.document(userId).updateData({
      'watchGroupId': id
    });
  }

  User _userFromFirestore(DocumentSnapshot user){
    return user != null ? User(userName: user["name"], watchGroupId: user["watchGroupId"]): null;
  }

  // get user stream
  Stream<User> get user {
    return userCollection.document(userId).snapshots().map((DocumentSnapshot user) => _userFromFirestore(user));
  }

  Future getData() async {
    return await userCollection.document(userId).get();
  }

  Future<User> userFromData() async {
    DocumentSnapshot userRef = await userCollection.document(userId).get();
    User userInfo = new User(
        userName: userRef.data["userName"],
        watchGroupId: userRef.data["watchGroupId"]
    );

    return userInfo;


    return await userCollection.document(userId).get().then((DocumentSnapshot snapshot) {
      return new User(
          userName: snapshot.data["userName"],
          watchGroupId: snapshot.data["watchGroupId"]
      );
    });
  }

}
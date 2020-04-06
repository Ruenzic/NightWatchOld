import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_am_rich/models/user.dart';
import 'user_service.dart';

abstract class BaseAuth {
  Future<FirebaseUser> signIn(String email, String password);

  Future<FirebaseUser> signUp(String email, String password, String name);

  Future<FirebaseUser> getCurrentUser();
  
  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class AuthService implements BaseAuth {

  // Create User object based on FirebaseUser
//  User _userFromFirebaseUser(FirebaseUser user){
//    return user != null ? User(userId: user.uid, userName: user.displayName): null;
//  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
//    print(user);
    return user;
  }

  Future<FirebaseUser> signUp(String email, String password, String name) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    // Create user object on firestore
    await UserService(userId: user.uid).updateUserName(name);
    // Update displayName with user name on firebath auth user object
    await user.updateProfile(UserUpdateInfo()..displayName = name);
    return user;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

}
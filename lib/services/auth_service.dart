import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_am_rich/models/user.dart';

abstract class BaseAuth {
  Future<User> signIn(String email, String password);

  Future<User> signUp(String email, String password, String name);

  Future<User> getCurrentUser();

  Future<FirebaseUser> getFirebaseUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class AuthService implements BaseAuth {

  // Create User object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user){
    return user != null ? User(userId: user.uid, userName: user.displayName): null;
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    print(user);
    return _userFromFirebaseUser(user);
  }

  Future<User> signUp(String email, String password, String name) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    await user.updateProfile(UserUpdateInfo()..displayName = name);
    return _userFromFirebaseUser(user);
  }

  Future<User> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return _userFromFirebaseUser(user);
  }

  Future<FirebaseUser> getFirebaseUser() async {
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
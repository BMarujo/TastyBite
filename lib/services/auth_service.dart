import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/util/logout.dart';

class AuthServices {
  final FirebaseAuth user;
  final FirebaseFirestore _database;

  AuthServices(this._database, this.user);

  User? getCurrentuser() {
    return user.currentUser;
  }

  Future<UserCredential> signIn(String email, password) async {
    try {
      final UserCredential userCredential = await user
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  Future<void> signOut(context, LogoutHelper x) async {
    await user.signOut();
    x.deposit();
  }

  Future<UserCredential> signUp(String email, password, nickname, type) async {
    try {
      final UserCredential userCredential = await user
          .createUserWithEmailAndPassword(email: email, password: password);
      _database
          .collection("Users")
          .doc(
            userCredential.user!.uid,
          )
          .set(
        {
          "uid": userCredential.user!.uid,
          "email": email,
          "name": nickname,
          "type": type,
          "available": true,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }
}

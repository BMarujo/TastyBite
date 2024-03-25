import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tastybite/login.dart';

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

  Future<void> signOut(context) async {
    await user.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<UserCredential> signUp(String email, password, nickname) async {
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
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }
}

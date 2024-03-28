import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/locator/service_locator.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = locator.get();
final FirebaseFirestore _firestore = locator.get();

class Wallet extends ChangeNotifier {
  double _balance = 0;
  double get balance => _balance;

  int points = 0;

  int get getPoints => points;
  Future<void> deposit(double amount) async {
    _balance += amount;
    await _firestore
        .collection('Users')
        .doc(_auth.currentUser!.uid)
        .set({'balance': _balance}, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> getBalanceFromFirebase() async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      final data = snapshot.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('balance')) {
        throw Exception('Balance data not available');
      }

      _balance = data['balance'];
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error retrieving balance: $e');
    }
  }

  Future<void> withdraw(double amount) async {
    _balance -= amount;
    await _firestore
        .collection('Users')
        .doc(_auth.currentUser!.uid)
        .set({'balance': _balance}, SetOptions(merge: true));
    notifyListeners();
  }

  void addPoint() {
    points += 1;
    notifyListeners();
  }

  void removePoints() {
    points = 0;
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tastybite/services/locator_service.dart';

final FirebaseAuth _auth = locator.get();
final FirebaseFirestore _firestore = locator.get();

class MyUser {
  final String? name;

  MyUser({this.name});

  String? get getname => name;

  Future<List<String>> getHistory() async {
    try {
      final DocumentSnapshot snapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      final data = snapshot.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('history')) {
        throw Exception('History data not available');
      }

      return List<String>.from(data['history']);
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error retrieving history: $e');
      return [];
    }
  }

  Future<List<String>> getDate() async {
    try {
      final DocumentSnapshot snapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      final data = snapshot.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('date')) {
        throw Exception('Date data not available');
      }

      return List<String>.from(data['date']);
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error retrieving date: $e');
      return [];
    }
  }

  Future<void> addHistory(String item) async {
    try {
      await _firestore.collection('Users').doc(_auth.currentUser!.uid).update({
        'history': FieldValue.arrayUnion([item])
      });
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error adding history: $e');
    }
  }

  Future<void> removeHistory(String item) async {
    try {
      await _firestore.collection('Users').doc(_auth.currentUser!.uid).update({
        'history': FieldValue.arrayRemove([item])
      });
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error removing history: $e');
    }
  }

  Future<void> addDate(String item) async {
    try {
      await _firestore.collection('Users').doc(_auth.currentUser!.uid).update({
        'date': FieldValue.arrayUnion([item])
      });
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error adding date: $e');
    }
  }

  Future<void> removeDate(String item) async {
    try {
      await _firestore.collection('Users').doc(_auth.currentUser!.uid).update({
        'date': FieldValue.arrayRemove([item])
      });
    } catch (e) {
      // Handle errors, e.g., logging or notifying the user
      print('Error removing date: $e');
    }
  }
}

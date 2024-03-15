import 'package:flutter/material.dart';

class Wallet extends ChangeNotifier {
  double _balance = 0;

  double get balance => _balance;

  int points = 0;

  int get getPoints => points;

  void deposit(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void withdraw(double amount) {
    _balance -= amount;
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

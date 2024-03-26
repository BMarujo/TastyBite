import 'package:flutter/material.dart';

class LogoutHelper extends ChangeNotifier {
  //the purpose of this is to warn the screen_builder that the user has logged out and to return to the login screen

  double _balance = 0;

  double get balance => _balance;

  void deposit() {
    _balance = 1;
    notifyListeners();
  }
}

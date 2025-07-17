import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _selectedUserName = '';

  String get userName => _userName;
  String get selectedUserName => _selectedUserName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners(); // Notify listeners that the data has changed
  }

  void setSelectedUserName(String name) {
    _selectedUserName = name;
    notifyListeners(); // Notify listeners that the data has changed
  }
}
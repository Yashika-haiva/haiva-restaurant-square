import 'package:flutter/material.dart';

class AgentDataProvider with ChangeNotifier {
  String _imageUrl = "";
  String _displayName = "";
  String _description = "";

  String _formattedBalance = "0.00";

  String get formattedBalance => _formattedBalance;

  String get imageUrl => _imageUrl;

  String get displayName => _displayName;

  String get description => _description;

  void updateBalance(String newBalance) {
    _formattedBalance = newBalance;
    notifyListeners(); // Notifies all listeners about the state change
  }

  void updateImageUrl(String newImageUrl) {
    _imageUrl = newImageUrl;
    notifyListeners(); // Notifies all listeners about the state change
  }

  void updateName(String newName) {
    _displayName = newName;
    notifyListeners(); // Notifies all listeners about the state change
  }

  void updateDescription(String newDescription) {
    _description = newDescription;
    notifyListeners(); // Notifies all listeners about the state change
  }
}

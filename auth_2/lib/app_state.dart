import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  bool _showActivated = false;
  bool get showActivated => _showActivated;
  set showActivated(bool value) {
    _showActivated = value;
  }

  int _localVictoryCount = 0;
  int get localVictoryCount => _localVictoryCount;
  set localVictoryCount(int value) {
    _localVictoryCount = value;
  }
}

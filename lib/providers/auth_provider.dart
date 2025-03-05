import 'package:flutter/material.dart';
import '../services/student_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await StudentService.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      await StudentService.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await StudentService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}

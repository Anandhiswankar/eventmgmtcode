import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userData = prefs.getString('user');

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      _error = 'Failed to initialize authentication';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var bodyData = jsonEncode({'email': email.trim(), 'password': password});

      final response = await http.post(
        Uri.parse("$baseUrl/api/login/"),
        headers: {'Content-Type': 'application/json'},
        body: bodyData,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data != null && data["status"]) {
          var userData = data["userdata"];
          String token = data["token"];

          _user = User.fromJson(userData);
          _token = token;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user', jsonEncode(_user!.toJson()));
          await prefs.setString('uid', _user!.id);
          await prefs.setString('email', _user!.email);
          await prefs.setString('name', _user!.name);
          await prefs.setString('role', _user!.role);

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Invalid credentials';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Login failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token != null) {
        final response = await http.post(
          Uri.parse("$baseUrl/api/logout"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data["status"]) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
          }
        }
      }

      _user = null;
      _token = null;
      _error = null;
    } catch (e) {
      _user = null;
      _token = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

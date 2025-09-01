import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/event.dart';
import '../models/pagination_response.dart';
import '../providers/auth_provider.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  bool _isLoadingMore = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasNextPage => _hasNextPage;
  bool get hasPrevPage => _hasPrevPage;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> initializeEvents(AuthProvider authProvider) async {
    await checkPermission(authProvider);
    await fetchEvents(authProvider);
  }

  Future<void> checkPermission(AuthProvider authProvider) async {
    _isAdmin = authProvider.user?.role == "admin";
    notifyListeners();
  }

  Future<void> fetchEvents(AuthProvider authProvider, {int page = 1}) async {
    if (page == 1) {
      _isLoading = true;
      _events = [];
    } else {
      _isLoadingMore = true;
    }
    _error = null;

    await checkPermission(authProvider);

    notifyListeners();

    try {
      String? token = authProvider.token;

      if (token == null) {
        _error = "Please login first";
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/events?page=$page"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        print("Full response: $data");
        print("Response type: ${data.runtimeType}");

        try {
          if (data.containsKey("current_page")) {
            PaginationResponse paginationResponse = PaginationResponse.fromJson(
              data,
            );

            if (page == 1) {
              _events = paginationResponse.data;
            } else {
              _events.addAll(paginationResponse.data);
            }

            _currentPage = paginationResponse.currentPage;
            _lastPage = paginationResponse.lastPage;
            _total = paginationResponse.total;
            _hasNextPage = paginationResponse.nextPageUrl != null;
            _hasPrevPage = paginationResponse.prevPageUrl != null;
          } else if (data.containsKey("status") &&
              data["status"] == true &&
              data["data"] != null) {
            PaginationResponse paginationResponse = PaginationResponse.fromJson(
              data["data"],
            );

            if (page == 1) {
              _events = paginationResponse.data;
            } else {
              _events.addAll(paginationResponse.data);
            }

            _currentPage = paginationResponse.currentPage;
            _lastPage = paginationResponse.lastPage;
            _total = paginationResponse.total;
            _hasNextPage = paginationResponse.nextPageUrl != null;
            _hasPrevPage = paginationResponse.prevPageUrl != null;
          } else {
            if (data is List) {
              _events = data.map((json) => Event.fromJson(json)).toList();
              _currentPage = 1;
              _lastPage = 1;
              _total = _events.length;
              _hasNextPage = false;
              _hasPrevPage = false;
            } else {
              _error = "Unexpected response structure";
            }
          }
        } catch (parseError) {
          print("Parse error: $parseError");
          print("Error details: ${parseError.toString()}");
          _error = "Failed to parse response: $parseError";
        }
      } else {
        _error = "Failed to fetch events (Status: ${response.statusCode})";
      }
    } catch (e) {
      _error = "Network error. Please check your connection.";
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreEvents(AuthProvider authProvider) async {
    if (_isLoadingMore || !_hasNextPage) return;

    await fetchEvents(authProvider, page: _currentPage + 1);
  }

  Future<bool> addEvent(
    AuthProvider authProvider,
    String title,
    String description,
    String date,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? token = authProvider.token;

      if (token == null) {
        _error = "Please login first";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      var bodyData = jsonEncode({
        'EventTitle': title,
        'EventDesc': description,
        'EventDate': date,
      });

      final response = await http.post(
        Uri.parse("$baseUrl/api/events"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyData,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Add response: $data");

        if (data != null) {
          _currentPage = 1;
          _events = [];
          try {
            await fetchEvents(authProvider, page: 1);
          } catch (e) {
            print("Error refreshing events after add: $e");
          }
          return true;
        } else {
          _error = data["message"] ?? "Failed to add event";
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = "Failed to add event";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Network error. Please check your connection.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(
    AuthProvider authProvider,
    int eventId,
    String title,
    String description,
    String date,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? token = authProvider.token;

      if (token == null) {
        _error = "Please login first";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      var bodyData = jsonEncode({
        'EventTitle': title,
        'EventDesc': description,
        'EventDate': date,
      });

      final response = await http.put(
        Uri.parse("$baseUrl/api/events/$eventId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyData,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Update response: $data");

        if (data != null) {
          _currentPage = 1;
          _events = [];
          try {
            await fetchEvents(authProvider, page: 1);
          } catch (e) {
            print("Error refreshing events after update: $e");
          }
          return true;
        } else {
          _error = data["message"] ?? "Failed to update event";
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = "Failed to update event";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Network error. Please check your connection.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(AuthProvider authProvider, int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? token = authProvider.token;

      if (token == null) {
        _error = "Please login first";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/api/events/$eventId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Delete response: $data");

        if (data["status"]) {
          _currentPage = 1;
          _events = [];
          try {
            await fetchEvents(authProvider, page: 1);
          } catch (e) {
            print("Error refreshing events after delete: $e");
          }
          return true;
        } else {
          _error = data["message"] ?? "Failed to delete event";
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = "Failed to delete event";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Network error. Please check your connection.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetAdminStatus() {
    _isAdmin = false;
    notifyListeners();
  }
}

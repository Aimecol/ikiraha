import 'package:flutter/foundation.dart';
import '../models/user.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _error;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Initialize auth state (check if user is already logged in)
  Future<void> initializeAuth() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // TODO: Check for stored auth token/user data
      // For now, simulate checking stored credentials
      await Future.delayed(const Duration(seconds: 1));
      
      // If no stored auth found, set to unauthenticated
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _error = 'Failed to initialize authentication';
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      // TODO: Implement actual API call
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation - in real app, this would be server-side
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Mock successful login
      _user = User(
        id: '1',
        email: email,
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isEmailVerified: true,
      );

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      // TODO: Implement actual API call
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation - in real app, this would be server-side
      if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
        throw Exception('All required fields must be filled');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (firstName.length < 2) {
        throw Exception('First name must be at least 2 characters');
      }

      if (lastName.length < 2) {
        throw Exception('Last name must be at least 2 characters');
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty && !_isValidPhoneNumber(phoneNumber)) {
        throw Exception('Please enter a valid phone number');
      }

      // Mock successful registration
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        isEmailVerified: false,
      );

      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _clearError();

    try {
      // TODO: Implement actual API call
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty) {
        throw Exception('Email is required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Mock successful password reset request
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // TODO: Clear stored auth token/user data
      await Future.delayed(const Duration(milliseconds: 500));
      
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _error = 'Failed to logout';
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    if (_user == null) return false;

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _user = _user!.copyWith(
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  // Helper methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    // Simple phone validation - adjust regex based on your requirements
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }
}

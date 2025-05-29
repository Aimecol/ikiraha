import '../constants/app_strings.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }
    
    return null;
  }

  // First name validation
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.firstNameRequired;
    }
    
    if (value.trim().length < 2) {
      return AppStrings.firstNameTooShort;
    }
    
    return null;
  }

  // Last name validation
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.lastNameRequired;
    }
    
    if (value.trim().length < 2) {
      return AppStrings.lastNameTooShort;
    }
    
    return null;
  }

  // Phone number validation (optional field)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it has at least 10 digits
    if (digitsOnly.length < 10) {
      return AppStrings.invalidPhoneNumber;
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation (for both first and last names)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    // Check if name contains only letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Strong password validation (optional, more strict)
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Username validation (if needed)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    // Check if username contains only alphanumeric characters and underscores
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  // Age validation (if needed)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    
    if (age > 120) {
      return 'Please enter a valid age';
    }
    
    return null;
  }
}

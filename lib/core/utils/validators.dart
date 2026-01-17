class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget is required';
    }
    final budget = double.tryParse(value);
    if (budget == null || budget <= 0) {
      return 'Please enter a valid budget amount';
    }
    return null;
  }

  static String? validateProgress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Progress is required';
    }
    final progress = int.tryParse(value);
    if (progress == null || progress < 0 || progress > 100) {
      return 'Please enter a valid progress (0-100)';
    }
    return null;
  }
}
class AppValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final String? requiredCheck = validateRequired(value, 'Email');
    if (requiredCheck != null) return requiredCheck;

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final String? requiredCheck = validateRequired(value, 'Contact number');
    if (requiredCheck != null) return requiredCheck;

    // Strict 10-digit Indian phone number regex
    final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value!.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? validateSafetyScore(String? value) {
    final String? requiredCheck = validateRequired(value, 'Safety score');
    if (requiredCheck != null) return requiredCheck;

    final double? score = double.tryParse(value!.trim());
    if (score == null || score < 0 || score > 100) {
      return 'Safety score must be between 0 and 100';
    }
    return null;
  }
}

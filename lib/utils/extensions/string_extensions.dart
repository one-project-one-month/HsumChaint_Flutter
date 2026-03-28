extension StringExtensions on String {
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  String get capitalizeFirst {
    if (trim().isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeAllWords {
    if (trim().isEmpty) return this;
    return split(
      ' ',
    ).map((word) => word.isNotEmpty ? word.capitalizeFirst : '').join(' ');
  }

  bool get isNullOrEmpty => trim().isEmpty;
}

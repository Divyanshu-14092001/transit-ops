import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';

export '../../controllers/dashboard_controller.dart';

void showActionSnackbar(String message) {
  Get.snackbar(
    'Operational Event',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF0F172A),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );
}

String formatIndianCost(double cost) {
  String cleaned = cost.toStringAsFixed(0);
  if (cleaned.length <= 3) return cleaned;
  String lastThree = cleaned.substring(cleaned.length - 3);
  String rest = cleaned.substring(0, cleaned.length - 3);
  List<String> groups = [];
  int i = rest.length;
  while (i > 0) {
    int start = i - 2;
    if (start < 0) start = 0;
    groups.insert(0, rest.substring(start, i));
    i -= 2;
  }
  return '${groups.join(',')},$lastThree';
}

class IndianCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    String formatted = _format(cleaned);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String cleaned) {
    if (cleaned.length <= 3) return cleaned;
    String lastThree = cleaned.substring(cleaned.length - 3);
    String rest = cleaned.substring(0, cleaned.length - 3);
    List<String> groups = [];
    int i = rest.length;
    while (i > 0) {
      int start = i - 2;
      if (start < 0) start = 0;
      groups.insert(0, rest.substring(start, i));
      i -= 2;
    }
    return '${groups.join(',')},$lastThree';
  }
}

class TimelineNode {
  final String title;
  final bool isActive;
  final TripStatusHistory? history;
  final Color color;

  TimelineNode({
    required this.title,
    required this.isActive,
    this.history,
    required this.color,
  });
}

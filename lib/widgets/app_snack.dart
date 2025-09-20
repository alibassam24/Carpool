import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnack {
  static void success(String title, String msg) {
    _show(title, msg, Colors.white, const Color(0xFF255A45), Icons.check_circle);
  }

  static void warning(String title, String msg) {
    _show(title, msg, Colors.white, const Color(0xFFFACC15), Icons.warning);
  }

  static void error(String title, String msg) {
    _show(title, msg, Colors.white, const Color(0xFFEF4444), Icons.error);
  }

  static void _show(String title, String msg, Color textColor, Color bg, IconData icon) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      colorText: textColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}

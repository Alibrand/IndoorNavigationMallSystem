import 'package:flutter/material.dart';
import 'package:get/get.dart';

showGetSnackBar(String title, String content, String type) {
  Get.snackbar(title, content,
      barBlur: 0,
      backgroundColor: type == "OK" ? Colors.green : Colors.red,
      margin: const EdgeInsets.all(5),
      duration: const Duration(seconds: 3),
      colorText: Colors.white);
}

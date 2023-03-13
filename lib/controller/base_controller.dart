import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachidmallsystem/helper/general_helper.dart';
import 'package:rachidmallsystem/model/FireResponse.dart';


class BaseController extends GetxController {
  var isLoading = false.obs;
  var fireResponse = FireRespone().obs;

  showSnackBar() {
    showGetSnackBar(fireResponse.value.status, fireResponse.value.message,
        fireResponse.value.status);
  }

  showGetDialog() {
    Get.defaultDialog(
        title: 'Error',
        middleText: fireResponse.value.message,
        cancel: ElevatedButton(
            onPressed: () {
              Get.back();
              exit(0);
            },
            child: const Text('Ok')));
  }
}

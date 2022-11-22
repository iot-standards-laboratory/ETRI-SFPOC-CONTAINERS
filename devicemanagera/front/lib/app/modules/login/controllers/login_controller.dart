import 'package:flutter/material.dart';
import 'package:front/constants.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController
  var formKey = GlobalKey<FormState>();
  final count = 0.obs;
  var email = '';
  var password = '';

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Future<bool> login() async {
  //   var url = Uri.http(
  //     'localhost:4444',
  //     '/login',
  //   );

  //   http.post(url);
  //   return true;
  // }
  Future<bool> login() async {
    if (email == 'etri@etri.com' && password == 'etrietri') {
      isLogin = true;
      return true;
    }

    return false;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../data/clients/service.dart';
import '../../../data/utils/urls.dart';

class RegistrationController extends GetxController {
  final firstnameCtrl = TextEditingController();
  final lastnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  void RegisterUser() async {
    String firstname = firstnameCtrl.text.trim();
    String lastname = lastnameCtrl.text.trim();
    String email = emailCtrl.text.trim();
    String password = passwordCtrl.text.trim();

    if (firstname.isEmpty ||
        lastname.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      Get.snackbar(
        'Error!',
        "Please enter all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Map<String, dynamic> responseBody = {
        "full_name": firstnameCtrl.text.trim(),
        "username": lastnameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "password": passwordCtrl.text,
      };

      networkResponse response = await networkClient.postRequest(
        url: Urls.registerApi,
        body: responseBody,
      );

      if(response.statusCode== 200){
        Get.snackbar(
          'Success',
          "Registration Successfully Done!",
          snackPosition: SnackPosition.BOTTOM,
        );
      }else{
        Get.snackbar(
          'faild',
          "Something went wrong!",
          snackPosition: SnackPosition.BOTTOM,
        );
      }


    }


  }

  @override
  void onClose() {
    firstnameCtrl.dispose();
    lastnameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

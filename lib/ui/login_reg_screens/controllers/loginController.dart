import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import '../../../data/utils/urls.dart';
import '../model/user_model.dart'; // UserModel ইমপোর্ট করতে হবে
import 'auth_service.dart';

class LoginController extends GetxController {
  final emailOrPhoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  var isLoading = false.obs;
  var isGuestLoading = false.obs; // গেস্ট লোডিং এর জন্য আলাদা ভেরিয়েবল

  final AuthService _authService = Get.find<AuthService>();

  // --- Regular Login ---
  Future<void> LoginUser() async {
    String email = emailOrPhoneCtrl.text.trim();
    String password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Required', "Please enter both email and password",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      Map<String, dynamic> requestBody = {
        "login_identifier": email,
        "password": password,
      };

      networkResponse response = await networkClient.postRequest(
        url: Urls.loginApi,
        body: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        String token = response.data['token'];
        Map<String, dynamic> userData = response.data['user'];

        await _authService.saveUserSession(token, userData);

        emailOrPhoneCtrl.clear();
        passwordCtrl.clear();
        Get.offAll(() => const Basescreens());
      } else {
        Get.snackbar('Failed', response.data['message'] ?? "Invalid credentials",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar('Error', "Something went wrong.");
    } finally {
      isLoading(false);
    }
  }

  // --- GUEST MODE LOGIN (One-Tap & Persistent) ---
  Future<void> loginAsGuest() async {
    try {
      isGuestLoading(true);

      // TODO: তোমার ব্যাকএন্ডে যদি Guest API থাকে, সেটি এখানে কল করবে।
      // বর্তমানে আমি একটি ডামি বা লোকাল গেস্ট সেশন তৈরি করে দিচ্ছি।

      // সিমুলেটেড API কল (বাস্তবে এখানে API কল হবে)
      await Future.delayed(const Duration(seconds: 1));

      // ডামি গেস্ট ডাটা (সার্ভার থেকে আসলে সেটাই ব্যবহার করবে)
      String guestToken = "guest_token_${DateTime.now().millisecondsSinceEpoch}";
      Map<String, dynamic> guestUser = {
        "id": "guest_001",
        "name": "Guest User",
        "email": "guest@meetyarah.com",
        "avatar": "", // ডিফল্ট আভাটার
        "is_guest": true
      };

      // AuthService-এ সেভ করা হচ্ছে (Web-এ এটি লোকাল স্টোরেজে থেকে যাবে)
      await _authService.saveUserSession(guestToken, guestUser);

      Get.snackbar('Welcome', "You are logged in as Guest",
          backgroundColor: Colors.blueGrey, colorText: Colors.white);

      Get.offAll(() => const Basescreens());

    } catch (e) {
      Get.snackbar('Error', "Guest login failed");
    } finally {
      isGuestLoading(false);
    }
  }
}
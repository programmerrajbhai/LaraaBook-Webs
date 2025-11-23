import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/controllers/get_post_controllers.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';
// ✅ Basescreens ইমপোর্ট করা হলো
import 'package:meetyarah/ui/home/screens/baseScreens.dart';

class CreatePostController extends GetxController {
  final TextEditingController postTitleCtrl = TextEditingController();
  var isLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  Future<void> createPost({List<dynamic>? images}) async {
    final String content = postTitleCtrl.text.trim();

    // ইউজার আইডি চেক
    final String? userId = _authService.userId;

    if (userId == null || userId.isEmpty) {
      Get.snackbar("Error", "Please login again to post.");
      return;
    }

    if (content.isEmpty && (images == null || images.isEmpty)) {
      Get.snackbar("Alert", "Write something or add an image.");
      return;
    }

    try {
      isLoading(true);
      String? imageUrl;

      // ইমেজ আপলোড (যদি থাকে)
      if (images != null && images.isNotEmpty) {
        imageUrl = await _uploadImage(File(images.first.path));
        if (imageUrl == null) {
          isLoading(false);
          return;
        }
      }

      // API কল
      var response = await http.post(
        Uri.parse(Urls.createPostApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "post_content": content,
          "image_url": imageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Get.snackbar("Success", "Post created successfully!");
        postTitleCtrl.clear();

        // ✅ ১. হোম পেজের ডেটা রিফ্রেশ করা
        if (Get.isRegistered<GetPostController>()) {
          Get.find<GetPostController>().getAllPost();
        }

        // ✅ ২. লোডিং বন্ধ করে সরাসরি Base Screen-এ নিয়ে যাওয়া
        // Get.offAll() ব্যবহার করলে ব্যাক বাটন চাপলে আর ক্রিয়েট পোস্ট পেজে ফিরে আসবে না
        Get.offAll(() => const Basescreens());

      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to create post");
      }

    } catch (e) {
      print("Create Post Error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading(false);
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(Urls.uploadImageApi));
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json != null && json['status'] == 'success') {
          return json['image_url'];
        }
      }
      return null;
    } catch (e) {
      print("Upload Exception: $e");
      return null;
    }
  }
}
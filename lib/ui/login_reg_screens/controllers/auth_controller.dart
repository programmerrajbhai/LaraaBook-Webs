import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meetyarah/ui/login_reg_screens/model/user_model.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/login_screen.dart';

class AuthService extends GetxService {
  late SharedPreferences _prefs;

  // রিয়েল-টাইম ইউজার ডেটা (পুরো অ্যাপে ব্যবহার করা যাবে)
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxString token = ''.obs;

  // অ্যাপ চালুর সময় এই ফাংশনটি কল হবে
  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserSession();
    return this;
  }

  // --- ১. লগইন সেশন সেভ করা ---
  Future<void> saveUserSession(String userToken, Map<String, dynamic> userMap) async {
    // টোকেন সেভ
    await _prefs.setString('token', userToken);
    token.value = userToken;

    // ইউজার ডেটা সেভ (JSON String হিসেবে)
    // UserModel.fromJson ব্যবহার করে নিশ্চিত করি ডেটা ঠিক আছে
    UserModel loggedInUser = UserModel.fromJson(userMap);
    await _prefs.setString('user_data', jsonEncode(loggedInUser.toJson()));

    // মেমোরিতে আপডেট
    user.value = loggedInUser;

    print("✅ User Session Saved: ${loggedInUser.username}");
  }

  // --- ২. অটোমেটিক লগইন চেক (অ্যাপ রিস্টার্ট হলে) ---
  Future<void> _loadUserSession() async {
    final String? savedToken = _prefs.getString('token');
    final String? savedUserData = _prefs.getString('user_data');

    // যদি টোকেন এবং ডেটা থাকে, তবে মেমোরিতে লোড করি
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
    }

    if (savedUserData != null && savedUserData.isNotEmpty) {
      try {
        user.value = UserModel.fromJson(jsonDecode(savedUserData));
        print("✅ User Loaded from Storage: ${user.value?.username}");
      } catch (e) {
        print("❌ Error loading user data: $e");
        // ডাটা করাপ্ট হলে ক্লিয়ার করে দিই
        await logout();
      }
    }
  }

  // --- ৩. লগআউট ---
  Future<void> logout() async {
    await _prefs.clear(); // সব লোকাল ডেটা মুছে ফেলি
    token.value = '';
    user.value = null;

    // লগইন পেজে পাঠিয়ে দিই
    Get.offAll(() => const LoginScreen());
  }

  // --- হেল্পার গেটার ---
  bool get isLoggedIn => token.value.isNotEmpty;

  // ইউজার আইডি পাওয়ার সহজ উপায় (String বা int যাই হোক, মডেল হ্যান্ডেল করবে)
  String? get userId => user.value?.user_id;
}
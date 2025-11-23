import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';

class GetPostController extends GetxController {
  var posts = <GetPostModel>[].obs;
  var isLoading = true.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    getAllPost();
    super.onInit();
  }

  // পোস্ট লোড করা (User ID সহ)
  Future<void> getAllPost() async {
    try {
      isLoading(true);
      String? myUserId = _authService.userId;

      String url = Urls.get_all_posts;
      if (myUserId != null && myUserId.isNotEmpty) {
        url = "$url?user_id=$myUserId";
      }

      networkResponse response = await networkClient.getRequest(url: url);

      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data!['posts'];
        posts.value = data.map((e) => GetPostModel.fromJson(e)).toList();
      } else {
        Get.snackbar("Error", response.errorMessage ?? "Something went wrong");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // ✅ লাইক টগল ফাংশন (আপডেটেড)
  Future<void> toggleLike(int index) async {
    var post = posts[index];
    String? userId = _authService.userId;

    // লগইন চেক
    if (userId == null) {
      Get.snackbar("Error", "Please login to like posts");
      return;
    }

    // ১. UI তে আগে আপডেট করি (যাতে ইউজার ওয়েট না করে)
    bool previousState = post.isLiked; // আগের অবস্থা ব্যাকআপ রাখা

    // টগল লজিক
    post.isLiked = !post.isLiked;

    // লাইক কাউন্ট আপডেট
    if (post.isLiked) {
      post.like_count = (post.like_count ?? 0) + 1;
    } else {
      post.like_count = (post.like_count ?? 0) - 1;
    }

    posts.refresh(); // UI রিফ্রেশ

    // ২. সার্ভারে রিকোয়েস্ট পাঠানো
    try {
      networkResponse response = await networkClient.postRequest(
        url: Urls.likePostApi,
        body: {
          "user_id": userId,
          "post_id": post.post_id,
        },
      );

      // ৩. রেসপন্স হ্যান্ডলিং
      if (response.isSuccess && response.data['status'] == 'success') {

        String action = response.data['action']; // 'liked' or 'unliked'

        // সফল হলে স্ন্যাকবার দেখানো
        Get.snackbar(
          "Success",
          action == 'liked' ? "Post Liked ❤️" : "Post Unliked 💔",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );

      } else {
        // ❌ ফেইল হলে আগের অবস্থায় ফিরে যাওয়া (Revert)
        _revertLikeState(post, previousState);
        Get.snackbar("Error", "Failed to update like");
      }

    } catch (e) {
      print("Like API Error: $e");
      // ❌ এরর হলে আগের অবস্থায় ফিরে যাওয়া
      _revertLikeState(post, previousState);
      Get.snackbar("Error", "Connection failed!");
    }
  }

  // এরর হলে রিভার্ট করার হেল্পার ফাংশন
  void _revertLikeState(GetPostModel post, bool previousState) {
    post.isLiked = previousState;
    if (post.isLiked) {
      post.like_count = (post.like_count ?? 0) + 1;
    } else {
      post.like_count = (post.like_count ?? 0) - 1;
    }
    posts.refresh();
  }
}
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';
import 'get_post_controllers.dart'; // GetPostController ইমপোর্ট করতে হবে

class LikeController extends GetxController {
  // অন্য কন্ট্রোলারগুলো খুঁজে বের করছি
  final AuthService _authService = Get.find<AuthService>();
  final GetPostController _postController = Get.find<GetPostController>();

  Future<void> toggleLike(int index) async {
    // পোস্ট লিস্ট থেকে নির্দিষ্ট পোস্টটি ধরা
    var post = _postController.posts[index];
    String? userId = _authService.userId;

    if (userId == null) {
      Get.snackbar("Error", "Please login to like posts");
      return;
    }

    // ১. UI আপডেট (Optimistic Update)
    bool previousStatus = post.isLiked;
    post.isLiked = !post.isLiked;

    if (post.isLiked) {
      post.like_count = (post.like_count ?? 0) + 1;
    } else {
      post.like_count = (post.like_count ?? 0) - 1;
    }

    // UI রিফ্রেশ করা (GetPostController এর লিস্ট আপডেট করা হচ্ছে)
    _postController.posts.refresh();

    // ২. API কল
    try {
      networkResponse response = await networkClient.postRequest(
        url: Urls.likePostApi,
        body: {
          "user_id": userId,
          "post_id": post.post_id,
        },
      );

      if (!response.isSuccess) {
        // ফেইল হলে রিভার্ট করা
        post.isLiked = previousStatus;
        if (post.isLiked) {
          post.like_count = (post.like_count ?? 0) + 1;
        } else {
          post.like_count = (post.like_count ?? 0) - 1;
        }
        _postController.posts.refresh();
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }
}
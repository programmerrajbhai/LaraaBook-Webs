import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import '../../../adsterra/controller/adsterra_controller.dart';
import '../../../adsterra/widgets/simple_ad_widget.dart';
import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../view_post/screens/post_details.dart';
import '../widgets/like_button.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = Get.put(GetPostController());
  final likeController = Get.put(LikeController());
  final adController = Get.put(AdsterraController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdBlocker();
    });
  }

  // --- AdBlocker Logic (No Change) ---
  Future<void> _checkAdBlocker() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://pl25522730.effectivegatecpm.com/dd/4f/78/dd4f7878c3a97f6f9e08bdf8911ad44b.js",
        ),
      );
      if (response.statusCode != 200 || response.body.isEmpty) {
        if (mounted) _showAdBlockAlert();
      }
    } catch (e) {
      if (mounted) _showAdBlockAlert();
    }
  }

  void _showAdBlockAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Ad Blocker Detected",
              style: TextStyle(color: Colors.red),
            ),
            content: const Text(
              "Please disable your AdBlocker/VPN to continue.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  const intent = AndroidIntent(
                    action: 'android.settings.SETTINGS',
                    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                  );
                  await intent.launch();
                },
                child: const Text("Open Settings"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    _checkAdBlocker,
                  );
                },
                child: const Text("I Turned It Off"),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays >= 1) return '${difference.inDays} days ago';
      return 'Just now';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await postController.getAllPost();
          },
          child: Obx(() {
            if (postController.isLoading.value) {
              return _buildFacebookShimmerEffect();
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ✅ Social Bar (Must be visible in DOM to trigger popup script)
                  const SimpleAdWidget(type: AdType.socialBar),

                  // Stories
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        5,
                        (i) =>
                            storyCard("Story $i", "https://picsum.photos/20$i"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // ✅ Top Banner
                  const FittedBox(
                    child: SimpleAdWidget(type: AdType.banner728),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: postController.posts.length,
                    itemBuilder: (context, index) {
                      final post = postController.posts[index];

                      return Column(
                        children: [
                          _buildPostContent(post, index),

                          // ✅ Banner 300x250 (Every 5 posts)
                          if ((index + 1) % 5 == 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: SimpleAdWidget(type: AdType.banner300),
                            ),

                          // ✅ Native Ad (Frequency increased: Every 4 posts)
                          if ((index + 1) % 4 == 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: SimpleAdWidget(type: AdType.native),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPostContent(post, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  post.profile_picture_url ?? "https://via.placeholder.com/150",
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.full_name ?? "User",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatTimeAgo(post.created_at),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (post.post_content != null)
            Text(post.post_content!, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),

          // ✅ Image Click Logic (High CPM Trick)
          if (post.image_url != null)
            InkWell(
              onTap: () async {
                // 🔥 50% Chance to open Smart Link instead of Image Viewer
                if (DateTime.now().millisecond % 2 == 0) {
                  await adController.openSmartLink();
                } else {
                  // এখানে আপনার অরিজিনাল ইমেজ ভিউ লজিক দিতে পারেন
                  // Get.to(() => ImageViewer(url: post.image_url));
                  print("Open Image Viewer");
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.image_url!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LikeButton(
                isLiked: post.isLiked,
                likeCount: post.like_count ?? 0,
                onTap: () => likeController.toggleLike(index),
              ),

              // ✅ Comment Button Click triggers Ad before Page Load
              interactionButton(
                Icons.comment,
                "${post.comment_count} Comments",
                onTap: () {
                  // 🔥 Open Popunder then go to details
                  adController.openPopunder();
                  Get.to(() => PostDetailPage(post: post));
                },
              ),

              interactionButton(
                Icons.share,
                "Share",
                onTap: () {
                  adController.openPopunder();
                  _showShareBottomSheet(
                    context,
                    "http://yoursite.com/post?id=${post.post_id}",
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context, String postLink) {
    // আপনার আগের কোড...
    Share.share("Check this out: $postLink");
  }

  Widget _buildFacebookShimmerEffect() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (c, i) => Padding(
        padding: const EdgeInsets.all(15),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 200, color: Colors.white),
        ),
      ),
    );
  }

  Widget storyCard(String name, String img) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(5),
      color: Colors.grey,
      child: Center(child: Text(name)),
    );
  }

  Widget interactionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}

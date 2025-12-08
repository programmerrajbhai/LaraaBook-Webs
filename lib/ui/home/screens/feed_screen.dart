import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../../../adsterra/controller/adsterra_controller.dart';
import '../../../adsterra/widgets/simple_ad_widget.dart';
import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../view_post/screens/post_details.dart';
import '../../create_post/screens/create_post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = Get.put(GetPostController());
  final likeController = Get.put(LikeController());
  final adController = Get.put(AdsterraController());

  final Map<int, String> _postReactions = {};
  final bool _showDemoAds = kDebugMode;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAdBlocker();
      });
    }
  }

  Future<void> _checkAdBlocker() async {
    try {
      final response = await http.get(Uri.parse("https://pl25522730.effectivegatecpm.com/dd/4f/78/dd4f7878c3a97f6f9e08bdf8911ad44b.js"));
      if (response.statusCode != 200 || response.body.isEmpty) {
        if (mounted) _showAdBlockAlert();
      }
    } catch (e) {
      // Ignore
    }
  }

  void _showAdBlockAlert() {
    // AdBlock alert logic (same as before)
  }

  // ✅ Link Generate Helper
  String _getPostLink(String postId) {
    return "https://meetyarah.com/post/$postId";
  }

  // ✅ Copy Link Function
  void _copyPostLink(String postId) {
    Clipboard.setData(ClipboardData(text: _getPostLink(postId)));
    if (Get.isBottomSheetOpen ?? false) Get.back(); // Close sheet if open

    Get.snackbar(
      "Link Copied",
      "Link saved to clipboard.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[900],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.link, color: Colors.white),
    );
  }

  // ✅ New: Advanced Share Menu (Bottom Sheet)
  void _showShareOptions(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text("Share this post", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Share Options Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOptionItem(Icons.copy, "Copy Link", Colors.blue, () => _copyPostLink(post.post_id ?? "0")),
                _shareOptionItem(Icons.share, "More Options", Colors.green, () {
                  Get.back();
                  Share.share("Check out this post: ${_getPostLink(post.post_id ?? "0")}");
                }),
                _shareOptionItem(Icons.send_rounded, "Send in App", Colors.purple, () {
                  Get.back();
                  Get.snackbar("Coming Soon", "Direct messaging will be available soon!", snackPosition: SnackPosition.BOTTOM);
                }),
                _shareOptionItem(Icons.add_to_photos_rounded, "Share to Feed", Colors.orange, () {
                  Get.back();
                  Get.to(() => const CreatePostScreen()); // Example redirection
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ✅ New: Three-Dot Menu Options
  void _showPostOptions(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(Icons.bookmark_border, "Save Post", "Add this to your saved items.", () {
              Get.back();
              Get.snackbar("Saved", "Post saved to your collection.", snackPosition: SnackPosition.BOTTOM);
            }),
            _buildOptionTile(Icons.visibility_off_outlined, "Hide Post", "See fewer posts like this.", () {
              Get.back();
              // Logic to hide post from list locally can be added here
            }),
            const Divider(),
            _buildOptionTile(Icons.copy, "Copy Link", "", () => _copyPostLink(post.post_id ?? "0")),
            _buildOptionTile(Icons.report_gmailerrorred, "Report Post", "I'm concerned about this post.", () {
              Get.back();
              Get.snackbar("Reported", "Thanks for letting us know.", snackPosition: SnackPosition.BOTTOM);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black87)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 900;
            double feedWidth = isWideScreen ? 600 : constraints.maxWidth;

            return RefreshIndicator(
              onRefresh: () async { await postController.getAllPost(); },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CENTER FEED ---
                  SizedBox(
                    width: feedWidth,
                    child: Obx(() {
                      if (postController.isLoading.value) return _buildShimmer();

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 50),
                        children: [
                          _buildCreatePostBox(),
                          _buildStorySection(),
                          _buildAdContainer(AdType.banner728, height: 100),

                          if (postController.posts.isEmpty)
                            _buildEmptyState(),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postController.posts.length,
                            itemBuilder: (context, index) {
                              final post = postController.posts[index];
                              return Column(
                                children: [
                                  _buildFacebookPostCard(post, index),
                                  if ((index + 1) % 5 == 0)
                                    _buildAdContainer(AdType.banner300, height: 260),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),

                  // --- RIGHT SIDEBAR (Web Only) ---
                  if (isWideScreen)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Align(alignment: Alignment.centerLeft, child: Text("Sponsored", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            const SizedBox(height: 10),
                            _buildAdContainer(AdType.native, height: 300, isSidebar: true),
                            const SizedBox(height: 20),
                            const Divider(),
                            _buildFriendSuggestions(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildCreatePostBox() {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8), // Web style edge-to-edge mostly
      elevation: 0.5,
      color: Colors.white,
      shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => Get.to(() => const CreatePostScreen()),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(25)),
                  child: const Text("What's on your mind?", style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(icon: const Icon(Icons.photo_library, color: Colors.green), onPressed: () => Get.to(() => const CreatePostScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: kIsWeb ? Colors.transparent : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage("https://picsum.photos/200/300?random=$index"), fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                  ),
                ),
                Positioned(
                  bottom: 8, left: 8,
                  child: Text(index == 0 ? "Add Story" : "User $index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacebookPostCard(dynamic post, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0.5,
      shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.profile_picture_url ?? "https://via.placeholder.com/150")),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.full_name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        children: [
                          Text(_formatTimeAgo(post.created_at), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.public, size: 12, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showPostOptions(context, post), // ✅ 3-Dot Menu Trigger
                ),
              ],
            ),
          ),

          // Content
          InkWell(
            onTap: () => Get.to(() => PostDetailPage(post: post)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.post_content != null && post.post_content!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(post.post_content!, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87)),
                    ),
                  const SizedBox(height: 8),
                  if (post.image_url != null && post.image_url!.isNotEmpty)
                    Hero(
                      tag: "post_image_${post.post_id}",
                      child: Image.network(
                        post.image_url!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(height: 200, color: Colors.grey[200], alignment: Alignment.center, child: const Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildReactionIcon(Icons.thumb_up, Colors.blue),
                    if ((post.like_count ?? 0) > 0) ...[const SizedBox(width: 6), Text("${post.like_count}", style: const TextStyle(color: Colors.grey, fontSize: 13))],
                  ],
                ),
                InkWell(onTap: () => Get.to(() => PostDetailPage(post: post)), child: Text("${post.comment_count ?? 0} Comments", style: const TextStyle(color: Colors.grey, fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildReactionButton(post, index)),
                Expanded(child: _actionButton(icon: Icons.chat_bubble_outline, label: "Comment", onTap: () => Get.to(() => PostDetailPage(post: post)))),
                Expanded(child: _actionButton(icon: Icons.share_outlined, label: "Share", onTap: () => _showShareOptions(context, post))), // ✅ Smart Share Trigger
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Widgets ---

  Widget _buildReactionButton(dynamic post, int index) {
    String currentReaction = _postReactions[index] ?? (post.isLiked ? "Like" : "None");
    IconData icon = Icons.thumb_up_off_alt;
    Color color = Colors.grey[600]!;
    String label = "Like";

    if (currentReaction == "Like") { icon = Icons.thumb_up; color = Colors.blue; label = "Like"; }
    else if (currentReaction == "Love") { icon = Icons.favorite; color = Colors.red; label = "Love"; }

    return GestureDetector(
      onLongPress: () => _showReactionMenu(index, post),
      onTap: () {
        setState(() {
          if (currentReaction == "None") { _postReactions[index] = "Like"; }
          else { _postReactions.remove(index); }
        });
        likeController.toggleLike(index);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: color, size: 20), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14))],
        ),
      ),
    );
  }

  void _showReactionMenu(int index, dynamic post) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        alignment: Alignment.center,
        child: Container(
          height: 55, width: 250,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _reactionMenuItem(index, "Like", "👍"),
              _reactionMenuItem(index, "Love", "❤️"),
              _reactionMenuItem(index, "Haha", "😂"),
              _reactionMenuItem(index, "Wow", "😮"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reactionMenuItem(int index, String type, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() => _postReactions[index] = type);
        likeController.toggleLike(index);
        Get.back();
      },
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }

  Widget _buildAdContainer(AdType type, {required double height, bool isSidebar = false}) {
    if (_showDemoAds) {
      return Container(
        height: height, width: double.infinity,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.public, color: Colors.blueAccent), Text(isSidebar ? "Sponsored" : "Advertisement")])),
      );
    }
    return Container(height: height, width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 8), color: Colors.white, child: SimpleAdWidget(type: type));
  }

  // --- Helper Widgets ---
  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: Colors.grey[600], size: 20), const SizedBox(width: 6), Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14))],
        ),
      ),
    );
  }

  Widget _buildReactionIcon(IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, size: 10, color: Colors.white));
  }

  Widget _buildEmptyState() {
    return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No posts found.")));
  }

  Widget _buildFriendSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("People You May Know", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(shrinkWrap: true, itemCount: 2, itemBuilder: (c, i) => const ListTile(title: Text("User Name"), leading: CircleAvatar())),
      ],
    );
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return "Just now";
    try {
      final diff = DateTime.now().difference(DateTime.parse(dateString));
      if (diff.inDays > 0) return "${diff.inDays}d";
      if (diff.inHours > 0) return "${diff.inHours}h";
      return "Just now";
    } catch (e) {
      return "Just now";
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(itemCount: 3, itemBuilder: (c, i) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 250, color: Colors.white, margin: const EdgeInsets.all(10))));
  }
}
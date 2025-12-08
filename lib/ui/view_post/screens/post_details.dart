import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../home/models/get_post_model.dart';
import '../../home/controllers/like_controller.dart';
import '../controllers/comments_controllers.dart';
import '../models/comments_model.dart';

class PostDetailPage extends StatefulWidget {
  final GetPostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late CommentController commentController;
  final LikeController likeController = Get.put(LikeController());

  // Local state for immediate like feedback
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    int postId = int.tryParse(widget.post.post_id.toString()) ?? 0;

    // Initialize Comment Controller unique to this post
    commentController = Get.put(
      CommentController(postId: postId),
      tag: postId.toString(),
    );

    // Initial values
    isLiked = widget.post.isLiked;
    likeCount = widget.post.like_count ?? 0;
  }

  // --- ACTIONS (Copied from Feed logic for consistency) ---

  void _handleAction({required String message, VoidCallback? action}) {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    if (action != null) action();
    Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.black87, colorText: Colors.white, margin: const EdgeInsets.all(20), borderRadius: 20, duration: const Duration(seconds: 1), icon: const Icon(Icons.check_circle, color: Colors.greenAccent));
  }

  void _copyPostLink() {
    Clipboard.setData(ClipboardData(text: "https://meetyarah.com/post/${widget.post.post_id}"));
    _handleAction(message: "Link copied to clipboard! 📋");
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        children: [
          Text("Share this post", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _shareOptionItem(Icons.copy, "Copy Link", Colors.blue, _copyPostLink),
              _shareOptionItem(Icons.share, "More", Colors.green, () {
                _handleAction(message: "Opening share options...", action: () => Share.share("Check this post: https://meetyarah.com/post/${widget.post.post_id}"));
              }),
              _shareOptionItem(Icons.send_rounded, "Send", Colors.purple, () => _handleAction(message: "Sent to friend! 🚀")),
              _shareOptionItem(Icons.add_to_photos_rounded, "Share Feed", Colors.orange, () => _handleAction(message: "Shared to timeline! ✍️")),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        children: [
          _buildOptionTile(Icons.bookmark_border, "Save Post", () => _handleAction(message: "Post saved! 💾")),
          _buildOptionTile(Icons.visibility_off_outlined, "Hide Post", () => _handleAction(message: "Post hidden. 🙈")),
          const Divider(),
          _buildOptionTile(Icons.copy, "Copy Link", _copyPostLink),
          _buildOptionTile(Icons.report_gmailerrorred, "Report Post", () => _handleAction(message: "Reported. 🛡️"), isDestructive: true),
        ],
      ),
    );
  }

  void _openFullImage() {
    if (widget.post.image_url == null) return;
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: InteractiveViewer(child: Image.network(widget.post.image_url!))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Web/FB Style BG
      appBar: AppBar(
        title: Text(widget.post.full_name ?? "Post Details", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: _showPostOptions),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWeb = constraints.maxWidth > 700;
            return Center(
              child: Container(
                width: isWeb ? 650 : double.infinity,
                decoration: isWeb ? BoxDecoration(color: Colors.white, border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade300))) : null,
                child: Column(
                  children: [
                    // --- Scrollable Content (Post + Comments) ---
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildPostContent(),
                            const Divider(thickness: 8, color: Color(0xFFF0F2F5)), // Separator
                            _buildCommentSection(),
                          ],
                        ),
                      ),
                    ),

                    // --- Sticky Input Field ---
                    _buildCommentInput(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- POST CONTENT WIDGETS ---

  Widget _buildPostContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.post.profile_picture_url ?? "https://via.placeholder.com/150"),
            ),
            title: Text(widget.post.full_name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(timeago.format(DateTime.tryParse(widget.post.created_at ?? "") ?? DateTime.now()), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),

          // Text
          if (widget.post.post_content != null && widget.post.post_content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(widget.post.post_content!, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
            ),

          const SizedBox(height: 10),

          // Image (Clickable & Zoomable)
          if (widget.post.image_url != null && widget.post.image_url!.isNotEmpty)
            GestureDetector(
              onTap: _openFullImage,
              child: Hero(
                tag: "post_image_${widget.post.post_id}",
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  width: double.infinity,
                  child: Image.network(widget.post.image_url!, fit: BoxFit.cover),
                ),
              ),
            ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text("$likeCount Likes", style: const TextStyle(color: Colors.grey)),
                ]),
                Text("${widget.post.comment_count ?? 0} Comments", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildReactionButton()),
                Expanded(child: _actionButton(Icons.mode_comment_outlined, "Comment", () {})), // Just focuses input implicitly
                Expanded(child: _actionButton(Icons.share_outlined, "Share", _showShareOptions)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMMENT SECTION WIDGETS ---

  Widget _buildCommentSection() {
    return Obx(() {
      if (commentController.isLoading.value) {
        return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
      }
      if (commentController.comments.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text("No comments yet. Be the first!", style: TextStyle(color: Colors.grey))),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: commentController.comments.length,
        itemBuilder: (context, index) {
          final CommentModel comment = commentController.comments[index];
          return _buildSingleComment(comment);
        },
      );
    });
  }

  Widget _buildSingleComment(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(comment.profilePictureUrl ?? 'https://i.pravatar.cc/150?img=5'),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Modern light bubble
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(comment.commentText, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Row(
                    children: [
                      Text(timeago.format(DateTime.now().subtract(const Duration(minutes: 5))), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Text("Like", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Text("Reply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- INPUT FIELD ---

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12")), // Current User
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: commentController.commentTextController,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
              onPressed: commentController.addComment,
            ),
          ],
        ),
      ),
    );
  }

  // --- ACTION BUTTONS & HELPERS ---

  Widget _buildReactionButton() {
    return _FeedbackButton(
      onTap: () {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        // Call API
        int idx = int.tryParse(widget.post.post_id.toString()) ?? 0;
        likeController.toggleLike(idx);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt, color: isLiked ? Colors.blue : Colors.grey[600], size: 20),
            const SizedBox(width: 6),
            Text("Like", style: TextStyle(color: isLiked ? Colors.blue : Colors.grey[600], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return _FeedbackButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return _FeedbackButton(
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

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: Icon(icon, color: isDestructive ? Colors.red : Colors.black87, size: 22)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildBottomSheetContainer({required List<Widget> children}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 15),
        ...children,
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ✅ Feedback Button (Same as Feed)
class _FeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _FeedbackButton({required this.child, required this.onTap});
  @override
  State<_FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<_FeedbackButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed ? Matrix4.diagonal3Values(0.95, 0.95, 1.0) : Matrix4.identity(),
        decoration: BoxDecoration(color: _isPressed ? Colors.grey.shade200 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: widget.child,
      ),
    );
  }
}
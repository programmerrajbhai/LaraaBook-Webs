import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';

import '../controllers/comments_controllers.dart';
import '../models/comments_model.dart';
import '../widgets/post_card.dart';

class PostDetailPage extends StatelessWidget {
  final GetPostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {

    int postId = int.tryParse(post.post_id.toString()) ?? 0;

    final CommentController controller = Get.put(
      CommentController(postId: postId),
      tag: postId.toString(),
    );

    const Color darkBlue = Color(0xFF1B1B3C);
    const Color mediumBlue = Color(0xFF2A2A4A);

    return Scaffold(
      appBar: AppBar(
        title: Text(post.full_name ?? "Unknown User"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // পোস্ট কার্ড
          PostCard(
            post: post,
            isDetailPage: true,
          ),

          // সব কমেন্ট লিস্ট
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // যদি কোনো কমেন্ট না থাকে
              if (controller.comments.isEmpty) {
                return const Center(
                  child: Text(
                    "No comments yet. Be the first to comment!",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final CommentModel comment = controller.comments[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            comment.profilePictureUrl ??
                                'https://i.pravatar.cc/150?img=5',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: mediumBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.fullName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.commentText,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // কমেন্ট ইনপুট ফিল্ড
          _buildCommentInput(context, mediumBlue, controller),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
      BuildContext context,
      Color backgroundColor,
      CommentController controller,
      ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentTextController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: controller.addComment,
          )
        ],
      ),
    );
  }
}
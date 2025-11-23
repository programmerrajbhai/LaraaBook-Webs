import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';

class PostCard extends StatelessWidget {
  final GetPostModel post;
  final bool isDetailPage;

  const PostCard({
    super.key,
    required this.post,
    this.isDetailPage = false,s
  });

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF2A2A4A);
    const Color textColor = Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- USER INFO ----------
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  post.profile_picture_url ??
                      "https://i.pravatar.cc/150?img=12",
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.full_name ?? "Unknown User",
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '@${post.username ?? 'username'}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- POST TEXT ----------
          if (post.post_content != null && post.post_content!.isNotEmpty)
            Text(
              post.post_content!,
              style: const TextStyle(color: textColor, fontSize: 14),
            ),

          const SizedBox(height: 10),

          // ---------- POST IMAGE ----------
          if (post.image_url != null && post.image_url!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.image_url!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 14),

          // ---------- LIKE & COMMENT SECTION ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Like Count
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${post.like_count ?? 0} Likes",
                    style: const TextStyle(color: textColor),
                  ),
                ],
              ),

              // Comment Button (Hidden on Detail Page)
              if (!isDetailPage)
                InkWell(
                  onTap: () {
                    // পেজে যাও
                    Get.toNamed('/post-detail', arguments: post);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${post.comment_count ?? 0} Comments",
                        style: const TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}



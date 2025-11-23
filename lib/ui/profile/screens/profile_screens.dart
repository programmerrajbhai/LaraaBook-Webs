import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/create_post/screens/create_post.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

import '../controllers/profile_controllers.dart'; // ডিটেইলস পেজ

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার লোড করি
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
          controller.profileUser.value?.username ?? "Loading...",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              Get.to(CreatePostScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: controller.logout, // লগআউট বাটন
          ),
        ],
      ),
      body: Obx(() {
        // লোডিং হলে স্পিনার দেখাবে
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileHeader(controller), // হেডার উইজেট
                  ]),
                ),
              ];
            },
            body: Column(
              children: [
                const TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.person_pin_outlined)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPostsGrid(controller), // ১. পোস্ট গ্রিড
                      const Center(child: Text("Tagged Photos")), // ২. ট্যাগ (খালি)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- ১. প্রোফাইল হেডার ---
  Widget _buildProfileHeader(ProfileController controller) {
    final user = controller.profileUser.value;
    // পোস্ট সংখ্যা লিস্টের সাইজ থেকে নিচ্ছি
    final postCount = controller.myPosts.length.toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // প্রোফাইল ছবি (API থেকে)
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        user?.profilePictureUrl ?? "https://cdn-icons-png.flaticon.com/512/149/149071.png"
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
              const SizedBox(width: 20),

              // স্ট্যাটস (Posts রিয়েল, বাকিগুলো ডামি)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(postCount, "Posts"),
                    _buildStatColumn("0", "Followers"), // API তে নেই, তাই 0
                    _buildStatColumn("0", "Following"), // API তে নেই, তাই 0
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // নাম এবং বায়ো
          Text(
            user?.fullName ?? "Name",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            "Flutter Developer 💙\nWelcome to my profile!", // বায়ো (স্ট্যাটিক)
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          // এডিট বাটন
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // স্ট্যাটস হেল্পার
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  // --- ২. পোস্ট গ্রিড ---
  Widget _buildPostsGrid(ProfileController controller) {
    // যদি কোনো পোস্ট না থাকে
    if (controller.myPosts.isEmpty) {
      return const Center(child: Text("No posts yet"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      itemCount: controller.myPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = controller.myPosts[index];

        return GestureDetector(
          onTap: () {
            // ইমেজে ক্লিক করলে ডিটেইলস পেজে যাবে
            Get.to(() => PostDetailPage(post: post));
          },
          child: Container(
            color: Colors.grey[200],
            child: post.image_url != null
                ? Image.network(post.image_url!, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.text_fields, color: Colors.grey)),
          ),
        );
      },
    );
  }
}
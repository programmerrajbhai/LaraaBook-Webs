import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/create_post/screens/create_post.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

import '../../profile/controllers/profile_controllers.dart';

// --- DASHBOARD DATA MODELS (Local for UI) ---
class DashboardStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  DashboardStat(this.title, this.value, this.icon, this.color);
}

class ActivityDashboardScreens extends StatelessWidget {
  const ActivityDashboardScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Web Centered Layout Logic
            bool isWide = constraints.maxWidth > 900;
            double contentWidth = isWide ? 800 : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: DefaultTabController(
                  length: 3, // Posts, Dashboard, Tagged
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) {
                      return [
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildProfileHeader(controller),
                          ]),
                        ),
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            const TabBar(
                              indicatorColor: Colors.black87,
                              labelColor: Colors.black87,
                              unselectedLabelColor: Colors.grey,
                              indicatorWeight: 2,
                              tabs: [
                                Tab(icon: Icon(Icons.grid_on), text: "Posts"),
                                Tab(icon: Icon(Icons.bar_chart_rounded), text: "Dashboard"),
                                Tab(icon: Icon(Icons.person_pin_outlined), text: "Tagged"),
                              ],
                            ),
                          ),
                          pinned: true,
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        _buildPostsGrid(controller),      // Tab 1
                        _buildDashboardTab(controller),   // Tab 2 (Merged Dashboard)
                        _buildTaggedGrid(),               // Tab 3
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- APP BAR ---
  AppBar _buildAppBar(ProfileController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Obx(() => Text(
        controller.profileUser.value?.username ?? "Loading...",
        style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      )),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_box_outlined, color: Colors.black),
          tooltip: "Create Post",
          onPressed: () => Get.to(() => const CreatePostScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Bottom Sheet Menu for Settings/Logout
            Get.bottomSheet(
              Container(
                color: Colors.white,
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Logout"),
                      onTap: () {
                        Get.back();
                        controller.logout();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // --- PROFILE HEADER (User Info) ---
  Widget _buildProfileHeader(ProfileController controller) {
    final user = controller.profileUser.value;
    final postCount = controller.myPosts.length.toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(user?.profilePictureUrl ?? "https://i.pravatar.cc/150?img=12"),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
              const SizedBox(width: 20),

              // Stats Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(postCount, "Posts"),
                    _buildStatItem("1.2k", "Followers"), // Dummy
                    _buildStatItem("350", "Following"),  // Dummy
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name & Bio
          Text(
            user?.fullName ?? "Unknown",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          if (user?.username != null)
            Text("@${user!.username}", style: const TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 6),
          const Text(
            "💻 Flutter Developer & Content Creator\n🌍 Creating amazing apps with GetX\n👇 Check my dashboard for insights!",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Edit Profile"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Share Profile"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // --- TAB 1: POSTS GRID ---
  Widget _buildPostsGrid(ProfileController controller) {
    if (controller.myPosts.isEmpty) {
      return _buildEmptyState("No posts yet", Icons.camera_alt_outlined);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(),
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
          onTap: () => Get.to(() => PostDetailPage(post: post)),
          child: Container(
            color: Colors.grey[100],
            child: post.image_url != null
                ? Image.network(post.image_url!, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
          ),
        );
      },
    );
  }

  // --- TAB 2: DASHBOARD (MERGED) ---
  Widget _buildDashboardTab(ProfileController controller) {
    // ডামি ড্যাশবোর্ড ডাটা (বাস্তবে API থেকে আসতে পারে)
    final stats = [
      DashboardStat("Accounts Reached", "12.5K", Icons.people_outline, Colors.blue),
      DashboardStat("Content Interactions", "4.2K", Icons.touch_app_outlined, Colors.orange),
      DashboardStat("Total Followers", "1,230", Icons.person_add_outlined, Colors.green),
      DashboardStat("Approx. Earnings", "\$120.50", Icons.attach_money, Colors.purple),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Title
        Text("Professional Dashboard", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text("Insights from the last 30 days", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 20),

        // Stats Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            return _buildDashboardCard(stats[index]);
          },
        ),

        const SizedBox(height: 20),

        // Recent Performance List
        const Text("Recent Performance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildPerformanceTile("Most Viewed Post", "5.2K Views", Icons.remove_red_eye_outlined),
        _buildPerformanceTile("Top Commented", "120 Comments", Icons.comment_outlined),
        _buildPerformanceTile("Profile Visits", "310 Visits", Icons.person_search_outlined),

        const SizedBox(height: 20),
        // Ad/Banner Area
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_graph, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Boost your profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text("Reach more people today", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(DashboardStat stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(stat.icon, color: stat.color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(stat.title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTile(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
    );
  }

  // --- TAB 3: TAGGED (Placeholder) ---
  Widget _buildTaggedGrid() {
    return _buildEmptyState("No tagged photos", Icons.person_pin_outlined);
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}

// --- HELPER FOR STICKY TABS ---
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Sticky background color
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
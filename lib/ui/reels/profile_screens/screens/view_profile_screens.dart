import 'dart:math';
import 'dart:ui'; // For Blur Effect
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==========================================
// 1. DATA MODELS & HELPER (Your Provided Code)
// ==========================================

class VideoDataModel {
  final String url;
  final String title;
  final String channelName;
  final String views;
  final String likes;
  final String comments;
  final String timeAgo;
  final String duration;
  final String profileImage;
  final String subscribers;

  VideoDataModel({
    required this.url, required this.title, required this.channelName,
    required this.views, required this.likes, required this.comments,
    required this.timeAgo, required this.duration, required this.profileImage,
    required this.subscribers,
  });
}

class VideoDataHelper {
  static final List<String> _realProfileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1587009/pexels-photo-1587009.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/2104252/pexels-photo-2104252.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/2613260/pexels-photo-2613260.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/2773977/pexels-photo-2773977.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=200',
  ];

  static final List<String> _girlNames = [
    "Naughty Anika", "Desi Bhabi Vlogs", "Sexy Sophia", "Dream Girl Rimi",
    "Hot Bella", "Misty Night", "Sofia X", "Cute Puja",
    "Viral Queen", "Midnight Lover"
  ];

  static final List<String> _titleStart = ["OMG! My Ex", "Late Night", "Desi Bhabi", "College Girl", "Bathroom", "Bedroom Secret"];
  static final List<String> _titleMiddle = ["Forgot Camera Was ON 📸", "Leaked Video Viral", "Romance with BF", "Changing Clothes 👗"];
  static final List<String> _titleEnd = ["🔥 | Too Hot", "❌ | Don't Tell Anyone", "🔞 | 18+ Only", "😱 | Viral Clip"];

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;
      String dynamicTitle = "${_titleStart[random.nextInt(_titleStart.length)]} ${_titleMiddle[random.nextInt(_titleMiddle.length)]} ${_titleEnd[random.nextInt(_titleEnd.length)]}";
      String dynamicChannel = _girlNames[random.nextInt(_girlNames.length)];

      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: dynamicTitle,
        channelName: dynamicChannel,
        views: "${(random.nextDouble() * 8 + 0.5).toStringAsFixed(1)}M",
        likes: "${random.nextInt(80) + 20}K",
        comments: "${random.nextInt(2000) + 500}",
        timeAgo: "${random.nextInt(12) + 1}h",
        duration: "${random.nextInt(15) + 4}:${random.nextInt(50) + 10}",
        profileImage: _realProfileImages[random.nextInt(_realProfileImages.length)],
        subscribers: "${(random.nextDouble() * 5 + 0.5).toStringAsFixed(1)}M",
      );
    });
  }
}

// ==========================================
// 2. CONTROLLER
// ==========================================
class ProfileController extends GetxController {
  var isVip = false.obs;

  // Dummy data generated
  late List<VideoDataModel> posts;

  @override
  void onInit() {
    super.onInit();
    posts = VideoDataHelper.generateVideos(20); // Generate 20 posts
  }

  void unlockContent() {
    isVip.value = true;
    Get.snackbar(
      "VIP Unlocked! 💎",
      "Welcome to the premium club.",
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      borderRadius: 20,
    );
  }
}

// ==========================================
// 3. MAIN PROFILE SCREEN UI
// ==========================================
class ProfileViewScreen extends StatefulWidget {
  // যদি কোনো স্পেসিফিক ডাটা পাস করতে চান, কনস্ট্রাক্টর ইউজ করতে পারেন
  // final VideoDataModel? initialData;
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final Color ofBlue = const Color(0xFF00AFF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // --- 1. Cover Photo (SliverAppBar) ---
              SliverAppBar(
                expandedHeight: 180,
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "https://images.pexels.com/photos/3756770/pexels-photo-3756770.jpeg?auto=compress&cs=tinysrgb&w=1260",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // --- 2. Profile Info (Overlapping Logic) ---
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Avatar & Info Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 Overlapping Avatar
                          Transform.translate(
                            offset: const Offset(0, -45), // Moves avatar UP over the cover
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))]
                                  ),
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage("https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=600"),
                                  ),
                                ),
                                const Spacer(),
                                // Action Buttons on the right
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 45),
                                  child: Row(
                                    children: [
                                      _iconBtn(Icons.share_outlined),
                                      const SizedBox(width: 10),
                                      _iconBtn(Icons.star_border),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          // Name & Bio Section (Adjusted spacing due to transform)
                          Transform.translate(
                            offset: const Offset(0, -35),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Sofia Rose", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                                    const SizedBox(width: 6),
                                    Icon(Icons.verified, color: ofBlue, size: 22),
                                  ],
                                ),
                                Text("@sofia_rose_vip • Available Now", style: TextStyle(color: Colors.grey[600], fontSize: 14)),

                                const SizedBox(height: 12),
                                const Text(
                                  "Hey loves! 💖 Welcome to my exclusive world.\nActress | Model | Dreamer ✨",
                                  style: TextStyle(fontSize: 15, height: 1.4),
                                ),

                                const SizedBox(height: 20),
                                // Stats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _statItem("126", "Posts"),
                                    _statItem("5.2K", "Likes"),
                                    _statItem("1.1K", "Fans"),
                                    const Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Subscribe Button
                                Obx(() => !controller.isVip.value
                                    ? SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: controller.unlockContent,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ofBlue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 5,
                                    ),
                                    child: const Text("SUBSCRIBE FOR \$9.99", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                )
                                    : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(30)),
                                  child: const Center(child: Text("MEMBER ACTIVE ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 3. Sticky TabBar Header ---
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: ofBlue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: ofBlue,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "POSTS"),
                      Tab(text: "MEDIA"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // --- POSTS TAB ---
              ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final data = controller.posts[index];

                  // 🔥 Logic: প্রথম ২টা পোস্ট ফ্রি, এরপর ১টা লকড, ১টা ফ্রি (এমন লজিক)
                  // অথবা আপনি চাইলে সিম্পল index ধরে করতে পারেন
                  bool isLocked = false;

                  // উদাহরণ: 0, 1 ইনডেক্স ফ্রি, বাকিগুলো লকড (ডেমো হিসেবে)
                  // অথবা রিকোয়ারমেন্ট অনুযায়ী: "list a rakle free hbe"
                  // এখানে আমি ধরে নিচ্ছি বিজোড় সংখ্যার পোস্টগুলো লকড (Paid)
                  if (index > 1 && index % 2 != 0) {
                    isLocked = true;
                  }

                  return _buildPostCard(data, isLocked);
                },
              ),

              // --- MEDIA TAB (Grid) ---
              GridView.builder(
                padding: const EdgeInsets.all(1),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) => Image.network(controller.posts[index].profileImage, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00AFF0)), shape: BoxShape.circle),
      child: Icon(icon, color: const Color(0xFF00AFF0), size: 20),
    );
  }

  Widget _statItem(String count, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  // 🔥 POST CARD WIDGET
  Widget _buildPostCard(VideoDataModel data, bool isLocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: NetworkImage(data.profileImage)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sofia Rose", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(data.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text(data.title, style: const TextStyle(fontSize: 14)),
          ),

          // 🔥 Content Logic (Free vs Paid)
          Obx(() {
            bool shouldLock = isLocked && !controller.isVip.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Image (Blurred if locked)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: shouldLock ? 15 : 0, sigmaY: shouldLock ? 15 : 0),
                  child: Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(data.profileImage), // Using profile image as post image for demo
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Lock Overlay
                if (shouldLock)
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white)),
                          child: const Icon(Icons.lock, color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 15),
                        const Text("PREMIUM CONTENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showSubscriptionSheet(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ofBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          child: const Text("UNLOCK POST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
              ],
            );
          }),

          // Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.favorite_border), const SizedBox(width: 5), Text(data.likes),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline), const SizedBox(width: 5), Text(data.comments),
                const Spacer(),
                const Icon(Icons.bookmark_border),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        ],
      ),
    );
  }

  void _showSubscriptionSheet() {
    Get.bottomSheet(
        Container(
          height: 300,
          color: Colors.white,
          child: Center(child: Text("Subscription Sheet Placeholder")),
        )
    );
  }
}

// ==========================================
// 4. STICKY HEADER DELEGATE CLASS
// ==========================================
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
      color: Colors.white, // Background color for sticky header
      child: Column(
        children: [
          _tabBar,
          Container(height: 1, color: Colors.grey[200]), // Bottom border line
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
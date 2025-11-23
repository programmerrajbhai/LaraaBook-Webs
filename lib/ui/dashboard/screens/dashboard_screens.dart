import 'package:flutter/material.dart';
// আপনার কালার ফাইলটি import করুন
// import 'package:meetyarah/assetsPath/textColors.dart';

// --- ডেমো ডেটার জন্য মডেল ক্লাস ---

// 1. পোস্ট পারফরম্যান্স মডেল
class PostPerformance {
  final String title;
  final String imageUrl;
  final int views;
  final int likes;
  final int comments;

  PostPerformance({
    required this.title,
    required this.imageUrl,
    required this.views,
    required this.likes,
    required this.comments,
  });
}

// 2. সাম্প্রতিক অ্যাক্টিভিটি মডেল
class RecentActivity {
  final String userName;
  final String userImageUrl;
  final String activity; // যেমন: "liked your post", "started following you"
  final String timeAgo;

  RecentActivity({
    required this.userName,
    required this.userImageUrl,
    required this.activity,
    required this.timeAgo,
  });
}

// --- মূল ড্যাশবোর্ড স্ক্রিন ---

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({Key? key}) : super(key: key);

  @override
  _ActivityDashboardScreenState createState() =>
      _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState extends State<ActivityDashboardScreen> {
  // --- ডেমো ডেটা ---
  final Map<String, dynamic> _overviewStats = {
    'posts': 124,
    'likes': 8200,
    'followers': 1350,
    'profileViews': 21300,
  };

  final List<PostPerformance> _recentPosts = [
    PostPerformance(
      title: "Just released my new Meetyarah app project... 🔥",
      imageUrl: "https://images.unsplash.com/photo-1542393545-10f5cde2c810?q=80&w=1965&auto=format&fit=crop",
      views: 5200,
      likes: 310,
      comments: 45,
    ),
    PostPerformance(
      title: "Exploring the beautiful mountains this weekend!",
      imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=2070&auto=format&fit=crop",
      views: 12000,
      likes: 1100,
      comments: 120,
    ),
    PostPerformance(
      title: "My setup for coding.",
      imageUrl: "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=2070&auto=format&fit=crop",
      views: 2100,
      likes: 150,
      comments: 22,
    ),
  ];

  final List<RecentActivity> _recentActivity = [
    RecentActivity(
      userName: 'Rina Akter',
      userImageUrl: 'https://i.pravatar.cc/150?img=49',
      activity: 'liked your post.',
      timeAgo: '5m ago',
    ),
    RecentActivity(
      userName: 'Masum Billah',
      userImageUrl: 'https://i.pravatar.cc/150?img=51',
      activity: 'started following you.',
      timeAgo: '1h ago',
    ),
    RecentActivity(
      userName: 'John Doe',
      userImageUrl: 'https://i.pravatar.cc/150?img=53',
      activity: 'commented: "Great work!"',
      timeAgo: '3h ago',
    ),
    RecentActivity(
      userName: 'Sabiha Islam',
      userImageUrl: 'https://i.pravatar.cc/150?img=45',
      activity: 'liked your comment.',
      timeAgo: '8h ago',
    ),
  ];
  // --- ডেমো ডেটা শেষ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // হালকা ধূসর ব্যাকগ্রাউন্ড
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- সেকশন ১: ওভারভিউ ---
          Text(
            'Overview (Last 30 days)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsGrid(), // ওভারভিউ কার্ড গ্রিড

          const SizedBox(height: 24),

          // --- সেকশন ২: পোস্ট পারফরম্যান্স ---
          Text(
            'Post Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPostPerformanceList(), // পোস্টের লিস্ট

          const SizedBox(height: 24),

          // --- সেকশন ৩: সাম্প্রতিক অ্যাক্টিভিটি ---
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivityList(), // অ্যাক্টিভিটি লিস্ট
        ],
      ),
    );
  }

  /// 1. ওভারভিউ স্ট্যাট গ্রিড
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2, // প্রতি সারিতে ২টি কার্ড
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true, // ListView-এর ভিতরে GridView ব্যবহারের জন্য
      physics: const NeverScrollableScrollPhysics(), // ListView-এর স্ক্রল ব্যবহার করবে
      children: [
        _buildStatCard(
          title: 'Total Posts',
          value: _overviewStats['posts'].toString(),
          icon: Icons.article,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Total Likes',
          value: (_overviewStats['likes'] / 1000).toStringAsFixed(1) + 'k', // 8.2k
          icon: Icons.thumb_up,
          color: Colors.red,
        ),
        _buildStatCard(
          title: 'Followers',
          value: _overviewStats['followers'].toString(),
          icon: Icons.people,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Profile Views',
          value: (_overviewStats['profileViews'] / 1000).toStringAsFixed(1) + 'k', // 21.3k
          icon: Icons.visibility,
          color: Colors.orange,
        ),
      ],
    );
  }

  // একটি স্ট্যাট কার্ডের ডিজাইন
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. পোস্ট পারফরম্যান্স লিস্ট
  Widget _buildPostPerformanceList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // ListTile-এর কোণগুলো গোল করার জন্য
      child: Column(
        // Column ব্যবহার করা হয়েছে কারণ ListView-এর ভিতরে আরেকটি ListView.builder
        // ব্যবহার করা ভালো প্র্যাকটিস নয় (যদি না লিস্টটি খুব বড় হয়)।
        children: _recentPosts.map((post) {
          return _buildPostPerformanceTile(post);
        }).toList(),
      ),
    );
  }

  // একটি পোস্ট পারফরম্যান্স আইটেমের ডিজাইন
  Widget _buildPostPerformanceTile(PostPerformance post) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          post.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${post.views} views • ${post.likes} likes • ${post.comments} comments',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        // TODO: এই পোস্টের বিস্তারিত অ্যানালিটিক্স পেজে নেভিগেট করুন
      },
    );
  }

  /// 3. সাম্প্রতিক অ্যাক্টিভিটি লিস্ট
  Widget _buildRecentActivityList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _recentActivity.map((activity) {
          return _buildActivityTile(activity);
        }).toList(),
      ),
    );
  }

  // একট
  Widget _buildActivityTile(RecentActivity activity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(activity.userImageUrl),
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: activity.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${activity.activity}'),
          ],
        ),
      ),
      subtitle: Text(
        activity.timeAgo,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        // TODO: এই ইউজারের প্রোফাইল বা নির্দিষ্ট পোস্টে নেভিগেট করুন
      },
    );
  }
}
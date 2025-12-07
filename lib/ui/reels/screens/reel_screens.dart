import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';
import '../profile_screens/screens/view_profile_screens.dart';

// ==========================================
// 1. DATA MODEL
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
  final String bio;
  final String subscribers;
  final bool isVerified;
  final String premiumSubscribers;
  final String serviceOverview;
  final String clientFeedback;
  final String contactPrice;
  final List<String> freeContentImages;
  final List<String> premiumContentImages;

  VideoDataModel({
    required this.url,
    required this.title,
    required this.channelName,
    required this.views,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.duration,
    required this.profileImage,
    required this.bio,
    required this.subscribers,
    required this.freeContentImages,
    required this.premiumContentImages,
    required this.premiumSubscribers,
    required this.serviceOverview,
    required this.clientFeedback,
    required this.contactPrice,
    this.isVerified = false,
  });
}

// ==========================================
// 2. DATA HELPER
// ==========================================
class VideoDataHelper {
  static final List<String> _profileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  static final List<String> _girlNames = ["Sofia Rose", "Anika Vlogz", "Misty Night", "Bella X", "Desi Queen"];
  static final List<String> _titles = ["Viral Video 🔥", "Late night fun 🤫", "My new dance cover 💃", "Behind the scenes...", "Must Watch! 😱"];

  static List<String> _generateContentImages(int count, int seed) {
    return List.generate(count, (i) => "https://source.unsplash.com/random/300x400?sig=${seed + i}");
  }

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;
      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: _titles[random.nextInt(_titles.length)],
        channelName: _girlNames[random.nextInt(_girlNames.length)],
        profileImage: _profileImages[random.nextInt(_profileImages.length)],
        bio: "Content Creator ✨",
        views: "${(random.nextDouble() * 5 + 0.1).toStringAsFixed(1)}M",
        likes: "${random.nextInt(50) + 5}K",
        comments: "${random.nextInt(1000) + 100}",
        timeAgo: "${random.nextInt(23) + 1}h",
        duration: "0:30",
        subscribers: "1.2M",
        premiumSubscribers: "100K",
        serviceOverview: "Available for shoutouts",
        clientFeedback: "Great work!",
        contactPrice: "\$${random.nextInt(50) + 20}",
        isVerified: random.nextBool(),
        freeContentImages: _generateContentImages(5, index),
        premiumContentImages: _generateContentImages(5, index + 100),
      );
    });
  }
}

// ==========================================
// 3. REEL SCREENS
// ==========================================
class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  List<VideoDataModel> _allVideos = [];
  bool _isLoading = true;

  // Note: Autoplay logic is removed as per new requirement (Preview on Hold)
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    var list = VideoDataHelper.generateVideos(kIsWeb ? 30 : 50);
    list.shuffle();
    if (mounted) {
      setState(() {
        _allVideos = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF1877F2),
            child: _isLoading
                ? _buildShimmerLoading()
                : ListView.builder(
              controller: _scrollController,
              itemCount: _allVideos.length,
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: kIsWeb ? 800 : 1500,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FacebookVideoCard(
                    key: ValueKey(_allVideos[index].url),
                    videoData: _allVideos[index],
                    allVideosList: _allVideos.map((e) => e.url).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildResponsiveAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      titleSpacing: kIsWeb ? 20 : 0,
      title: const Text(
        "facebook",
        style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: -1.2),
      ),
      actions: [
        if (kIsWeb) ...[
          _webNavIcon(Icons.home, true),
          _webNavIcon(Icons.ondemand_video, false),
          _webNavIcon(Icons.storefront, false),
          const SizedBox(width: 20),
        ],
        _circleButton(Icons.search),
        _circleButton(Icons.chat_bubble),
        if(kIsWeb) _circleButton(Icons.refresh, onTap: _onRefresh),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _webNavIcon(IconData icon, bool isActive) {
    return Container(
      width: 80,
      height: double.infinity,
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Color(0xFF1877F2), width: 3)) : null,
      ),
      child: Icon(icon, color: isActive ? const Color(0xFF1877F2) : Colors.grey[600], size: 28),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(height: 60, margin: const EdgeInsets.all(10), color: Colors.white),
                Container(height: 300, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. FACEBOOK VIDEO CARD (PREVIEW ON HOLD & CLICK TO PLAY)
// ==========================================
class FacebookVideoCard extends StatefulWidget {
  final VideoDataModel videoData;
  final List<String> allVideosList;

  const FacebookVideoCard({
    super.key,
    required this.videoData,
    required this.allVideosList,
  });

  @override
  State<FacebookVideoCard> createState() => _FacebookVideoCardState();
}

class _FacebookVideoCardState extends State<FacebookVideoCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPreviewing = false; // Track preview state

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    String url = widget.videoData.url.replaceFirst("http://", "https://");
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          // Auto-play বন্ধ রাখা হয়েছে, শুধুমাত্র Preview এর সময় চলবে
          _controller?.setLooping(true);
          _controller?.setVolume(0); // Preview মিউট থাকবে (অপশনাল)
        }
      }).catchError((e) {
        debugPrint("Video Error: $e");
      });
  }

  // ✅ Step 1: Preview Logic (Long Press)
  void _startPreview() {
    if (_controller != null && _isInitialized) {
      HapticFeedback.lightImpact(); // হালকা ভাইব্রেশন
      setState(() => _isPreviewing = true);
      _controller?.play();
    }
  }

  void _stopPreview() {
    if (_controller != null && _isInitialized) {
      setState(() => _isPreviewing = false);
      _controller?.pause();
    }
  }

  // ✅ Step 2: Full Screen Logic (Tap)
  void _openFullScreen() {
    // প্রিভিউ বন্ধ করে নতুন পেজে যাওয়া
    _stopPreview();

    Get.to(() => AdWebViewScreen(
      adLink: AdsterraConfigs.monetagHomeLink,
      targetVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videoData;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: kIsWeb ? BorderRadius.circular(8) : null,
        boxShadow: kIsWeb ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))] : null,
      ),
      margin: EdgeInsets.only(bottom: kIsWeb ? 15 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: InkWell(
              onTap: () => Get.to(() => ProfileViewScreen(userData: video)),
              child: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
            ),
            title: InkWell(
              onTap: () => Get.to(() => ProfileViewScreen(userData: video)),
              child: Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            subtitle: Text("${video.timeAgo} · 🌎", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            trailing: const Icon(Icons.more_horiz),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(video.title, style: const TextStyle(fontSize: 15)),
          ),

          const SizedBox(height: 5),

          // ✅ INTERACTIVE VIDEO AREA
          GestureDetector(
            // ১. চেপে ধরলে প্রিভিউ দেখাবে
            onLongPressStart: (_) => _startPreview(),
            onLongPressEnd: (_) => _stopPreview(),

            // ২. ক্লিক করলে নতুন পেজে প্লে হবে
            onTap: _openFullScreen,

            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _isInitialized
                  ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio > 1 ? _controller!.value.aspectRatio : 16/9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),

                    // Preview Indicator / Play Icon
                    if (!_isPreviewing)
                      Container(
                        color: Colors.black12, // সামান্য ডার্ক ওভারলে যখন পজ থাকে
                        child: const Center(
                          child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 60),
                        ),
                      ),

                    // "Hold to Preview" Hint (Optional)
                    if (!_isPreviewing)
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Hold to Preview • Tap to Watch",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              )
                  : const SizedBox(
                  height: 350,
                  child: Center(child: CircularProgressIndicator(color: Colors.white))
              ),
            ),
          ),

          // Footer Actions
          _buildActionFooter(),
        ],
      ),
    );
  }

  Widget _buildActionFooter() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.thumb_up, size: 14, color: Color(0xFF1877F2)),
                SizedBox(width: 4),
                Text("1.2K"),
              ]),
              Text("25 Comments  •  10 Shares", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const Divider(height: 0, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionBtn(Icons.thumb_up_outlined, "Like"),
              _actionBtn(Icons.mode_comment_outlined, "Comment"),
              _actionBtn(Icons.share_outlined, "Share"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey[700], size: 20),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/reels/screens/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:share_plus/share_plus.dart';

// আপনার প্রজেক্ট পাথ ঠিক রাখুন
import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';

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

  // 🔥 Hot & Secret Channel Names
  static final List<String> _girlNames = [
    "Naughty Anika", "Desi Bhabi Vlogs", "Secret Diary", "Dream Girl Rimi",
    "Hot Bella Official", "Misty Night", "Sofia X", "Cute Puja",
    "Viral Leaks", "Midnight Lover", "Sunny Fan Club", "Sweet Taniya",
    "Boudi Diaries", "Romance Hub", "Private Moments", "Lisa Uncut",
    "Zara Private", "Desi Masala", "Night Angel", "Pinky Vlogs",
    "Bedroom Queen", "Late Night Show", "Hot Model Riya", "Desi Dhamaka",
    "Village Viral", "College Crush", "My Private Life", "Exclusive Clips"
  ];

  // 🔥 Title Part 1: The Scene (Location / Person)
  static final List<String> _titleStart = [
    "OMG! My Ex", "Late Night", "Desi Bhabi", "College Hostel", "Bathroom Door",
    "Bedroom Secret", "First Night", "Private Room", "Hidden Cam", "Hot Yoga",
    "Naughty", "Midnight", "Shower Time", "Hotel Room 302", "My Crush",
    "Dirty Truth", "Open Door", "Only Fans", "Step Sister", "Gym Workout",
    "My Landlord", "Neighbor Aunty", "Cute Student", "Office Cabin",
    "Village Girl", "While Husband Sleeping", "Changing Room", "Massage Parlor",
    "Wild Party", "After School", "Tuition Teacher", "Nurse Roleplay",
    "Lonely Housewife", "Swimming Pool", "Car Romance", "Lift Prank",
    "Kitchen Romance", "Rainy Day", "Winter Night", "Summer Heat"
  ];

  // 🔥 Title Part 2: The Action (What Happened - NO DANCE)
  static final List<String> _titleMiddle = [
    "Forgot Camera Was ON 📸", "Leaked Video Viral", "Romance with BF",
    "Changing Clothes 👗", "Towel Slipped 😱", "Video Call Record",
    "Private Moment Caught", "Oil Massage Prank", "Uncut Scene", "Sleeping Alone",
    "Live Stream Mistake", "Sending Nudes?", "Kissing Prank", "Doing It Publicly",
    "Bathtub Fun", "Saree Wardrobe Malfunction", "Shows Everything",
    "Caught by Mom 😱", "Forgot to Lock Door", "Playing with Myself",
    "Trying New Lingerie", "Dirty Talk Audio", "Zoom Meeting Fail",
    "Exposed by BF", "Cleaning Room", "Doing Yoga Steps",
    "Removing Everything", "Transparent Dress", "Wet Saree Look",
    "Making Out in Public", "Secretly Recorded", "Asking for It",
    "Bed Sheet Challenge", "Morning Routine", "Late Night Study"
  ];

  // 🔥 Title Part 3: The Hook (Clickbait Suffix)
  static final List<String> _titleEnd = [
    "🔥 | Too Hot", "❌ | Don't Tell Anyone", "🔞 | 18+ Only", "😱 | Viral Clip",
    "🚫 | Watch Before Delete", "💦 | Satisfaction", "😈 | Very Naughty", "🔒 | Leaked",
    "😍 | Must Watch", "📹 | Full HD", "🍌 | Wild", "🔞 | Headphones Must",
    "🔥 | Agun", "💋 | Romantic", "🥵 | Sweaty", "🤯 | Mind Blowing",
    "🤫 | Secret", "🤐 | No Sound", "👀 | Zoom In", "👄 | ASMR",
    "💣 | Boom", "🙈 | Shameful", "🔥 | Trending #1"
  ];

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();

    return List.generate(count, (index) {
      int id = 64000 + index;

      // 🧠 Smart Logic: 3 Parts Mix
      String dynamicTitle = "${_titleStart[random.nextInt(_titleStart.length)]} "
          "${_titleMiddle[random.nextInt(_titleMiddle.length)]} "
          "${_titleEnd[random.nextInt(_titleEnd.length)]}";

      String dynamicChannel = _girlNames[random.nextInt(_girlNames.length)];

      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: dynamicTitle,
        channelName: dynamicChannel,
        views: "${(random.nextDouble() * 8 + 0.5).toStringAsFixed(1)}M", // 0.5M - 8.5M
        likes: "${random.nextInt(80) + 20}K", // 20K - 99K
        comments: "${random.nextInt(2000) + 500}",
        timeAgo: "${random.nextInt(12) + 1}h",
        duration: "${random.nextInt(15) + 4}:${random.nextInt(50) + 10}",
        profileImage: "https://i.pravatar.cc/150?u=$id",
        subscribers: "${(random.nextDouble() * 5 + 0.5).toStringAsFixed(1)}M",
      );
    });
  }
}



// ==========================================
// 3. MAIN REEL SCREEN (With Shimmer Effect)
// ==========================================
class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  List<VideoDataModel> _allVideos = [];
  bool _isLoading = true; // লোডিং ইন্ডিকেটর

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // ফেক লোডিং ইফেক্ট (প্রথমবার ১ সেকেন্ড)
    await Future.delayed(const Duration(seconds: 1));
    var list = VideoDataHelper.generateVideos(1500);
    list.shuffle();
    if(mounted) {
      setState(() {
        _allVideos = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true); // শিমার শুরু
    await Future.delayed(const Duration(milliseconds: 1500)); // ১.৫ সেকেন্ড লোডিং
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9CCD1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("facebook", style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: -1.2)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble, color: Colors.black), onPressed: () {}),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF1877F2),
        backgroundColor: Colors.white,
        child: _isLoading
            ? _buildShimmerLoading() // 🔥 লোডিং হলে শিমার দেখাবে
            : ListView.builder(
          cacheExtent: 4000,
          physics: const AlwaysScrollableScrollPhysics(),
          addAutomaticKeepAlives: true,
          itemCount: _allVideos.length,
          itemBuilder: (context, index) {
            return FacebookVideoCard(
              key: ValueKey(_allVideos[index].url),
              videoData: _allVideos[index],
              allVideosList: _allVideos.map((e) => e.url).toList(),
            );
          },
        ),
      ),
    );
  }

  // 🔥 SHIMMER EFFECT WIDGET (Facebook Style Skeleton)
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // ৫টা স্কেলিটন কার্ড দেখাবে
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Shimmer
              ListTile(
                leading: _shimmerBox(height: 40, width: 40, isCircle: true),
                title: _shimmerBox(height: 10, width: 100),
                subtitle: _shimmerBox(height: 10, width: 60),
              ),
              // Title Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _shimmerBox(height: 12, width: double.infinity),
              ),
              // Video Box Shimmer
              _shimmerBox(height: 300, width: double.infinity),
              // Footer Shimmer
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(height: 20, width: 80),
                    _shimmerBox(height: 20, width: 80),
                    _shimmerBox(height: 20, width: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // শিমার বক্স বিল্ডার
  Widget _shimmerBox({required double height, required double width, bool isCircle = false}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(4),
      ),
    );
  }
}
// ==========================================
// 4. FACEBOOK VIDEO CARD (FEED ITEM)
// ==========================================
// ==========================================
// 4. FACEBOOK VIDEO CARD (PREMIUM LOADING UI)
// ==========================================
class FacebookVideoCard extends StatefulWidget {
  final VideoDataModel videoData;
  final List<String> allVideosList;
  const FacebookVideoCard({super.key, required this.videoData, required this.allVideosList});

  @override
  State<FacebookVideoCard> createState() => _FacebookVideoCardState();
}

class _FacebookVideoCardState extends State<FacebookVideoCard> with AutomaticKeepAliveClientMixin {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isPreviewing = false;
  double _scale = 1.0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    String cleanUrl = widget.videoData.url.replaceFirst("http://", "https://");

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
    // 🔥 Optimized Agent
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) { if(mounted) setState(() => _isLoading = false); }));

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_webViewController.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController.loadHtmlString(_getFeedHtml(cleanUrl));
  }

  String _getFeedHtml(String url) {
    return '''
      <!DOCTYPE html><html><head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>body{margin:0;background:#000;display:flex;align-items:center;justify-content:center;overflow:hidden;} video{width:100%;height:100%;object-fit:cover;}</style>
      </head><body>
      <video id="v" muted playsinline preload="metadata" src="$url#t=1.5"></video>
      <script>
        var v=document.getElementById("v");
        v.addEventListener('loadedmetadata',function(){this.currentTime=1.5;});
        function startP(){ v.preload="auto"; v.currentTime=0; v.play(); v.playbackRate=2.0; }
        function stopP(){ v.pause(); v.currentTime=1.5; v.preload="metadata"; }
      </script></body></html>
    ''';
  }

  void _onTap() {
    Get.to(() => FullVideoPlayerScreen(
      initialVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ));
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    HapticFeedback.lightImpact();
  }

  void _shareVideo() {
    Share.share("🔥 Check out this viral video: ${widget.videoData.title}\n\nWatch full video here 👇\nhttps://play.google.com/store/apps/details?id=com.hotreels.app");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final video = widget.videoData;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
            title: Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${video.timeAgo} · 🌎"),
            trailing: const Icon(Icons.more_horiz),
            onTap: () => Get.to(() => ProfileViewScreen(videoData: video)),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(video.title, maxLines: 2, style: const TextStyle(fontSize: 15)),
          ),

          // Video Preview Area (With Animation)
          GestureDetector(
            onTap: _onTap,
            onLongPressStart: (_) {
              HapticFeedback.selectionClick();
              setState(() { _isPreviewing = true; _scale = 1.02; });
              _webViewController.runJavaScript('startP();');
            },
            onLongPressEnd: (_) {
              setState(() { _isPreviewing = false; _scale = 1.0; });
              _webViewController.runJavaScript('stopP();');
            },
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 150),
              child: Container(
                height: 350, width: double.infinity, color: const Color(0xFF101010),
                child: Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),

                    Container(color: Colors.transparent), // Touch Blocker

                    // 🔥 PREMIUM LOADING ANIMATION
                    if (_isLoading)
                      Container(
                        color: Colors.black, // কালো ব্যাকগ্রাউন্ডের উপর লোডিং
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // কাস্টম পালসিং আইকন
                              TweenAnimationBuilder(
                                tween: Tween(begin: 0.8, end: 1.2),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.2), size: 60),
                                  );
                                },
                                onEnd: () {}, // লুপের জন্য বা কনটিনিউয়াস রাখার জন্য আলাদা কন্ট্রোলার লাগবে, এখানে সিম্পল রাখা হলো
                              ),
                              const SizedBox(height: 20),
                              // লোডিং টেক্সট বা স্পিনার
                              const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Duration Badge
                    if (!_isPreviewing && !_isLoading)
                      Positioned(bottom: 10, right: 10, child: Container(padding: const EdgeInsets.all(4), color: Colors.black54, child: Text(video.duration, style: const TextStyle(color: Colors.white)))),

                    // Preview Indicator
                    if (_isPreviewing)
                      const Center(child: Text("PREVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(blurRadius: 10, color: Colors.black)]))),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.thumb_up, size: 14, color: Color(0xFF1877F2)),
                  const SizedBox(width: 5),
                  Text(_isLiked ? "You and ${video.likes}" : video.likes, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ]),
                Text("${video.comments} Comments • ${video.views} Views", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                  onPressed: _toggleLike,
                  icon: Icon(_isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt, color: _isLiked ? const Color(0xFF1877F2) : Colors.grey),
                  label: Text("Like", style: TextStyle(color: _isLiked ? const Color(0xFF1877F2) : Colors.grey))
              ),
              TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Comments 💬",
                      content: const Text("Only premium members can comment on this video!"),
                      confirm: ElevatedButton(onPressed: () => Get.back(), child: const Text("OK")),
                    );
                  },
                  icon: const Icon(Icons.comment, color: Colors.grey),
                  label: const Text("Comment", style: TextStyle(color: Colors.grey))
              ),
              TextButton.icon(
                  onPressed: _shareVideo,
                  icon: const Icon(Icons.share, color: Colors.grey),
                  label: const Text("Share", style: TextStyle(color: Colors.grey))
              ),
            ],
          )
        ],
      ),
    );
  }
  @override bool get wantKeepAlive => true;
}

class ProfileViewScreen extends StatelessWidget {
  final VideoDataModel videoData;
  const ProfileViewScreen({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    final List<VideoDataModel> profileVideos = VideoDataHelper.generateVideos(15);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(videoData.channelName, style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back())),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 200, child: Stack(alignment: Alignment.bottomCenter, children: [Container(height: 200, decoration: const BoxDecoration(image: DecorationImage(image: NetworkImage("https://picsum.photos/800/300"), fit: BoxFit.cover))), Positioned(bottom: 0, child: CircleAvatar(radius: 60, backgroundImage: NetworkImage(videoData.profileImage)))])),
            const SizedBox(height: 10),
            Text(videoData.channelName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("${videoData.subscribers} Subscribers", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 15),
            ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: profileVideos.length, itemBuilder: (context, index) => FacebookVideoCard(videoData: profileVideos[index], allVideosList: [])),
          ],
        ),
      ),
    );
  }
}
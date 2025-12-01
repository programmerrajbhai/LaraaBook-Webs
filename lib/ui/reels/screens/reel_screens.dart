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
  static final List<String> _girlNames = [
    "Naughty Anika", "Desi Bhabi", "Sexy Sophia", "Dream Girl Rimi",
    "Hot Bella", "Misty Night", "Sofia X", "Cute Puja",
    "Viral Queen", "Midnight Lover", "Sunny Fan", "Sweet Taniya",
    "Boudi Diaries", "Romance Hub", "Private Moments"
  ];

  static final List<String> _titleStart = [
    "OMG! My Ex", "Late Night", "Desi Bhabi", "College Girl", "Bathroom",
    "Bedroom Secret", "First Night", "Private Room", "Hidden Cam", "Hot Yoga",
    "Naughty", "Midnight", "Shower Time", "Hotel Room", "My Crush"
  ];

  static final List<String> _titleMiddle = [
    "Forgot Camera Was ON 📸", "Leaked Video Viral", "Romance with BF",
    "Changing Clothes 👗", "Towel Slipped 😱", "Video Call Record",
    "Private Moment Caught", "Oil Massage Prank", "Uncut Scene", "Sleeping Alone",
    "Live Stream Mistake", "Sending Nudes?", "Kissing Prank"
  ];

  static final List<String> _titleEnd = [
    "🔥 | Too Hot", "❌ | Don't Tell Anyone", "🔞 | 18+ Only", "😱 | Viral Clip",
    "🚫 | Watch Before Delete", "💦 | Satisfaction", "😈 | Very Naughty", "🔒 | Leaked",
    "😍 | Must Watch"
  ];

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;
      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: "${_titleStart[random.nextInt(_titleStart.length)]} ${_titleMiddle[random.nextInt(_titleMiddle.length)]} ${_titleEnd[random.nextInt(_titleEnd.length)]}",
        channelName: _girlNames[random.nextInt(_girlNames.length)],
        views: "${(random.nextDouble() * 8 + 0.5).toStringAsFixed(1)}M",
        likes: "${random.nextInt(80) + 20}K",
        comments: "${random.nextInt(2000) + 500}",
        timeAgo: "${random.nextInt(12) + 1}h",
        duration: "${random.nextInt(15) + 4}:${random.nextInt(50) + 10}",
        profileImage: "https://i.pravatar.cc/150?u=$id",
        subscribers: "${(random.nextDouble() * 5 + 0.5).toStringAsFixed(1)}M",
      );
    });
  }
}

class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  List<VideoDataModel> _allVideos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    var list = VideoDataHelper.generateVideos(1500);
    list.shuffle();
    setState(() => _allVideos = list);
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
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
        child: ListView.builder(
          cacheExtent: 5000, // আরও বেশি প্রি-লোড করবে
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
}

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
    // 🔥 Optimized Agent for Speed
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) { if(mounted) setState(() => _isLoading = false); }));

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_webViewController.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController.loadHtmlString(_getFeedHtml(cleanUrl));
  }

  // 🔥 Feed Optimization Engine
  String _getFeedHtml(String url) {
    return '''
      <!DOCTYPE html><html><head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>body{margin:0;background:#000;display:flex;align-items:center;justify-content:center;overflow:hidden;} video{width:100%;height:100%;object-fit:cover;}</style>
      </head><body>
      <video id="v" muted playsinline preload="metadata" src="$url#t=1.5"></video>
      <script>
        var v=document.getElementById("v");
        // ফাস্ট লোডিং এর জন্য মেটাডেটা লোড হলেই ফ্রেম সেট করবে
        v.addEventListener('loadedmetadata',function(){this.currentTime=1.5;});
        
        function startP(){ 
           v.preload="auto"; // প্রিভিউ শুরু হলে অটো লোড অন হবে
           v.currentTime=0; 
           v.play(); 
           v.playbackRate=2.0; // ফাস্ট প্রিভিউ
        } 
        function stopP(){ 
           v.pause(); 
           v.currentTime=1.5; 
           v.preload="metadata"; // ডাটা সেভ করার জন্য আবার মেটাডেটা মোডে
        }
      </script></body></html>
    ''';
  }

  void _onTap() {
    Get.to(() => FullVideoPlayerScreen(
      initialVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ));
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
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
            title: Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${video.timeAgo} · 🌎"),
            trailing: const Icon(Icons.more_horiz),
            onTap: () => Get.to(() => ProfileViewScreen(videoData: video)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(video.title, maxLines: 2, style: const TextStyle(fontSize: 15)),
          ),
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
                    Container(color: Colors.transparent),
                    if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white24)),
                    if (!_isPreviewing && !_isLoading)
                      Positioned(bottom: 10, right: 10, child: Container(padding: const EdgeInsets.all(4), color: Colors.black54, child: Text(video.duration, style: const TextStyle(color: Colors.white)))),
                    if (_isPreviewing)
                      const Center(child: Text("PREVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(blurRadius: 10, color: Colors.black)]))),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(onPressed: (){ setState(()=>_isLiked=!_isLiked); }, icon: Icon(_isLiked?Icons.thumb_up:Icons.thumb_up_off_alt, color: _isLiked?Colors.blue:Colors.grey), label: Text("Like")),
              TextButton.icon(onPressed: (){}, icon: const Icon(Icons.comment, color: Colors.grey), label: const Text("Comment", style: TextStyle(color: Colors.grey))),
              TextButton.icon(onPressed: (){}, icon: const Icon(Icons.share, color: Colors.grey), label: const Text("Share", style: TextStyle(color: Colors.grey))),
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
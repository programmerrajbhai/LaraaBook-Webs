import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';

class FullVideoPlayerScreen extends StatefulWidget {
  final String initialVideoUrl;
  final List<String> allVideos;

  const FullVideoPlayerScreen({
    super.key,
    required this.initialVideoUrl,
    required this.allVideos, required String adLink,
  });

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _showRecommendations = false;

  // লজিক ভেরিয়েবল
  Timer? _progressTimer;
  bool _hasShownAt30s = false; // ৩০ সেকেন্ডে একবার দেখানো হয়েছে কিনা
  double _currentVideoDuration = 0.0;

  @override
  void initState() {
    super.initState();
    // পোর্ট্রেট মোড ফিক্সড রাখা
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _initializeWebView(widget.initialVideoUrl);
  }

  void _initializeWebView(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
              // ভিডিও লোড হলে টাইমার চালু হবে যা প্রতি ১ সেকেন্ডে চেক করবে
              _startProgressChecker();
            }
          },
        ),
      );

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false); // ডিবাগ অফ (ফাস্ট লোডিংয়ের জন্য)
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController.loadHtmlString(_getVideoHtml(url));
  }

  // জাভাস্ক্রিপ্ট দিয়ে ভিডিওর টাইম চেক করা
  void _startProgressChecker() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        // ১. বর্তমান সময় নেওয়া (Current Time)
        final currentTimeStr = await _webViewController.runJavaScriptReturningResult(
            "document.getElementById('myVideo').currentTime");
        // ২. মোট সময় নেওয়া (Duration)
        final durationStr = await _webViewController.runJavaScriptReturningResult(
            "document.getElementById('myVideo').duration");

        double currentTime = double.tryParse(currentTimeStr.toString()) ?? 0.0;
        double duration = double.tryParse(durationStr.toString()) ?? 0.0;

        _currentVideoDuration = duration;

        // --- লজিক ১: ৩০ সেকেন্ড পার হলে ---
        if (currentTime > 30 && !_hasShownAt30s && !_showRecommendations) {
          setState(() {
            _showRecommendations = true;
            _hasShownAt30s = true; // ফ্ল্যাগ সেট করা যাতে বারবার ওপেন না হয়
          });
        }

        // --- লজিক ২: শেষ ১০ সেকেন্ড বাকি থাকলে ---
        if (duration > 0 && (duration - currentTime) <= 10 && !_showRecommendations) {
          // যদি ইউজার ম্যানুয়ালি বন্ধ না করে থাকে, তবে আবার দেখাও
          if(currentTime > (duration - 9)) { // একদম শেষের দিকে জাস্ট একবার ট্রিগার
            setState(() {
              _showRecommendations = true;
            });
          }
        }

      } catch (e) {
        // ভিডিও লোড না হলে ইগনোর করবে
      }
    });
  }

  String _getVideoHtml(String url) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { margin: 0; background-color: black; height: 100vh; display: flex; align-items: center; justify-content: center; }
          video { width: 100%; height: 100%; object-fit: contain; }
          /* ডিফল্ট প্লেয়ার কন্ট্রোল স্টাইল */
          video::-webkit-media-controls-panel { background-image: linear-gradient(transparent, rgba(0,0,0,0.5)); }
        </style>
      </head>
      <body>
        <video id="myVideo" controls autoplay playsinline name="media">
          <source src="$url" type="video/mp4">
        </video>
      </body>
      </html>
    ''';
  }

  void _playSuggestedVideo(String url) {
    _progressTimer?.cancel(); // আগের টাইমার বন্ধ
    Get.off(() => AdWebViewScreen(
      adLink: AdsterraConfigs.monetagPlayerLink,
      targetVideoUrl: url,
      allVideos: widget.allVideos,
    ));
  }

  void _onBackPress() {
    _progressTimer?.cancel();
    Get.back();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = widget.allVideos
        .where((url) => url != widget.initialVideoUrl)
        .toList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Video Player Layer
              Center(
                child: WebViewWidget(controller: _webViewController),
              ),

              // 2. Loading Indicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.red)),

              // 3. Control Buttons (Back & Playlist)
              Positioned(
                top: 10,
                left: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _onBackPress,
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                        _showRecommendations ? Icons.close : Icons.playlist_play,
                        color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showRecommendations = !_showRecommendations;
                      });
                    },
                  ),
                ),
              ),

              // 4. Recommendations Sidebar (Animated)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: _showRecommendations ? 0 : -220, // স্লাইড ইফেক্ট
                top: 60,
                bottom: 20,
                width: 200,
                child: Container(
                  margin: const EdgeInsets.only(right: 5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85), // একটু স্বচ্ছ
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15)
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Up Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            // ছোট টাইমার দেখা যেতে পারে যদি দরকার হয়
                            if(_currentVideoDuration > 0)
                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 14)
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            final url = suggestions[index];
                            return GestureDetector(
                              onTap: () => _playSuggestedVideo(url),
                              child: Container(
                                height: 100,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                  color: Colors.grey[900],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // সুপার ফাস্ট থাম্বনেইল উইজেট
                                      _OptimizedWebViewThumbnail(videoUrl: url),

                                      // প্লে আইকন
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// অপ্টিমাইজড থাম্বনেইল ক্লাস (ন্যানো সেকেন্ড স্পিড ফিল দেওয়ার জন্য)
// -----------------------------------------------------------------------------
class _OptimizedWebViewThumbnail extends StatefulWidget {
  final String videoUrl;
  const _OptimizedWebViewThumbnail({required this.videoUrl});

  @override
  State<_OptimizedWebViewThumbnail> createState() => _OptimizedWebViewThumbnailState();
}

class _OptimizedWebViewThumbnailState extends State<_OptimizedWebViewThumbnail> with AutomaticKeepAliveClientMixin {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black); // লোড হওয়ার আগে কালো দেখাবে

    // এখানে HTML কোডটিকে মিনিফাই করা হয়েছে যাতে দ্রুত লোড হয়
    _controller.loadHtmlString('''
        <html><body style="margin:0;background:#000;overflow:hidden;display:flex;align-items:center;justify-content:center;">
        <video muted playsinline preload="metadata" style="width:100%;height:100%;object-fit:cover;">
        <source src="${widget.videoUrl}" type="video/mp4"></video>
        <script>
        var v=document.querySelector('video');
        v.addEventListener('loadedmetadata',function(){this.currentTime=0.5;}); // 0.1 এর বদলে 0.5 দিলে ফ্রেম ভালো আসে
        </script></body></html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox.expand(
      child: AbsorbPointer(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // লিস্ট স্ক্রল করলেও লোডেড থাকবে
}
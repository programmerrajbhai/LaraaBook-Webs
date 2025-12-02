import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/adsterra/adsterra_configs.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Android ফিচার ব্যবহারের জন্য
import 'package:webview_flutter_android/webview_flutter_android.dart';
// আপনি ভিডিও প্লেয়ারের পাথ আপনার প্রোজেক্ট অনুযায়ী ঠিক রাখুন
import 'package:meetyarah/ui/reels/screens/video_player.dart';

class AdWebViewScreen extends StatefulWidget {
  final String adLink;
  final String targetVideoUrl;
  final List<String> allVideos;

  const AdWebViewScreen({
    super.key,
    required this.adLink,
    required this.targetVideoUrl,
    required this.allVideos,
  });

  @override
  State<AdWebViewScreen> createState() => _AdWebViewScreenState();
}

class _AdWebViewScreenState extends State<AdWebViewScreen> {
  late final WebViewController _controller;
  int _countdown = 5;
  bool _canSkip = false;
  Timer? _timer;

  bool _isLoading = true;
  bool _isAdHidden = false; // রিডাইরেক্ট ব্লক হলে এটি ট্রু হবে

  // ✅ লেটেস্ট ক্রোম ইউজার এজেন্ট (Real Device Feel)
  final String _userAgent =
      "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeWebView();
  }

  void _initializeWebView() {
    // ১. কন্ট্রোলার সেটআপ
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        Colors.transparent,
      ) // ✅ ব্যাকগ্রাউন্ড স্বচ্ছ রাখলাম যাতে পেছনের 'Sponsored' লেখা দেখা যায়
      ..setUserAgent(_userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            // এরর হলেও আমরা চেষ্টা চালিয়ে যাব, ইউজার যাতে আটকে না যায়
            debugPrint("WebView Error: ${error.description}");
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            // 🔥 প্লে-স্টোর বা অ্যাপ রিডাইরেক্ট ব্লক করা
            bool isStoreRedirect =
                url.startsWith('market://') ||
                url.startsWith('intent://') ||
                url.contains('play.google.com') ||
                url.startsWith('itms-appss://') ||
                url.startsWith('deep_link');

            if (isStoreRedirect) {
              debugPrint("Blocked Auto-Redirect: $url");
              // আমরা রিডাইরেক্ট ব্লক করব এবং 'Sponsored' ব্যাকগ্রাউন্ড দেখাব
              if (mounted) {
                setState(() {
                  _isAdHidden = true;
                  _isLoading = false;
                });
              }
              return NavigationDecision.prevent;
            }

            // ইউটিউব ব্লক
            if (url.contains('youtube.com') || url.contains('youtu.be')) {
              if (mounted) setState(() => _isAdHidden = true);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    // 🔥 Android স্পেসিফিক সেটিংস (স্ট্যান্ডার্ড API) 🔥
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController androidController =
          controller.platform as AndroidWebViewController;
      // ভিডিও বা সাউন্ড অটো প্লে হওয়ার জন্য
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // নোট: setSupportMultipleWindows বা setLoadWithOverviewMode মেথডগুলো
      // স্ট্যান্ডার্ড প্যাকেজে সরাসরি নেই বা কাজ করছে না, তাই সেগুলো বাদ দেওয়া হয়েছে।
      // ডিফল্ট সেটিংসেই Monetag ভালো কাজ করবে যদি UserAgent সঠিক থাকে।
    }

    _controller = controller;

    // ক্যাশ ক্লিয়ার এবং রিকোয়েস্ট লোড
    _controller.clearCache();
    _controller.loadRequest(Uri.parse(widget.adLink));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canSkip = true);
        _timer?.cancel();
      }
    });
  }

  void _skipAdAndPlayVideo() {
    _timer?.cancel();
    Get.off(
      () => FullVideoPlayerScreen(
        initialVideoUrl: widget.targetVideoUrl,
        allVideos: widget.allVideos,
        adLink: AdsterraConfigs.monetagHomeLink,
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (_canSkip) _skipAdAndPlayVideo();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Fallback Background (SPONSORED)
              // যদি অ্যাড ব্লক হয় বা লোড না হয়, এটি দেখা যাবে
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 60,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "SPONSORED ADVERTISEMENT",
                      style: TextStyle(
                        color: Colors.white24,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your video will play shortly...",
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 2. WebView (Ad Layer)
              // অ্যাড হাইড না হলে এটি দেখাবে
              if (!_isAdHidden) WebViewWidget(controller: _controller),

              // 3. Loading Indicator
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),

              // 4. Timer & Skip Button (Always on Top)
              Positioned(
                top: 15,
                right: 15,
                child: GestureDetector(
                  onTap: _canSkip ? _skipAdAndPlayVideo : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _canSkip ? Colors.greenAccent : Colors.white24,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_canSkip)
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              value: (5 - _countdown) / 5,
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _canSkip ? "Skip Ad ▶" : "Skip in $_countdown",
                          style: TextStyle(
                            color: _canSkip ? Colors.greenAccent : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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

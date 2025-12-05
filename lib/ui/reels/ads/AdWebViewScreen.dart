import 'dart:async';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
// মোবাইল স্পেসিফিক ইম্পোর্ট
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../screens/video_player.dart';


class AdWebViewScreen extends StatefulWidget {
  final String adLink;
  final String targetVideoUrl;
  final List<String> allVideos;

  const AdWebViewScreen({
    super.key,
    required this.adLink,
    required this.targetVideoUrl,
    required this.allVideos
  });

  @override
  State<AdWebViewScreen> createState() => _AdWebViewScreenState();
}

class _AdWebViewScreenState extends State<AdWebViewScreen> {
  late final WebViewController _controller;
  int _countdown = 5;
  bool _canSkip = false;
  Timer? _timer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initWebView();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;

    // ১. প্ল্যাটফর্ম চেক
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    // ২. শুধুমাত্র মোবাইল অ্যাপের জন্য সেটিংস (ওয়েবে ক্র্যাশ এড়াতে)
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.setBackgroundColor(Colors.black);

      _controller.setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            // এরর হলে অটো স্কিপ (Web Crash Prevent)
            if(mounted && !_isNavigating) _skipAd();
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      );
    }

    _controller.loadRequest(Uri.parse(widget.adLink));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canSkip = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _skipAd() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    _timer?.cancel();

    // ভিডিও প্লেয়ারে রিডাইরেক্ট
    Get.off(() => FullVideoPlayerScreen(
      initialVideoUrl: widget.targetVideoUrl,
      allVideos: widget.allVideos,
      adLink: "",
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ব্যাক বাটন ডিজেবল
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          // ✅ Stack এর বদলে Column (আপনার কোড অনুযায়ী)
          child: Column(
            children: [
              // ✅ Top Bar
              Container(
                height: 60,
                color: const Color(0xFF1E1E1E),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sponsored Ad",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),

                    // ✅ Skip Button
                    InkWell(
                      onTap: _canSkip ? _skipAd : null,
                      borderRadius: BorderRadius.circular(20),
                      hoverColor: Colors.white.withOpacity(0.1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: _canSkip ? const Color(0xFFE50914) : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _canSkip ? Colors.transparent : Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _canSkip ? "Skip Ad" : "Wait $_countdown s",
                              style: TextStyle(
                                color: _canSkip ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_canSkip) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.skip_next, color: Colors.white, size: 18),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ WebView (Remaining Area)
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
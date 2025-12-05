import 'dart:async';
import 'package:flutter/foundation.dart'; // kIsWeb এর জন্য
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
// মোবাইল স্পেসিফিক ইম্পোর্ট
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class FullVideoPlayerScreen extends StatefulWidget {
  final String initialVideoUrl;
  final List<String> allVideos;
  final String adLink;

  const FullVideoPlayerScreen({
    super.key,
    required this.initialVideoUrl,
    required this.allVideos,
    required this.adLink,
  });

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;

    // ১. প্ল্যাটফর্ম চেক
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    // ২. শুধুমাত্র মোবাইল অ্যাপের জন্য সেটিংস
    if (!kIsWeb) {
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.setBackgroundColor(Colors.black);

      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint("Web Error: ${error.description}");
          },
        ),
      );

      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(false);
        (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
      }
    } else {
      // ওয়েবের জন্য ম্যানুয়াল লোডিং হ্যান্ডেল
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }

    controller.loadHtmlString(_getVideoHtml(widget.initialVideoUrl));
    _webViewController = controller;
  }

  // HTML Generator
  String _getVideoHtml(String url) {
    String cleanUrl = url.replaceFirst("http://", "https://");

    // ওয়েবে 'muted' ছাড়া অটোপ্লে কাজ করে না
    String autoPlaySettings = kIsWeb
        ? 'autoplay muted playsinline controls'
        : 'autoplay playsinline controls';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; background-color: black; height: 100vh; display: flex; align-items: center; justify-content: center; overflow: hidden; }
          video { width: 100%; height: 100%; object-fit: contain; }
        </style>
      </head>
      <body>
        <video id="player" $autoPlaySettings name="media">
          <source src="$cleanUrl" type="video/mp4">
          Your browser does not support the video tag.
        </video>
        <script>
           var video = document.getElementById("player");
           var promise = video.play();
           if (promise !== undefined) {
             promise.catch(function(error) {
               console.log("Autoplay prevented: " + error);
             });
           }
        </script>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text("Watching", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../adsterra_configs.dart'; // আপনার কনফিগ ফাইল ইম্পোর্ট করুন
import '../controller/adsterra_controller.dart'; // আপনার কন্ট্রোলার ফাইল ইম্পোর্ট করুন

enum AdType { banner300, banner728, socialBar, native }

class SimpleAdWidget extends StatefulWidget {
  final AdType type;

  const SimpleAdWidget({super.key, required this.type});

  @override
  State<SimpleAdWidget> createState() => _SimpleAdWidgetState();
}

class _SimpleAdWidgetState extends State<SimpleAdWidget> {
  late final WebViewController _controller;
  double height = 0;
  double width = 0;

  final adController = Get.put(AdsterraController());
  final String myWebsiteUrl = "https://laraabook.com";

  @override
  void initState() {
    super.initState();
    _setupAd();
  }

  void _setupAd() {
    String adCode = "";

    switch (widget.type) {
      case AdType.banner300:
        adCode = AdsterraConfigs.html300x250;
        height = 270;
        width = 320;
        break;
      case AdType.banner728:
        adCode = AdsterraConfigs.html728x90;
        height = 100;
        width = 360;
        break;
      case AdType.socialBar:
        adCode = AdsterraConfigs.htmlSocialBar;
        height = 1;
        width = 1;
        break;
      case AdType.native:
        adCode = AdsterraConfigs.htmlNative;
        height = 160;
        width = 320;
        break;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // এডে ক্লিক করলে এক্সটারনাল ব্রাউজারে ওপেন হবে
            if (request.url.startsWith("http")) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
        """
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { margin:0; padding:0; display:flex; justify-content:center; align-items:center; background-color: transparent; }
            </style>
          </head>
          <body>
            $adCode
          </body>
        </html>
        """,
        baseUrl: myWebsiteUrl,
      );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == AdType.socialBar) {
      // Social Bar ব্যাকগ্রাউন্ডে লোড হবে এবং স্ক্রিনে পপআপ আসবে
      return SizedBox(height: 1, width: 1, child: WebViewWidget(controller: _controller));
    }

    if (widget.type == AdType.native) {
      return _buildNativePostWrapper();
    }

    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: WebViewWidget(controller: _controller),
    );
  }

  // ✅ High CTR Native Ad Design
  Widget _buildNativePostWrapper() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sponsored", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Suggested for you", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),

          // Ad Body
          Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[50],
            child: WebViewWidget(controller: _controller),
          ),

          // ✅ "See More" Trick for Clicks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: InkWell(
              onTap: () => adController.openSmartLink(),
              child: const Text(
                "See More...",
                style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const Divider(height: 1),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fakeActionButton(Icons.favorite_border, "Like"),
                _fakeActionButton(Icons.comment_outlined, "Comment"),
                _fakeActionButton(Icons.share, "Share"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        adController.openSmartLink();
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
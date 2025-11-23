import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/image_url.dart'; // আপনার ইমেজের পাথ
import '../controllers/splash_controllers.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার কানেক্ট করা হলো
    Get.put(SplashController());

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // আপনার লোগো
            Image.asset(
              ImagePath.appLogotransparent,
              width: Get.width * 0.6,
            ),
            const SizedBox(height: 20),
            // একটি লোডিং ইন্ডিকেটর (অপশনাল)
            const CircularProgressIndicator(
              color: Colors.indigoAccent,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/reel_screens.dart';

class ProfileViewScreen extends StatelessWidget {
  final VideoDataModel videoData;
  const ProfileViewScreen({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    final List<VideoDataModel> profileVideos = VideoDataHelper.generateVideos(20);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(videoData.channelName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Photo
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 220,
                    margin: const EdgeInsets.only(bottom: 50),
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: NetworkImage("https://picsum.photos/800/400"), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundImage: NetworkImage(videoData.profileImage),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(videoData.channelName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text("${videoData.subscribers} Subscribers", style: TextStyle(color: Colors.grey[600])),

            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1877F2)), child: const Text("Follow", style: TextStyle(color: Colors.white)))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]), child: const Text("Message", style: TextStyle(color: Colors.black)))),
                ],
              ),
            ),
            const Divider(thickness: 5, color: Color(0xFFF0F2F5)),

            // Post List Reuse
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profileVideos.length,
              itemBuilder: (context, index) {
                return FacebookVideoCard(videoData: profileVideos[index], allVideosList: [],);
              },
            ),
          ],
        ),
      ),
    );
  }
}
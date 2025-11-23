import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/Like_Comment_Share.dart';

class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});

  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {



  final List<String> videoPaths = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
  ];

  late List<VideoPlayerController> _controllers;

  @override
  void initState() {
    videoPaths.shuffle();

    _controllers =
        videoPaths.map((path) {
          final controller =
          VideoPlayerController.network(path)
            ..setLooping(true)
            ..initialize().then((_) {
              setState(() {});
            });
          return controller;
        }).toList();


    // প্রথম ভিডিও প্লে করা
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_controllers.isNotEmpty) {
        final firstController = _controllers[4];
        await firstController.initialize(); // wait for ready
        firstController.play();
        setState(() {}); // ensure rebuild
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _pauseAllExcept(int playingIndex) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == playingIndex) {
        _controllers[i].play();
      } else {
        _controllers[i].pause();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _controllers.length,
        onPageChanged: (index) {
          _pauseAllExcept(index);
        },
        itemBuilder: (context, index) {
          final controller = _controllers[index];
          if (controller.value.isInitialized) {
            return GestureDetector(
              onTap: () {
                _togglePause(index); // Toggle play/pause on tap
              },
              child: Stack(
                children: [
                  // Video Player
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),

                  Like_Comment_Share(),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),

    );



  }

  // Function to toggle play/pause when tapped
  void _togglePause(int index) {
    final controller = _controllers[index];
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';

class FullVideoPlayerScreen extends StatefulWidget {
  final String initialVideoUrl;
  final List<String> allVideos;

  const FullVideoPlayerScreen({
    super.key,
    required this.initialVideoUrl,
    required this.allVideos,
  });

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isDragging = false;
  double _sliderValue = 0.0;
  bool _isFullScreen = false;
  bool _showRecommendations = false;
  late String _currentVideoUrl;

  @override
  void initState() {
    super.initState();
    _currentVideoUrl = widget.initialVideoUrl;
    _initializePlayer(_currentVideoUrl);
  }

  Future<void> _initializePlayer(String url) async {
    if (_isInitialized) await _controller.dispose();

    setState(() {
      _isInitialized = false;
      _showRecommendations = false;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _controller.play();
      });
    }

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!mounted || _isDragging) return;
    final duration = _controller.value.duration;
    final position = _controller.value.position;
    final remaining = duration - position;
    final showRec = remaining.inSeconds <= 15 && duration.inSeconds > 0;

    if (showRec != _showRecommendations) {
      setState(() => _showRecommendations = showRec);
    }
    if (position.inSeconds != _sliderValue.toInt()) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _onBackPress() {
    if (_isFullScreen) {
      _toggleFullScreen();
    } else {
      Get.back();
    }
  }

  // ✅ সাজেশন ক্লিক লজিক
  void _playSuggestedVideo(String url) {
    _controller.pause();
    Get.to(
      () => AdWebViewScreen(
        adLink: AdsterraConfigs.monetagPlayerLink, // Player Link
        targetVideoUrl: url,
        allVideos: widget.allVideos,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final duration = _isInitialized
        ? _controller.value.duration.inMilliseconds.toDouble()
        : 0.0;
    final position = _isInitialized
        ? _controller.value.position.inMilliseconds.toDouble()
        : 0.0;

    return PopScope(
      canPop: !_isFullScreen,
      onPopInvoked: (didPop) {
        if (_isFullScreen) _toggleFullScreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _isInitialized
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => _showControls = !_showControls),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InteractiveViewer(
                              panEnabled: false,
                              minScale: 1.0,
                              maxScale: 4.0,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                              ),
                            ),
                            if (_showControls)
                              _buildControls(duration, position),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),
              if (_showRecommendations) _buildRecommendationOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(double duration, double position) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: _onBackPress,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  final pos = _controller.value.position;
                  _controller.seekTo(pos - const Duration(seconds: 10));
                },
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_controller.value.position >=
                      _controller.value.duration) {
                    _controller.seekTo(Duration.zero);
                    _controller.play();
                  } else {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  }
                },
                icon: Icon(
                  _controller.value.position >= _controller.value.duration
                      ? Icons.replay
                      : (_controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                  color: Colors.white,
                  size: 50,
                ),
              ),
              IconButton(
                onPressed: () {
                  final pos = _controller.value.position;
                  _controller.seekTo(pos + const Duration(seconds: 10));
                },
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.white24,
                    trackHeight: 4.0,
                    thumbColor: Colors.red,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16.0,
                    ),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: duration,
                    value: _isDragging
                        ? _sliderValue
                        : position.clamp(0.0, duration),
                    onChanged: (value) => setState(() {
                      _isDragging = true;
                      _sliderValue = value;
                    }),
                    onChangeEnd: (value) {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                      setState(() => _isDragging = false);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleFullScreen,
                      icon: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationOverlay() {
    final suggestions = widget.allVideos
        .where((url) => url != _currentVideoUrl)
        .toList();
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: 60,
      bottom: 100,
      width: 170,
      child: AnimatedOpacity(
        opacity: _showRecommendations ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  "Up Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                          color: Colors.grey[900],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _SimpleThumbnail(videoUrl: url),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
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
    );
  }
}

class _SimpleThumbnail extends StatefulWidget {
  final String videoUrl;
  const _SimpleThumbnail({required this.videoUrl});

  @override
  State<_SimpleThumbnail> createState() => _SimpleThumbnailState();
}

class _SimpleThumbnailState extends State<_SimpleThumbnail>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _thumbController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _thumbController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..setVolume(0.0)
          ..initialize().then((_) {
            if (mounted) {
              setState(() => _loaded = true);
              _thumbController.seekTo(const Duration(milliseconds: 100));
              _thumbController.pause();
            }
          });
  }

  @override
  void dispose() {
    _thumbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.black,
      child: _loaded
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _thumbController.value.size.width,
                  height: _thumbController.value.size.height,
                  child: VideoPlayer(_thumbController),
                ),
              ),
            )
          : const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white30,
                  strokeWidth: 2,
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

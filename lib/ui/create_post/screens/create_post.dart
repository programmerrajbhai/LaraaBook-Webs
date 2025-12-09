import 'dart:io' as io; // ✅ Prefix যোগ করা হয়েছে যাতে কনফ্লিক্ট না হয়
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/ui/create_post/controllers/create_post_controller.dart';
import '../../login_reg_screens/controllers/auth_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController createdPostController = Get.put(CreatePostController());
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _mediaFiles = [];
  bool _isPostButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    createdPostController.postTitleCtrl.addListener(_updatePostButtonState);
  }

  void _updatePostButtonState() {
    setState(() {
      _isPostButtonEnabled = createdPostController.postTitleCtrl.text.isNotEmpty || _mediaFiles.isNotEmpty;
    });
  }

  // --- Submit Post ---
  void _submitPost() {
    if (!_isPostButtonEnabled) return;
    FocusScope.of(context).unfocus();
    createdPostController.createPost(images: _mediaFiles);
  }

  // --- Pick Image ---
  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(images);
        _updatePostButtonState();
      });
    }
  }

  // --- Pick Video ---
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _mediaFiles.add(video);
        _updatePostButtonState();
      });
    }
  }

  // ✅ Remove Image
  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
      _updatePostButtonState();
    });
  }

  // ✅ Back Button Fixed
  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: Desktop Center View
          if (constraints.maxWidth > 800) {
            return Center(
              child: Container(
                width: 600,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: _buildBody(),
              ),
            );
          }
          return _buildBody();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black87),
        onPressed: _handleBack,
      ),
      title: const Text("Create Post", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ElevatedButton(
            onPressed: _isPostButtonEnabled ? _submitPost : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              disabledBackgroundColor: Colors.blueAccent.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildUserInfoSection(),
                _buildCaptionInput(),
                if (_mediaFiles.isNotEmpty) _buildMediaGrid(),
                const Divider(),
                _buildOptionsList(),
              ],
            ),
          ),
        ),
        _buildBottomMediaBar(),
        Obx(() => createdPostController.isLoading.value ? const LinearProgressIndicator() : const SizedBox.shrink()),
      ],
    );
  }

  // ✅ SAFE IMAGE WIDGET
  Widget _buildImageWidget(XFile file) {
    if (file.path.toLowerCase().endsWith('.mp4') || file.path.toLowerCase().endsWith('.mov')) {
      return Container(color: Colors.black, child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 50)));
    }

    // ✅ Web এ Network Image ব্যবহার হবে
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.cover);
    } else {
      // ✅ Mobile এ File Image ব্যবহার হবে
      return Image.file(io.File(file.path), fit: BoxFit.cover);
    }
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemCount: _mediaFiles.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(_mediaFiles[index]),
            Positioned(
              top: 5, right: 5,
              child: GestureDetector(
                onTap: () => _removeMedia(index),
                child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        final user = _authService.user.value;
        return Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.grey[200], backgroundImage: NetworkImage(user?.profile_picture_url ?? "https://cdn-icons-png.flaticon.com/512/149/149071.png")),
            const SizedBox(width: 10),
            Text(user?.full_name ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        );
      }),
    );
  }

  Widget _buildCaptionInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: createdPostController.postTitleCtrl,
        maxLines: null,
        decoration: const InputDecoration(hintText: "What's on your mind?", border: InputBorder.none, hintStyle: TextStyle(fontSize: 18, color: Colors.grey)),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(children: [
      ListTile(leading: const Icon(Icons.location_on, color: Colors.red), title: const Text("Add Location"), trailing: const Icon(Icons.chevron_right)),
    ]);
  }

  Widget _buildBottomMediaBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(children: [
        const Text("Add to your post", style: TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.photo_library, color: Colors.green), onPressed: _pickImage),
        IconButton(icon: const Icon(Icons.videocam, color: Colors.redAccent), onPressed: _pickVideo),
      ]),
    );
  }
}
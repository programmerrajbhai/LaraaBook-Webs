import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/ui/create_post/controllers/create_post_controller.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController createdPostController = Get.put(CreatePostController());
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
      _isPostButtonEnabled =
          createdPostController.postTitleCtrl.text.isNotEmpty || _mediaFiles.isNotEmpty;
    });
  }

  @override
  void dispose() {
    createdPostController.postTitleCtrl.removeListener(_updatePostButtonState);
    super.dispose();
  }

  // --- মিডিয়া সিলেকশন ---
  void _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(images);
        _updatePostButtonState();
      });
    }
  }

  void _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _mediaFiles.add(video);
        _updatePostButtonState();
      });
    }
  }

  // --- পোস্ট সাবমিট ---
  void _submitPost() {
    FocusScope.of(context).unfocus();
    createdPostController.createPost(images: _mediaFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- ১. অ্যাপ বার (ইনস্টাগ্রাম স্টাইল) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _isPostButtonEnabled ? _submitPost : null,
            child: Text(
              "Share",
              style: TextStyle(
                color: _isPostButtonEnabled ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- ২. ক্যাপশন এরিয়া ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ইউজার অবতার (স্ট্যাটিক বা ডাইনামিক)
                            const CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              backgroundColor: Colors.grey,
                            ),
                            const SizedBox(width: 12),

                            // ইনপুট ফিল্ড
                            Expanded(
                              child: TextField(
                                controller: createdPostController.postTitleCtrl,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "Write a caption...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1, thickness: 0.5),

                      // --- ৩. প্রিভিউ সেকশন (ছবি/ভিডিও) ---
                      if (_mediaFiles.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 350),
                          width: double.infinity,
                          child: _mediaFiles.length == 1
                              ? Image.file(File(_mediaFiles.first.path), fit: BoxFit.cover)
                              : GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 1,
                            ),
                            itemCount: _mediaFiles.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(File(_mediaFiles[index].path), fit: BoxFit.cover),
                                  Positioned(
                                      right: 2, top: 2,
                                      child: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              _mediaFiles.removeAt(index);
                                              _updatePostButtonState();
                                            });
                                          },
                                          child: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.black54,
                                              child: Icon(Icons.close, size: 12, color: Colors.white)
                                          )
                                      )
                                  )
                                ],
                              );
                            },
                          ),
                        ),

                      if (_mediaFiles.isNotEmpty) const Divider(height: 1, thickness: 0.5),

                      // --- ৪. অপশনস লিস্ট ---
                      _buildOptionTile(Icons.location_on_outlined, "Add Location"),
                      const Divider(height: 1, indent: 50),
                      _buildOptionTile(Icons.person_outline, "Tag People"),
                      const Divider(height: 1, indent: 50),
                      _buildOptionTile(Icons.music_note_outlined, "Add Music"),
                      const Divider(height: 1, indent: 50),
                      _buildOptionTile(Icons.settings, "Advanced Settings"),
                      const SizedBox(height: 100), // নিচ পর্যন্ত স্ক্রল করার জন্য জায়গা
                    ],
                  ),
                ),
              ),

              // --- ৫. বটম বার (মিডিয়া অ্যাড করার জন্য) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))]
                ),
                child: Row(
                  children: [
                    const Text("Add to your post", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.green),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.redAccent),
                      onPressed: _pickVideo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                      onPressed: _pickImage, // ক্যামেরা লজিক এখানে দেওয়া যাবে
                    ),
                  ],
                ),
              ),
            ],
          ),

          // লোডিং ইন্ডিকেটর
          Obx(() => createdPostController.isLoading.value
              ? Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator())
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () {},
      dense: true,
    );
  }
}
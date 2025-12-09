import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/profile/screens/profile_screens.dart';
import '../../login_reg_screens/controllers/auth_service.dart';
import '../../profile/controllers/profile_controllers.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({Key? key}) : super(key: key);

  final AuthService authService = Get.find<AuthService>();
  // কন্ট্রোলার ইনিশিলাইজ (যদি আগে না হয়ে থাকে)
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Facebook Style Background
      appBar: AppBar(
        title: Text(
            'Menu',
            style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Web Responsive Logic
          bool isWideScreen = constraints.maxWidth > 700;
          double contentWidth = isWideScreen ? 600 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  // --- ১. প্রোফাইল হেডার ---
                  _buildProfileHeader(),

                  const SizedBox(height: 20),
                  const Text("All Shortcuts", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 10),

                  // --- ২. শর্টকাট গ্রিড ---
                  _buildShortcutGrid(),

                  const SizedBox(height: 20),
                  const Divider(),

                  // --- ৩. এক্সপান্ডেবল মেনু ---
                  _buildExpandableMenu(
                      icon: Icons.settings,
                      title: "Settings & Privacy",
                      children: ["Settings", "Privacy Checkup", "Device requests", "Ad preferences"]
                  ),
                  _buildExpandableMenu(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      children: ["Help Center", "Support Inbox", "Report a problem"]
                  ),
                  _buildExpandableMenu(
                      icon: Icons.info_outline,
                      title: "Community Resources",
                      children: ["Community Standards", "Safety Check"]
                  ),

                  const SizedBox(height: 20),

                  // --- ৪. লগআউট বাটন ---
                  _buildLogoutButton(),

                  const SizedBox(height: 30),

                  // Version
                  Center(
                    child: Text(
                      "Meetyarah • Version 1.0.0",
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Obx(() {
      final user = controller.profileUser.value;
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.to(() => const ProfilePage()),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                      user?.profilePictureUrl ?? "https://i.pravatar.cc/150?img=12"
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          user?.fullName ?? "Loading...",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                      const Text("See your profile", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShortcutGrid() {
    final List<Map<String, dynamic>> shortcuts = [
      {'icon': Icons.group, 'label': 'Groups', 'color': Colors.blue},
      {'icon': Icons.storefront, 'label': 'Marketplace', 'color': Colors.green},
      {'icon': Icons.ondemand_video, 'label': 'Video', 'color': Colors.red},
      {'icon': Icons.history, 'label': 'Memories', 'color': Colors.purple},
      {'icon': Icons.bookmark, 'label': 'Saved', 'color': Colors.deepPurple},
      {'icon': Icons.flag, 'label': 'Pages', 'color': Colors.orange},
      {'icon': Icons.event, 'label': 'Events', 'color': Colors.redAccent},
      {'icon': Icons.gamepad, 'label': 'Gaming', 'color': Colors.indigo},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3, // চ্যাপ্টা কার্ডের জন্য
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {}, // Future Logic
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(item['icon'], color: item['color'], size: 28),
                    const SizedBox(width: 12),
                    Text(item['label'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableMenu({required IconData icon, required String title, required List<String> children}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, size: 30, color: Colors.grey[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 10),
        children: children.map((subItem) => ListTile(
          contentPadding: const EdgeInsets.only(left: 40),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(subItem, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          onTap: () {},
        )).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Get.defaultDialog(
            title: "Log Out?",
            middleText: "Are you sure you want to log out?",
            textConfirm: "Yes",
            textCancel: "No",
            confirmTextColor: Colors.white,
            onConfirm: () {
              authService.logout();
            },
          );
        },
        child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
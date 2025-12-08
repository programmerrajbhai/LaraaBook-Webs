import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/create_post/screens/create_post.dart';
import 'package:meetyarah/ui/dashboard/screens/dashboard_screens.dart';
import 'package:meetyarah/ui/home/screens/feed_screen.dart' hide ReelScreens;
import 'package:meetyarah/ui/menu_list/screens/menu_item_screens.dart';
import '../../reels/screens/reel_screens.dart';

class Basescreens extends StatefulWidget {
  const Basescreens({super.key});

  @override
  State<Basescreens> createState() => _BasescreensState();
}

class _BasescreensState extends State<Basescreens> {
  // Current selected index
  int _selectedIndex = 0;

  // Define pages in a getter to ensure they are re-built if needed/safe
  List<Widget> get _pages => [
    const FeedScreen(),
    const ReelScreens(),
    const CreatePostScreen(),
    const ActivityDashboardScreen(),
    MenuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final size = MediaQuery.of(context).size;
    // Determine if we should use desktop layout (> 800px)
    final bool isWebDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Adjust spacing based on layout
        titleSpacing: isWebDesktop ? 30 : 20,
        title: Text(
          "MEETYARAH",
          style: GoogleFonts.bebasNeue(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            color: ColorPath.deepBlue,
            letterSpacing: 2,
          ),
        ),
        actions: [
          _buildActionButton(Icons.search_rounded, () {}),
          const SizedBox(width: 10),
          _buildActionButton(Icons.forum_rounded, () {}, isNotification: true),
          SizedBox(width: isWebDesktop ? 30 : 15),
        ],
      ),

      // --- BODY ---
      body: isWebDesktop
          ? _buildWebLayout()
          : IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // --- BOTTOM NAVIGATION (Mobile Only) ---
      bottomNavigationBar: isWebDesktop
          ? null
          : Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          items: _getNavItems(),
          currentIndex: _selectedIndex,
          selectedItemColor: ColorPath.deepBlue,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 26,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // --- WEB LAYOUT STRUCTURE ---
  Widget _buildWebLayout() {
    return Row(
      children: [
        // 1. Navigation Rail (Side Menu)
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          labelType: NavigationRailLabelType.all,
          backgroundColor: Colors.white,
          // Fixed: Border used inside BoxDecoration logic via Container/VerticalDivider
          groupAlignment: -1.0, // Top aligned
          indicatorColor: ColorPath.deepBlue.withOpacity(0.1),
          selectedIconTheme: const IconThemeData(color: ColorPath.deepBlue),
          unselectedIconTheme: const IconThemeData(color: Colors.grey),
          unselectedLabelTextStyle: GoogleFonts.inter(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          selectedLabelTextStyle: GoogleFonts.inter(
            color: ColorPath.deepBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          destinations: _getNavRailDestinations(),
        ),

        // Divider Line
        VerticalDivider(thickness: 1, width: 1, color: Colors.grey.shade200),

        // 2. Main Content Area (Centered)
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),
        ),

        // 3. Right Side (Suggestions/Ads) - Only on large screens
        if (MediaQuery.of(context).size.width > 1200)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Center(
              child: Text(
                "Suggestions / Ads",
                style: GoogleFonts.inter(color: Colors.grey[400]),
              ),
            ),
          ),
      ],
    );
  }

  // --- WIDGET HELPER: Action Buttons ---
  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isNotification = false}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.black87, size: 22),
            onPressed: onTap,
            splashRadius: 20,
          ),
        ),
        if (isNotification)
          Positioned(
            right: 6,
            top: 10,
            child: Container(
              height: 9,
              width: 9,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          )
      ],
    );
  }

  // --- DATA: Navigation Items (Mobile) ---
  List<BottomNavigationBarItem> _getNavItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.style_outlined), activeIcon: Icon(Icons.style), label: "Feed"),
      const BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle_fill), label: "Reels"),

      // Highlighted "Create" Button
      BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [ColorPath.deepBlue, Colors.purpleAccent]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: ColorPath.deepBlue.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        label: "Create",
      ),

      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Dash"),
      const BottomNavigationBarItem(icon: Icon(Icons.menu), activeIcon: Icon(Icons.menu_open), label: "Menu"),
    ];
  }

  // --- DATA: Navigation Rail Items (Web) ---
  List<NavigationRailDestination> _getNavRailDestinations() {
    return [
      const NavigationRailDestination(
        icon: Icon(Icons.style_outlined),
        selectedIcon: Icon(Icons.style),
        label: Text("Feed"),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.play_circle_outline),
        selectedIcon: Icon(Icons.play_circle_fill),
        label: Text("Reels"),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.add_box_outlined),
        selectedIcon: Icon(Icons.add_box),
        label: Text("Create"),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text("Dash"),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.menu),
        selectedIcon: Icon(Icons.menu_open),
        label: Text("Menu"),
      ),
    ];
  }
}
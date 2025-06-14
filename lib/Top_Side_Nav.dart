// top_nav.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'Screens/Job_Seeker/Login.dart';
import 'Top_Nav_Provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int activeIndex; // 0 = Dashboard, 1 = Profile, etc.
  final Key? key;

  MainLayout({
    this.key,
    required this.child,
    required this.activeIndex,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  final Color _cardWhite = Color(0xFFFFFFFF);
  final Color _textPrimary = Color(0xFF1E293B);
  final Color _textSecondary = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);
  final Color _hoverColor = Color(0xFFF1F5F9);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TopNavProvider>(
      create: (_) => TopNavProvider(),
      child: RepaintBoundary(child: _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final primaryColor = Theme
        .of(context)
        .primaryColor;
    final backgroundGray =    Color(0xFFF5F8FA);
    final initials = context.watch<TopNavProvider>().initials;
    return Scaffold(
      backgroundColor: backgroundGray,
      body: Row(
        children: [
          RepaintBoundary(
            child: Container(
              width: 240,
              height: double.infinity,
              decoration: BoxDecoration(
                color: backgroundGray,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset:    Offset(2, 0), // Right-side shadow
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                // ensure rounded corners clip scrollable content
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),

                      // ─── Logo inside Side Nav ───
                      Padding(
                        padding:    EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLogo(),
                      ),
                      SizedBox(height: 16),
                      Divider(
                        thickness: 1,
                        color: Color(0xFFCCCCCC),
                      ),
                      SizedBox(height: 24),
                      _buildUserProfileSection(primaryColor),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                      SizedBox(height: 16),

                      // ─── Dashboard Button ───
                      Padding(
                        padding:    EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.home_filled,
                          label: 'Register Farm',
                          isActive: widget.activeIndex == 0,
                          onTap: () {
                            if (widget.activeIndex != 0) {
                              context.go('/dashboard');
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8),

                      // ─── Create Profile Button ───
                      Padding(
                        padding:    EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.devices_outlined,
                          label: 'Device Registration',
                          isActive: widget.activeIndex == 1,
                          onTap: () {
                            if (widget.activeIndex != 1) {
                              context.go('/profile');
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8),

                      // ─── Saved Jobs ───
                      Padding(
                        padding:    EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.people_alt_outlined,
                          label: 'Profile',
                          isActive: widget.activeIndex == 2,
                          onTap: () {
                            if (widget.activeIndex != 2) {
                              context.go('/saved');
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8),

                      // ─── Job Alerts ───
                      Padding(
                        padding:    EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.settings,
                          label: 'Settings',
                          isActive: widget.activeIndex == 3,
                          onTap: () {
                            if (widget.activeIndex != 3) {
                              context.go('/alerts');
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      // ─── Bottom Divider + Logout ───
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding:    EdgeInsets.symmetric(horizontal: 16),
                        child: _LogoutButton(
                          key:    ValueKey('nav_logout'),
                          onTap: () async{
                            // handle logout
                            await FirebaseAuth.instance.signOut();
                            context.pushReplacement('/login');
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Right Side: Top Bar (without Logo) + Main Content ───
          Expanded(
            child: Column(
              children: [
                // ─── Top Bar (Search, Notification, Avatar) ───
                if (widget.activeIndex == 0)
                  _buildTopBar(primaryColor, initials),
                // ─── Main Content Area ────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration:    Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin:    Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLogo() {
    return MouseRegion(
      child: GestureDetector(
        onTap: () =>(),
        child: Row(
          children: [
            SizedBox(width: 2,),
            Image.asset('images/logo_ck.png', height: 50, fit: BoxFit.contain),
            const SizedBox(width: 5),
            // Optional: Add company name next to logo
            Text(
              'Crop Konnect',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color primaryColor, String initials) {
    return Container(
      height: 70,
      width: 800,
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius:    BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset:    Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset:    Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: _borderColor,
            width: 1,
          ),
        ),
      ),
      padding:    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // ─── Enhanced Search Field ───
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              constraints:    BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: _isSearchFocused ? _cardWhite : _hoverColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchFocused ? primaryColor : _borderColor,
                  width: _isSearchFocused ? 2 : 1,
                ),
                boxShadow: _isSearchFocused
                    ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset:    Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  filled: false,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _isSearchFocused ? primaryColor : _textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: _textSecondary,
                      size: 18,
                    ),
                    splashRadius: 16,
                  )
                      : null,
                  hintText: 'Search jobs, companies, or keywords...',
                  hintStyle:  GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding:    EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: (value) {
                  debugPrint('Search: $value');
                },
              ),
            ),
          ),

          Spacer(),

          // ─── Quick Actions ───
          Row(
            children: [
              // Notifications with badge
              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                onPressed: () => _showNotifications(context),
                badge: 3, // Example badge count
              ),

              SizedBox(width: 12),

              // Messages
              _buildIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => _showMessages(context),
              ),

              SizedBox(width: 16),

              // Profile Menu
              _buildProfileMenu(primaryColor, initials),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    int? badge,
  }) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: _textSecondary,
            size: 30,
          ),
          splashRadius: 20,
          tooltip: 'Notifications',
        ),
        if (badge != null && badge > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding:    EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade500,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints:BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                style:     GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileMenu(Color primaryColor, String initials) {
    return PopupMenuButton<String>(
      offset:    Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding:    EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _borderColor,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor,
          child: Text(
            initials.isNotEmpty ? initials : 'ZA',
            style:     GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) =>
      [
        _buildPopupMenuItem('Profile', Icons.person_outline_rounded, () {
          context.go('/profile');
        }),
        _buildPopupMenuItem('Settings', Icons.settings_outlined, () {
          // Handle settings
        }),
        _buildPopupMenuItem('Help', Icons.help_outline_rounded, () {
          // Handle help
        }),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: () {
            _showLogoutDialog(context);
          },
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18,
                color: Colors.red.shade500,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Logout',
                  overflow: TextOverflow.ellipsis,
                  style:  GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String title,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return PopupMenuItem<String>(
      value: title.toLowerCase(),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red.shade500 : _textSecondary,
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style:  GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red.shade500 : _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    // Placeholder: show a bottom sheet or dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:    Text('Notifications'),
        content:    Text('You have new notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:    Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessages(BuildContext context) {
    // Placeholder: show a bottom sheet or dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:    Text('Messages'),
        content:    Text('You have new messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:    Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title:    Text(
              'Confirm Logout',
              style:  GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
            content:    Text(
              'Are you sure you want to logout?',
              style:  GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:    Text('Cancel'),
              ),
              TextButton(
                onPressed: ()async {

                  await FirebaseAuth.instance.signOut();
                  context.pushReplacement('/login');

                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child:    Text('Logout'),
              ),
            ],
          ),
    );
  }

  Widget _buildUserProfileSection(Color primaryColor) {
    return Container(
      margin:    EdgeInsets.symmetric(horizontal: 10),
      padding:    EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:    Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zain Ali',
                      style:  GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Full Stack Developer',
                      style:  GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.go('/profile'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                padding:    EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:    Text(
                'View Profile',
                style:  GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/// Single navigation button in the side-rail.
/// Highlights itself if isActive == true.
class _SideNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  _SideNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super();

  @override
  State<_SideNavButton> createState() => _SideNavButtonState();
}

class _SideNavButtonState extends State<_SideNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final unselectedColor =    Color(0xFF5C738A);

    Color bgColor() {
      if (widget.isActive) {
        return primaryColor.withOpacity(0.1);
      } else if (_isHovered) {
        return primaryColor.withOpacity(0.05);
      } else {
        return Colors.transparent;
      }
    }

    Color iconColor() {
      if (widget.isActive) return primaryColor;
      if (_isHovered) return primaryColor;
      return unselectedColor;
    }

    Color textColor() {
      if (widget.isActive) return primaryColor;
      if (_isHovered) return primaryColor;
      return unselectedColor;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration:    Duration(milliseconds: 150),
          height: 48,
          width: double.infinity,
          padding:    EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: iconColor()),
              SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  final Key? key;

  _LogoutButton({
    this.key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final unselectedColor =    Color(0xFF5C738A);

    Color bgColor() {
      if (_isHovered) return Colors.red.shade100;
      return Color(0xFFF5F8FA);
    }

    Color iconColor() {
      if (_isHovered) return Colors.red;
      return unselectedColor;
    }

    Color textColor() {
      if (_isHovered) return Colors.red;
      return unselectedColor;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _logout(context),

        child: AnimatedContainer(
          duration:    Duration(milliseconds: 150),
          height: 48,

          width: double.infinity,
          padding:    EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(

            color: bgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.logout, color: iconColor()),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // In your dashboard screen's state widget (e.g., _JobSeekerDashboardState)

  Future<void> _logout(BuildContext context) async {
    // First, sign out the user from Firebase.
    await FirebaseAuth.instance.signOut();

    // IMPORTANT: Then, use context.go() to navigate.
    // This clears the entire navigation stack and pushes '/login' as the new
    // base route. This prevents the user from pressing the browser's back
    // button to get back to the dashboard.
    if (context.mounted) {
      context.pushReplacement('/login');
    }
  }


}

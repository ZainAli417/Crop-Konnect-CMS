// top_nav.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide LatLng;
import 'package:provider/provider.dart';
import 'Constant/Map_Screen.dart';
import 'Constant/map_screen_provider.dart';
import 'Screens/Job_Seeker/Login.dart';
import 'Top_Nav_Provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';


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
  final places = GoogleMapsPlaces(apiKey: "AIzaSyBqEb5qH08mSFysEOfSTIfTezbhJjJZSRs");

  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  final Color _textPrimary = Color(0xFF1E293B);
  final Color _textSecondary = Color(0xFF64748B);
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounceTimer;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  List<Prediction> _predictions = [];
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();


  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange); // ▶️ ADD THIS
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
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
    final backgroundGray = Color(0xFFF5F8FA);
    final initials = context
        .watch<TopNavProvider>()
        .initials;
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
                    offset: Offset(2, 0), // Right-side shadow
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.devices_outlined,
                          label: 'Device Registration',
                          isActive: widget.activeIndex == 1,
                          onTap: () {
                            if (widget.activeIndex != 1) {
                              context.go('/device-registration');
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8),

                      // ─── Saved Jobs ───
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _LogoutButton(
                          key: ValueKey('nav_logout'),
                          onTap: () async {
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
                  _buildtopbar(primaryColor, initials),
                // ─── Main Content Area ────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.0, 0.1),
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
        onTap: () => (),
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





// Consolidated tool section with better state management
  Widget _buildToolSection() {
    return Consumer<MapDrawingProvider>(
      builder: (context, provider, _) {
        final tools = [
          {'icon': Icons.brush, 'tool': 'freehand', 'tooltip': 'Draw'},
          {'icon': Icons.crop_square, 'tool': 'rectangle', 'tooltip': 'Rectangle'},
          {'icon': Icons.place, 'tool': 'marker', 'tooltip': 'Marker'},
          {'icon': Icons.front_hand, 'tool': 'hand', 'tooltip': 'Pan'},
        ];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: tools.map((tool) => _buildToolButton(
            icon: tool['icon'] as IconData,
            tool: tool['tool'] as String,
            tooltip: tool['tooltip'] as String,
            isSelected: provider.currentTool == tool['tool'],
            onPressed: () => provider.setCurrentTool(tool['tool'] as String),
          )).toList(),
        );
      },
    );
  }

// Enhanced tool button with better animations and accessibility
  Widget _buildToolButton({
    required IconData icon,
    required String tool,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

// Main consolidated top bar with enhanced UX
  Widget _buildtopbar(Color primaryColor, String initials) {
    return Container(
      height: 70,
      width: 800,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Left section: Tools + Search
          Expanded(
            flex: 6, // Increased flex to make search area longer
            child: Row(
              children: [
                // Consolidated tool buttons
                _buildToolSection(),
                const SizedBox(width: 20),
                // Enhanced search bar - takes more space now
                Expanded(child: _buildSearchWidget()),
              ],
            ),
          ),
          // Right section: Actions + Profile
          _buildActionsSection(primaryColor, initials),
        ],
      ),
    );
  }
// ------------------- WIDGET BUILD METHODS -------------------

  Widget _buildSearchWidget() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: _buildSearchBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _searchFocusNode.hasFocus
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _searchFocusNode,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Search places...",
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: _searchPlaces,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty && _predictions.isNotEmpty) {
                  _onSuggestionTap(_predictions.first);
                }
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
  Widget _buildSearchSuggestionsList() {
    return Material(
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 400, // Fixed width - adjust as needed
        constraints: const BoxConstraints(
          maxHeight: 300,
          minHeight: 50,
          maxWidth: 400, // Ensure maximum width
          minWidth: 300, // Ensure minimum width
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(3),
            child: ListView.separated(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _predictions.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 48,
                endIndent: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              itemBuilder: (context, index) {
                return _buildSuggestionItem(_predictions[index], index);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showOverlay() {
    // If overlay already exists, do nothing.
    if (_overlayEntry != null) return;
    // If there are no predictions, do nothing.
    if (_predictions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        // Wrap the Follower in a Positioned widget to add extra constraints
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Invisible barrier to detect taps outside
                GestureDetector(
                  onTap: () {
                    _removeOverlay();
                    _searchFocusNode.unfocus();
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                // The actual suggestions
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 52), // Position below search bar
                  child: Container(
                    // Additional container for size constraints
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 300,
                    ),
                    child: _buildSearchSuggestionsList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }







  Widget _buildSuggestionItem(dynamic prediction, int index) {
    final secondary = _getSecondaryText(prediction.description ?? "");

    // The InkWell handles both the tap and the visual feedback.
    // A wrapping GestureDetector is not needed.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _onSuggestionTap(prediction);
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        mouseCursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100 + (index * 30)),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getMainText(prediction.description ?? ""),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (secondary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          secondary,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.north_west_rounded,
                size: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFocusChange() {
    // Update the border color of the search bar
    setState(() {});

    // If we are losing focus, we must delay removing the overlay.
    // This gives the onTap event of a suggestion item enough time to
    // process before the overlay is removed from the widget tree.
    if (!_searchFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _removeOverlay();
        }
      });
    }
  }

  void _searchPlaces(String input) {
    _searchDebounceTimer?.cancel();

    if (input.isEmpty) {
      setState(() => _predictions = []);
      _removeOverlay();
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final response = await places.autocomplete(input);
        if (mounted) {
          if (response.isOkay && response.predictions.isNotEmpty) {
            setState(() => _predictions = response.predictions);
            _showOverlay(); // Show suggestions on success
          } else {
            debugPrint("Places Autocomplete error: ${response.errorMessage}");
            setState(() => _predictions = []);
            _removeOverlay(); // Hide on error
          }
        }
      } catch (e) {
        if (mounted) {
          debugPrint("Search error: $e");
          setState(() => _predictions = []);
          _removeOverlay(); // Hide on exception
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  void _onSuggestionTap(Prediction prediction) async {
    if (_isLoading) return; // Prevent multiple taps

    // 1. Immediately remove the overlay and unfocus the search bar
    _removeOverlay();
    _searchFocusNode.unfocus();

    // 2. Update UI to show loading and the selected place name
    setState(() {
      _controller.text = prediction.description ?? '';
      _predictions = [];
      _isLoading = true;
    });

    try {
      // 3. Fetch details and move the camera
      final latLng = await _getLatLngFromPlaceId(prediction.placeId!);
      if (latLng == null) return; // Error handled in finally

      final provider = Provider.of<MapDrawingProvider>(context, listen: false);
      if (provider.mapController != null) {
        await provider.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16),
        );
      }
    } catch (e) {
      debugPrint("Error navigating to place: $e");
    } finally {
      // 4. Stop loading indicator
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }


  String _getMainText(String description) {
    if (description.contains(',')) {
      return description.split(',').first.trim();
    }
    return description;
  }

  String _getSecondaryText(String description) {
    if (description.contains(',')) {
      final parts = description.split(',');
      if (parts.length > 1) {
        return parts.sublist(1).join(',').trim();
      }
    }
    return '';
  }

  Future<LatLng?> _getLatLngFromPlaceId(String placeId) async {
    final detail = await places.getDetailsByPlaceId(placeId);
    if (detail.isOkay) {
      final loc = detail.result.geometry?.location;
      if (loc != null) return LatLng(loc.lat, loc.lng);
    }
    return null;
  }








// Enhanced profile menu with theme consistency
  Widget _buildProfileMenu(Color primaryColor, String initials) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: 'Profile Menu',
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            initials.isNotEmpty ? initials : 'ZA',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('Device Registration', Icons.devices_outlined, () => context.go('/device-registration')),
        _buildMenuItem('Settings', Icons.settings_outlined, () {}),
        _buildMenuItem('Help', Icons.help_outline_rounded, () {}),
        const PopupMenuDivider(),
        _buildMenuItem(
          'Logout',
          Icons.logout_rounded,
              () => _showLogoutDialog(context),
          isDestructive: true,
        ),
      ],
    );
  }
// Streamlined menu item builder
  PopupMenuItem<String> _buildMenuItem(
      String title,
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
            color: isDestructive
                ? Colors.red.shade500
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDestructive
                  ? Colors.red.shade500
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildUserProfileSection(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: primaryColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                    Icons.person_rounded, color: Colors.white, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zain Ali',
                        style: GoogleFonts.inter(fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary)),
                    SizedBox(height: 2),
                    Text('Victoria, Australia',
                        style: GoogleFonts.inter(fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.go('/device-registration'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Buy Devices', style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
// Consolidated actions section
  Widget _buildActionsSection(Color primaryColor, String initials) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () => _showNotifications(context),
          badge: 3,
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: () => _showMessages(context),
          tooltip: 'Messages',
        ),
        const SizedBox(width: 16),
        _buildProfileMenu(primaryColor, initials),
      ],
    );
  }
// Enhanced action button with better visual feedback
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    int? badge,
  }) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(20),
              splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          if (badge != null && badge > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badge > 99 ? '99+' : badge.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
// Enhanced dialogs with consistent theming
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'You have new notifications.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessages(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Messages',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'You have new messages.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.pushReplacement('/login');
                }
              } catch (e) {
                debugPrint("Logout error: $e");
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

// Don't forget to dispose resources to prevent memory leaks
  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange); // ▶️ ADD THIS
    _focusNode.dispose();
    _searchDebounceTimer?.cancel();
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }



}
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

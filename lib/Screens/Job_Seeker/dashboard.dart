// dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constant/Map_Screen.dart';
import '../../Constant/farm_list_view.dart';
import '../../Constant/map_screen_provider.dart';
import '../../Top_Side_Nav.dart';

/// Enhanced farmer dashboard with modern UX and smooth animations
class farmer_dashboard extends StatefulWidget {
  const farmer_dashboard({super.key});

  @override
  State<farmer_dashboard> createState() => _farmer_dashboardState();
}

class _farmer_dashboardState extends State<farmer_dashboard>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _welcomeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color palette
  static const Color _primaryGreen = Color(0xFF4C6B3C);
  static const Color _accentGreen = Color(0xFF5A691A);
  static const Color _backgroundColor = Color(0xFFF9F6F1);
  static const Color _surfaceColor = Colors.white;
  static const Color _cardBackground = Color(0xFFF5F8FA);

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart),
    ));

    // Start animations
    _pageController.forward();
    _welcomeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapDrawingProvider(),
      child: MainLayout(
        activeIndex: 0,
        child: AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildDashboardContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Container(
     color: Color(0xFFF5F8FA),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Main Content
            Expanded(
              flex: 3,
              child: _buildMainContent(),
            ),

            const SizedBox(width: 24),

            // Right Column - Farms Sidebar
            Expanded(
              flex: 1,
              child: _buildFarmsSidebar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Welcome Section
          _buildWelcomeSection(),

          const SizedBox(height: 5),
          // Map Container with enhanced styling
          _buildMapContainer(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _welcomeController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(28),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.waving_hand,
                      color: _primaryGreen,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [_primaryGreen, _accentGreen],
                          ).createShader(bounds),
                          child: Text(
                            'Welcome Back, Zain!',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Ready to Map your farms today?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
SizedBox(height: 7,),
              // Quick Action Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryGreen.withOpacity(0.05),
                      _accentGreen.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryGreen.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.draw_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Start Guide',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use the draw tool from the top bar to plot your farm boundaries on the map',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_upward_sharp,
                      color: _primaryGreen,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapContainer() {
    return SizedBox(
      height: 450,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const Map_Screen(),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmsSidebar() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _surfaceColor,
            _cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _primaryGreen.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryGreen.withOpacity(0.05),
                  _accentGreen.withOpacity(0.02),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: _primaryGreen.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.landscape_rounded,
                    color: _primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'My Farms',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                    ),
                  ),
                ),
                Consumer<MapDrawingProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.farms.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Farms List Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<MapDrawingProvider>(
                builder: (context, provider, _) {
                  if (provider.farms.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.farms.length,
                    itemBuilder: (context, index) {
                      return AnimatedSlide(
                        offset: Offset(0, index * 0.1),
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeOutQuart,
                        child: FarmListItem(
                          farm: provider.farms[index],
                          onTap: () {
                            provider.selectFarm(provider.farms[index]);
                            HapticFeedback.lightImpact();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.agriculture_outlined,
              size: 48,
              color: _primaryGreen.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'No Farms Yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _primaryGreen,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Start by plotting your first farm boundary on the map',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreen, _accentGreen],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.draw_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Use Draw Tool',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
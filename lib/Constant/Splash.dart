import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'Header_Nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _checkingUser = true;
  bool _contentVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLoggedInUser();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  Future<void> _checkLoggedInUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final uid = user.uid;

        final jobSeeker = await firestore
            .collection('user_info')
            .doc(uid)
            .get();

        if (jobSeeker.exists) {
          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 500));
            context.go('/dashboard');
          }
          return;
        }

        // User exists but not in collection - sign out
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      debugPrint('Error checking user role: $e');
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingUser = false;
          _contentVisible = true;
        });
        _startAnimations();
      }
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache background image for better performance
    precacheImage(const AssetImage('images/bg_ck.png'), context);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isMobile = screenSize.width < 600;

    if (_checkingUser) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6B3C)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Background image with hero animation
          Hero(
            tag: 'background',
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bg_ck.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isTablet, bool isMobile) {
    return SafeArea(
      child: Column(
        children: [
          const HeaderNav(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 48,
                vertical: 32,
              ),
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  );
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 950 : double.infinity,
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // optional, aligns to start
                        children: [
                          SizedBox(height: 0), // push content down from top

                      Center(

                         child:_buildLogo(isMobile),
                      ),
                          SizedBox(height: isMobile ? 22 : 38),
                          Center(
                       child:    _buildSubtitle(isMobile),
                          ),
                          SizedBox(height: isMobile ? 20 : 36),
                          Center(
                          child: _buildActionButtons(isMobile),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isMobile) {
    return Hero(
      tag: 'logo',
      child: Material(
        color: Colors.transparent,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Crop ',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 48 : 76,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4C6B3C),
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: 'Konnect',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 48 : 76,
                  fontWeight: FontWeight.w800,
                  color: Colors.brown.shade700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Connect farmers with opportunities, grow your agricultural network',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: isMobile ? 16 : 20,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPrimaryButton(isMobile),
        SizedBox(
          width: isMobile ? 0 : 24,
          height: isMobile ? 16 : 0,
        ),
        _buildSecondaryButton(isMobile),
      ],
    );
  }

  Widget _buildPrimaryButton(bool isMobile) {
    return _AnimatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        context.go('/register');
      },
      width: isMobile ? double.infinity : 200,
      height: 56,
      isPrimary: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get Started',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(bool isMobile) {
    return _AnimatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        context.go('/recruiter-signup');
      },
      width: isMobile ? double.infinity : 200,
      height: 56,
      isPrimary: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.play_circle_outline_rounded,
            color: Color(0xFF4C6B3C),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Watch Demo',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4C6B3C),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;
  final bool isPrimary;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
    required this.width,
    required this.height,
    required this.isPrimary,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height,
                transform: _isHovered
                    ? Matrix4.translationValues(0, -2, 0)
                    : Matrix4.identity(),
                child: widget.isPrimary
                    ? _buildPrimaryButton()
                    : _buildSecondaryButton(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4C6B3C),
        foregroundColor: Colors.white,
        elevation: _isHovered ? 8 : 4,
        shadowColor: const Color(0xFF4C6B3C).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: widget.child,
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton(
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: _isHovered
            ? const Color(0xFFFFFFFF)
            : Colors.white.withOpacity(0.9),
        foregroundColor: const Color(0xFF4C6B3C),
        side: BorderSide(
          color: const Color(0xFF4C6B3C),
          width: _isHovered ? 2 : 1.5,
        ),
        elevation: _isHovered ? 4 : 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: widget.child,
    );
  }
}
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Header_Nav.dart';
import 'Forget Password Provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _focusNode = FocusNode();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isEmailValid = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupEmailListener();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  void _setupEmailListener() {
    _email.addListener(() {
      final email = _email.text.trim();
      final isValid = email.isNotEmpty &&
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

      if (isValid != _isEmailValid) {
        setState(() {
          _isEmailValid = isValid;
        });
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _focusNode.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError();
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    final provider = Provider.of<ForgotPasswordProvider>(context, listen: false);
    provider.setEmail(_email.text.trim());

    try {
      await provider.submitForgotPassword(context);

      // Show success state
      setState(() {
        _showSuccess = true;
      });

      // Auto-hide success after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
          });
        }
      });

    } catch (e) {
      // Error handling is done in provider
    }
  }

  void _showValidationError() {
    HapticFeedback.selectionClick();
    // Focus on email field if validation fails
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 800;
    final isTablet = screenWidth > 600 && screenWidth <= 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderNav(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight - 100, // Account for header
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48 : (isTablet ? 32 : 20),
                        vertical: 20,
                      ),
                      child: _buildContent(isWide, isTablet),
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

  Widget _buildContent(bool isWide, bool isTablet) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Column: Form
            Expanded(
              flex: isWide ? 5 : 1,
              child: _buildFormSection(isWide, isTablet),
            ),

            // Right Column: Illustration (Desktop only)
            if (isWide) ...[
              const SizedBox(width: 60),
              Expanded(
                flex: 4,
                child: _buildIllustrationSection(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(bool isWide, bool isTablet) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isWide ? 500 : double.infinity,
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(isWide ? 48 : (isTablet ? 32 : 24)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 24),
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: Color(0xFF4C6B3C),
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          "Forgot Password?",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          "Don't worry! Enter your email address and we'll send you a link to reset your password.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildEmailField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _focusNode.hasFocus
            ? [
          BoxShadow(
            color: const Color(0xFF4C6B3C).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: TextFormField(
        controller: _email,
        focusNode: _focusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _onSubmit(),
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "Email address is required";
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
            return "Please enter a valid email address";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Enter your email address",
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.email_outlined,
              color: _isEmailValid
                  ? const Color(0xFF4C6B3C)
                  : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          suffixIcon: _isEmailValid
              ? Container(
            margin: const EdgeInsets.only(right: 12),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4C6B3C),
              size: 18,
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4C6B3C),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<ForgotPasswordProvider>(
      builder: (_, provider, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _showSuccess
                  ? const Color(0xFF10B981)
                  : const Color(0xFF4C6B3C),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildButtonContent(provider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(ForgotPasswordProvider provider) {
    if (_showSuccess) {
      return Row(
        key: const ValueKey('success'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 20),
          const SizedBox(width: 8),
          Text(
            "Email Sent Successfully!",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (provider.isLoading) {
      return Row(
        key: const ValueKey('loading'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Sending...",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      key: const ValueKey('default'),
      "Send Reset Link",
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Remember your password? ",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: () {
           context.replace('/login');
    },
          child: Text(
            "Back to Login",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4C6B3C),
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF4C6B3C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 600, // ← Set desired fixed height or use MediaQuery
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                "images/forgot.svg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Secure & Fast Recovery",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We use advanced security measures to ensure your account recovery is both safe and quick.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
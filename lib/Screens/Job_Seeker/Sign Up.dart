import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../Constant/Header_Nav.dart';
import 'Signup_Provider.dart';

class farmer_signup extends StatefulWidget {
  const farmer_signup({super.key});
  @override
  State<farmer_signup> createState() => _farmer_signupState();
}

class _farmer_signupState extends State<farmer_signup>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // Focus nodes for better UX
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Toggle states for hiding/showing passwords
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupPasswordListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupPasswordListener() {
    _password.addListener(() {
      final password = _password.text;
      setState(() {
        _passwordStrength = _calculatePasswordStrength(password);
        _updatePasswordStrengthText();
      });
    });
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // Character variety checks
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    return strength.clamp(0.0, 1.0);
  }

  void _updatePasswordStrengthText() {
    if (_passwordStrength <= 0.3) {
      _passwordStrengthText = 'Weak';
      _passwordStrengthColor = Colors.red;
    } else if (_passwordStrength <= 0.6) {
      _passwordStrengthText = 'Medium';
      _passwordStrengthColor = Colors.orange;
    } else if (_passwordStrength <= 0.8) {
      _passwordStrengthText = 'Strong';
      _passwordStrengthColor = Colors.blue;
    } else {
      _passwordStrengthText = 'Very Strong';
      _passwordStrengthColor = Colors.green;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _showEnhancedFlushbar(BuildContext context, String message, bool isError) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
        size: 24,
      ),
      leftBarIndicatorColor: Colors.white,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    ).show(context);
  }

  void _onSubmit() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    final provider = Provider.of<SignUpProvider>(context, listen: false);
    final error = await provider.signUp(
      name: "${_firstName.text.trim()} ${_lastName.text.trim()}",
      email: _email.text.trim(),
      password: _password.text,
    );

    if (error != null) {
      _showEnhancedFlushbar(context, error, true);
      HapticFeedback.vibrate();
    } else {
      _showEnhancedFlushbar(context, "Welcome aboard! Account created successfully!", false);
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(seconds: 1), () {
        context.go('/login');
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              const HeaderNav(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    return Row(
                      children: [
                        // Form Section
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 40 : 16,
                              vertical: 20,
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - 40,
                                ),
                                child: _buildFormSection(primaryColor),
                              ),
                            ),
                          ),
                        ),
                        // Illustration Section
                        if (isWide)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              child: _buildIllustrationSection(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }


  Widget _buildFormSection(Color primaryColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 0),
          _buildNameFields(),
          const SizedBox(height: 24),
          _buildEmailField(),
          const SizedBox(height: 24),
          _buildPasswordFields(primaryColor),
          const SizedBox(height: 32),
          _buildSubmitButton(primaryColor),
          const SizedBox(height: 24),
          _buildFooterLinks(primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.agriculture_outlined,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Join the Future of Farming",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Create your account and start managing your farm with cutting-edge technology",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildEnhancedTextField(
            controller: _firstName,
            focusNode: _firstNameFocus,
            nextFocusNode: _lastNameFocus,
            label: "First Name",
            hintText: "John",
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildEnhancedTextField(
            controller: _lastName,
            focusNode: _lastNameFocus,
            nextFocusNode: _emailFocus,
            label: "Last Name",
            hintText: "Doe",
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildEnhancedTextField(
      controller: _email,
      focusNode: _emailFocus,
      nextFocusNode: _passwordFocus,
      label: "Email Address",
      hintText: "john.doe@example.com",
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.trim().isEmpty) return "Email is required";
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
          return "Please enter a valid email address";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordFields(Color primaryColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedTextField(
                    controller: _password,
                    focusNode: _passwordFocus,
                    nextFocusNode: _confirmPasswordFocus,
                    label: "Password",
                    hintText: "Create a strong password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Password is required";
                      if (val.length < 8) return "Password must be at least 8 characters";
                      return null;
                    },
                  ),
                  if (_password.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildPasswordStrengthIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedTextField(
                controller: _confirmPassword,
                focusNode: _confirmPasswordFocus,
                label: "Confirm Password",
                hintText: "Confirm your password",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return "Please confirm your password";
                  if (val != _password.text) return "Passwords don't match";
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _passwordStrength,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _passwordStrengthText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _passwordStrengthColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
          validator: validator ?? (val) {
            if (val == null || val.trim().isEmpty) return "$label is required";
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey.shade600,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Color primaryColor) {
    return Consumer<SignUpProvider>(
      builder: (_, provider, __) {
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 300, // Wider than the original 100 in EnhancedButton
            height: 56,
            child: _EnhancedButton(
              onPressed: provider.isLoading ? null : _onSubmit,
              isLoading: provider.isLoading,
              text: "Create Account",
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterLinks(Color primaryColor) {
    return Column(
      children: [
        const Divider(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => context.replace('/recover-password'),
              icon: Icon(Icons.help_outline, size: 16, color: primaryColor),
              label: Text(
                "Forgot Password?",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.replace('/login'),
              icon: Icon(Icons.login, size: 16, color: primaryColor),
              label: Text(
                "Already have an account?",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
            ),
          ],
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
              child: Image.asset(
                "images/signup.png",
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
                    SizedBox(width: 10,),
                    Text(
                      "Smart Farming Starts Here",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Join thousands of farmers using technology to maximize their harvest",
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

class _EnhancedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const _EnhancedButton({
    required this.onPressed,
    required this.isLoading,
    required this.text,
  });

  @override
  State<_EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<_EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 56,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.onPressed != null
                  ? const LinearGradient(
                colors: [Color(0xFF6D8A5F), Color(0xFF4C6B3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: widget.onPressed == null ? const Color(0xFFCBD5E0) : null,
              boxShadow: widget.onPressed != null
                  ? [
                BoxShadow(
                  color: const Color(0xFF4C6B3C).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    widget.text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

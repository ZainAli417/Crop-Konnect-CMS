import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderNav extends StatefulWidget {
  const HeaderNav({super.key});

  @override
  State<HeaderNav> createState() => _HeaderNavState();
}

class _HeaderNavState extends State<HeaderNav> {
  String? hoveredItem;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 30 : (isTablet ? 32 : 16),
        vertical: 10,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Row(
          children: [
            // Logo Section
            _buildLogo(),

            const Spacer(),

            // Navigation Menu (Desktop only)
            if (isDesktop) ...[_buildNavigation(), const SizedBox(width: 40)],

            // Action Buttons
            _buildActionButtons(isDesktop),

            // Mobile Menu Button
            if (!isDesktop) _buildMobileMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => GoRouter.of(context).go('/'),
        child: Row(
          children: [
            SizedBox(width: 40,),
            Image.asset('images/logo_ck.png', height: 70, fit: BoxFit.contain),
            const SizedBox(width: 12),
            // Optional: Add company name next to logo
            Text(
              'Crop Konnect',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    final navItems = [
      {'title': 'Home', 'route': '/'},
      {'title': 'About', 'route': '/about'},
      {'title': 'Services', 'route': '/services'},
      {'title': 'Portfolio', 'route': '/portfolio'},
      {'title': 'Blog', 'route': '/blog'},
      {'title': 'Contact', 'route': '/contact'},
    ];

    return Row(
      children: navItems.map((item) {
        final isHovered = hoveredItem == item['title'];

        return MouseRegion(
          onEnter: (_) => setState(() => hoveredItem = item['title']),
          onExit: (_) => setState(() => hoveredItem = null),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => GoRouter.of(context).go(item['route']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isHovered
                    ? const Color(0xFF4C6B3C).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Text(
                item['title']!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isHovered
                      ? const Color(0xFF4C6B3C)
                      : const Color(0xFF374151),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(bool isDesktop) {
    return Row(
      children: [
        // Search Button (Desktop)
        if (isDesktop) ...[
          _buildIconButton(
            Icons.search,
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search',
          ),
          const SizedBox(width: 12),
        ],

        // Language Selector
        _buildLanguageSelector(),
        const SizedBox(width: 16),

        // Login Button
        _buildPrimaryButton(
          'Login',
          onPressed: () => GoRouter.of(context).go('/login'),
          isPrimary: false,
        ),

        const SizedBox(width: 12),

        // Get Started Button
        _buildPrimaryButton(
          'Get Started',
          onPressed: () => GoRouter.of(context).go('/register'),
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<String>(
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.language, size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                'EN',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'en', child: Text('English')),
          const PopupMenuItem(value: 'es', child: Text('Español')),
          const PopupMenuItem(value: 'fr', child: Text('Français')),
          const PopupMenuItem(value: 'de', child: Text('Deutsch')),
        ],
        onSelected: (value) {
          // Handle language change
          print('Selected language: $value');
        },
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text, {
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary
                ? const Color(0xFF4C6B3C)
                : Colors.transparent,
            foregroundColor: isPrimary ? Colors.white : const Color(0xFF4C6B3C),
            elevation: isPrimary ? 2 : 0,
            shadowColor: isPrimary
                ? const Color(0xFF4C6B3C).withOpacity(0.3)
                : null,
            side: isPrimary ? null : const BorderSide(color: Color(0xFF4C6B3C)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildMobileMenuButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: IconButton(
        onPressed: () => _showMobileMenu(),
        icon: const Icon(Icons.menu),
        iconSize: 24,
        color: const Color(0xFF374151),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'What are you looking for?',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4C6B3C)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle search
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C6B3C),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildMobileMenuItem('Home', Icons.home, '/'),
                  _buildMobileMenuItem('About', Icons.info, '/about'),
                  _buildMobileMenuItem('Services', Icons.business, '/services'),
                  _buildMobileMenuItem('Portfolio', Icons.work, '/portfolio'),
                  _buildMobileMenuItem('Blog', Icons.article, '/blog'),
                  _buildMobileMenuItem(
                    'Contact',
                    Icons.contact_mail,
                    '/contact',
                  ),
                  const Divider(height: 40),
                  _buildMobileMenuItem('Login', Icons.login, '/login'),
                  _buildMobileMenuItem(
                    'Get Started',
                    Icons.rocket_launch,
                    '/register',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4C6B3C)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF374151),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        GoRouter.of(context).go(route);
      },
    );
  }
}

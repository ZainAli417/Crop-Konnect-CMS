// dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constant/Map_Screen.dart';
import '../../Top_Side_Nav.dart';
import 'Dashboard_Provider.dart';

/// farmer_dashboard now wraps its ListView inside MainLayout with activeIndex = 0
class farmer_dashboard extends StatelessWidget {
  const farmer_dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider(
      create: (_) => JobProvider(),
      child: MainLayout(
        activeIndex: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Left Column
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ProfileCard(),
                      SizedBox(height: 40),

                      SizedBox(
                        height: 340,
                        child: map_screen(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),





// Replace your existing “Right Column” with this code:
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F8FA),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── AI Assistant Heading ───────────────────
                        Text(
                          'My Fields',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click on Any Farm to View Farm Details.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }
}


class _ProfileCard extends StatelessWidget {
  const _ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, Zain!',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Pick up Draw Tool from Top Bar and Plot your Farm boundaries',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

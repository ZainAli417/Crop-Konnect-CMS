import 'dart:async';
import 'dart:math'; // for scale calculation
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Screens/Job_Seeker/Dashboard_Provider.dart';

/// ─── map_screen (Horizontal) ─────────────────────────────────────────────
/// Displays a horizontal, infinite-looping, auto-scrolling list of job cards.
/// Shows exactly 3 cards in the viewport at once via `viewportFraction`,
/// with scaling animation on side cards (making them smaller) and
/// a slightly enlarged center card. Also includes dot indicators below.
class map_screen extends StatefulWidget {
  const map_screen({Key? key}) : super(key: key);

  @override
  State<map_screen> createState() => _map_screenState();
}

class _map_screenState extends State<map_screen> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  List<Job> get _jobs => context.read<JobProvider>().jobs;
  static const int _kLoopOffset = 1000;

  @override
  void initState() {
    super.initState();

    if (_jobs.isNotEmpty) {
      final initialPage = _jobs.length * _kLoopOffset;
      _pageController = PageController(
        initialPage: initialPage,
        viewportFraction: 0.33, // show exactly 3 cards at once
      );
      _currentPage = initialPage;

      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_jobs.isEmpty) return;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Fallback if no jobs are loaded yet
      _pageController = PageController(
        initialPage: 0,
        viewportFraction: 0.33,
      );
      _currentPage = 0;
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _jobs;
    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs available'));
    }

    return RepaintBoundary(
      child: Column(
        children: [
          // ─── Carousel ──────────────────────────────────
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, rawIndex) {
                final index = rawIndex % jobs.length;
                final job = jobs[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _CarouselCardScaleWrapper(
                    pageController: _pageController,
                    rawIndex: rawIndex,
                    child: _JobCardDetailed(job: job),
                  ),
                );
              },
            ),
          ),

          // ─── Dots Indicator ───────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(jobs.length, (i) {
                final isActive = (_currentPage % jobs.length) == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── _CarouselCardScaleWrapper ───────────────────────────────────────────
/// Wraps each job card in an AnimatedBuilder so that only that card
/// rebuilds/scales in response to scrolling, rather than the entire PageView.
class _CarouselCardScaleWrapper extends StatelessWidget {
  final PageController pageController;
  final int rawIndex;
  final Widget child;

  const _CarouselCardScaleWrapper({
    required this.pageController,
    required this.rawIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, __) {
        final pageValue = pageController.hasClients
            ? pageController.page ?? pageController.initialPage.toDouble()
            : pageController.initialPage.toDouble();
        final difference = (pageValue - rawIndex).abs();
        final scale = max(0.7, 1.0 - difference * 0.15);

        // Center the scaled card within a fixed-height box so that
        // vertical layout never shifts as scale changes
        return SizedBox(
          height: 300,
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: child, // prevents rebuilding the child subtree on every tick
    );
  }
}

/// ─── _JobCardDetailed (Rectangular, Rounded Corners, Elegant) ─────────────────────────
/// A single card showing job details, “Read More” & “Apply Now” buttons.
/// Uses a neutral palette, subtle shadows, and ensures that card content
/// is vertically scrollable if it exceeds the allotted height.
class _JobCardDetailed extends StatelessWidget {
  final Job job;
  const _JobCardDetailed({required this.job});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const textColor = Colors.black87;
    const secondaryTextColor = Color(0xFF5C738A);

    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width * 0.6, // matches viewportFraction * screen width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Ensure the full card content can scroll vertically if needed
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Header: Placeholder Logo + Title & Company (with "Full‐time" chip) ───
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder “logo” box (swap for NetworkImage if desired)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job Title
                            Text(
                              job.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Company Name and "Full‐time" chip in the same row
                            Row(
                              children: [
                                Text(
                                  job.company,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Full‐time',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Divider ───
                const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

                // ─── Body: Location & Salary + Description Label ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Salary row
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF5C738A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.location,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Color(0xFF5C738A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.salary,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description label
                      Text(
                        'Job Description:',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 12),
                      // ─── Buttons Row: Read More & Apply Now ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // “Read More” (outlined)
                          OutlinedButton(
                            onPressed: () {
                              // TODO: Navigate to detailed view
                            },
                            style: ButtonStyle(
                              side: WidgetStateProperty.all(
                                BorderSide(color: primaryColor),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                              ),
                            ),
                            child: Text(
                              'Read More',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),

                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to full profile page if needed:
                              // context.go('/profile');
                            },
                            child: Text(
                              'Apply Now',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ─── Placeholder for the Profile Card ─────────────────────────────────────
/// This would be your actual profile‐card widget. Replace with your own.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example static placeholder:
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'John Doe',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Flutter Developer',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          // Add whatever other profile details you need here...
        ],
      ),
    );
  }
}
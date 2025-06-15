import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmListItem extends StatefulWidget {
  final dynamic farm;
  final VoidCallback onTap;

  const FarmListItem({super.key, required this.farm, required this.onTap});

  @override
  State<FarmListItem> createState() => _FarmListItemState();
}

class _FarmListItemState extends State<FarmListItem>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _backgroundAnimation;

  bool _isHovered = false;
  String _selectedAreaUnit = 'ha';

  // Color palette
  static const Color _primaryGreen = Color(0xFF4C6B3C);
  static const Color _accentGreen = Color(0xFF5A691A);
  static const Color _backgroundColor = Color(0xFFF9F6F1);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with optimized durations
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Create smooth animations
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundAnimation = ColorTween(
      begin: _surfaceColor,
      end: _surfaceColor.withOpacity(0.95),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (!_isHovered) {
      setState(() => _isHovered = true);
      _hoverController.forward();
      // Subtle haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  void _onHoverExit() {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    _tapController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _tapController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (1.0 - _tapController.value * 0.02),
          child: SizedBox(
            width: double.infinity,
            height: 120,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: BorderRadius.circular(16),
              color: _backgroundAnimation.value,
              shadowColor: _primaryGreen.withOpacity(0.2),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(12),
                splashColor: _primaryGreen.withOpacity(0.1),
                highlightColor: _primaryGreen.withOpacity(0.05),
                child: MouseRegion(
                  onEnter: (_) => _onHoverEnter(),
                  onExit: (_) => _onHoverExit(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isHovered
                            ? _primaryGreen.withOpacity(0.6)
                            : Colors.grey.shade200,
                        width: _isHovered ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Compact Farm Preview
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _primaryGreen.withOpacity(0.1),
                            border: Border.all(
                              color: _primaryGreen.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: FarmPolygonPreview(
                              coordinates: widget.farm.coordinates,
                              size: 38,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Main Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Farm Name
                              Text(
                                widget.farm.name ?? "Farm Name",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                  letterSpacing: -0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              // Farm ID & Area in one row
                              Column(
                                children: [
                                  // Farm ID
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "ID: ${widget.farm.id ?? "N/A"}",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: _primaryGreen,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
Row(
  children: [
                                  // Area with Unit Selector
                                  Icon(
                                    Icons.rectangle_outlined,
                                    size: 14,
                                    color: _textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatArea(widget.farm.area, _selectedAreaUnit)
                                        .split(' ')
                                        .first,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _primaryGreen,
                                    ),
                                  ),

                                  const SizedBox(width: 6),
                                  _buildCompactUnitSelector(),
    ]
),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Chevron with subtle animation
                        AnimatedRotation(
                          turns: _isHovered ? 0.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isHovered
                                  ? _primaryGreen.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: _isHovered ? _primaryGreen : _textSecondary,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildCompactUnitSelector() {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _primaryGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAreaUnit,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 12,
            color: _primaryGreen,
          ),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _primaryGreen,
          ),
          dropdownColor: _surfaceColor,
          borderRadius: BorderRadius.circular(6),
          items: ['ha', 'ac'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primaryGreen,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (newUnit) {
            if (newUnit != null) {
              setState(() {
                _selectedAreaUnit = newUnit;
              });
              HapticFeedback.selectionClick();
            }
          },
        ),
      ),
    );
  }
}

// Enhanced area formatting function
String _formatArea(double area, String unit) {
  switch (unit) {
    case 'ha':
      final converted = area / 10000;
      return '${converted.toStringAsFixed(2)} ha';
    case 'ac':
      final converted = area * 0.000247105;
      return '${converted.toStringAsFixed(2)} ac';
    default:
      return '${area.toStringAsFixed(2)} m²';
  }
}

class FarmPolygonPreview extends StatelessWidget {
  final List<LatLng> coordinates;
  final double size;

  const FarmPolygonPreview({
    super.key,
    required this.coordinates,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9F6F1),
            Colors.grey.shade50,
          ],
        ),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _EnhancedPolygonPainter(coordinates),
      ),
    );
  }
}

class _EnhancedPolygonPainter extends CustomPainter {
  final List<LatLng> coordinates;

  _EnhancedPolygonPainter(this.coordinates);

  @override
  void paint(Canvas canvas, Size size) {
    if (coordinates.isEmpty) {
      // Draw placeholder
      _drawPlaceholder(canvas, size);
      return;
    }

    // Calculate bounding box with padding
    final bounds = _calculateBounds();
    if (bounds == null) return;

    final path = _createPolygonPath(bounds, size);

    // Draw with modern styling
    _drawPolygon(canvas, path);
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4C6B3C).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.2,
          size.width * 0.6, size.height * 0.6),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, paint);
  }

  Map<String, double>? _calculateBounds() {
    if (coordinates.isEmpty) return null;

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      minLat = minLat < coord.latitude ? minLat : coord.latitude;
      maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
      minLng = minLng < coord.longitude ? minLng : coord.longitude;
      maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
    }

    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    // Ensure minimum range to avoid division by zero
    if (latRange == 0) latRange = 0.001;
    if (lngRange == 0) lngRange = 0.001;

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
      'latRange': latRange,
      'lngRange': lngRange,
    };
  }

  Path _createPolygonPath(Map<String, double> bounds, Size size) {
    final path = Path();
    const padding = 6.0; // Padding from edges
    final drawSize = Size(size.width - padding * 2, size.height - padding * 2);

    for (int i = 0; i < coordinates.length; i++) {
      final normalizedX = (coordinates[i].longitude - bounds['minLng']!) / bounds['lngRange']!;
      final normalizedY = (coordinates[i].latitude - bounds['minLat']!) / bounds['latRange']!;

      final x = padding + normalizedX * drawSize.width;
      final y = padding + drawSize.height - normalizedY * drawSize.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  void _drawPolygon(Canvas canvas, Path path) {
    // Fill with gradient effect
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4C6B3C),
          Color(0xFF5A691A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, 60, 60))
      ..style = PaintingStyle.fill;

    // Stroke with clean lines
    final strokePaint = Paint()
      ..color = const Color(0xFF4C6B3C)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
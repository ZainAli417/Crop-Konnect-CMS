// dashboard.dart - Enhanced with modern UX and animations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constant/Map_Screen.dart';
import '../../Constant/farm_list_view.dart';
import '../../Constant/map_screen_provider.dart';
import '../../Top_Side_Nav.dart';

/// Enhanced farmer dashboard with modern UX and smooth animations
class device_registration extends StatefulWidget {
  const device_registration({super.key});

  @override
  State<device_registration> createState() => device_registrationState();
}

class device_registrationState extends State<device_registration>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _welcomeController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  // Color palette with modern gradients
  static const Color _primaryGreen = Color(0xFF4C6B3C);
  static const Color _accentGreen = Color(0xFF5A691A);
  static const Color _backgroundColor = Color(0xFFF9F6F1);
  static const Color _surfaceColor = Colors.white;
  static const Color _cardBackground = Color(0xFFF5F8FA);
  static const List<Color> _gradientColors = [
    Color(0xFF4C6B3C),
    Color(0xFF5A691A),
    Color(0xFF6B7B2A),
  ];

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

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pageController.forward();
    _welcomeController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _welcomeController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapDrawingProvider(),
      child: MainLayout(
        activeIndex: 1,
        child: AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildDeviceregistration(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeviceregistration(BuildContext context) {
    return ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Stack(
          children: [
            // Animated background gradient
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildEnhancedHeader(),
                    const SizedBox(height: 20),

                    // Enhanced Product List
                    Expanded(
                      child: Consumer<CartProvider>(
                        builder: (context, cart, _) {
                          return AnimatedList(
                            initialItemCount: dummyLoggers.length,
                            itemBuilder: (context, idx, animation) {
                              if (idx >= dummyLoggers.length) return SizedBox.shrink();

                              final logger = dummyLoggers[idx];
                              return SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                                ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: EnhancedDataLoggerCard(
                                    logger: logger,
                                    selectedSensors: cart.selectedSensors[logger.id] ?? 0,
                                    onSensorChanged: (count) {
                                      HapticFeedback.lightImpact();
                                      cart.updateSensorCount(logger.id, count);
                                    },
                                    onAddToCart: () {
                                      HapticFeedback.mediumImpact();
                                      cart.addToCart(logger);
                                      _showAddToCartAnimation(context);
                                    },
                                    animationDelay: Duration(milliseconds: idx * 100),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Enhanced Checkout Bar
                    Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          height: cart.items.isEmpty ? 0 : 80,
                          child: AnimatedOpacity(
                            opacity: cart.items.isEmpty ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: _buildEnhancedCheckoutBar(cart),
                          ),
                        );
                      },
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _backgroundColor,
                _backgroundColor.withOpacity(0.8),
                Color(0xFFF0F4F8).withOpacity(0.6),
              ],
              stops: [
                0.0,
                0.5 + (_floatingAnimation.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            painter: FloatingShapesPainter(_floatingAnimation.value),
            child: Container(),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.sensors,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Data Loggers',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Choose the perfect monitoring system',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _floatingAnimation,
            child: Icon(Icons.trending_up, color: Colors.white, size: 24),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value * 4),
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCheckoutBar(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${cart.items.length} item${cart.items.length > 1 ? 's' : ''} in Cart',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Ready for deployment',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // TODO: Navigate to checkout with animation
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Checkout',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => AddToCartAnimationWidget(),
    );
  }
}

class EnhancedDataLoggerCard extends StatefulWidget {
  final DataLogger logger;
  final int selectedSensors;
  final ValueChanged<int> onSensorChanged;
  final VoidCallback onAddToCart;
  final Duration animationDelay;

  const EnhancedDataLoggerCard({
    required this.logger,
    required this.selectedSensors,
    required this.onSensorChanged,
    required this.onAddToCart,
    this.animationDelay = Duration.zero,
  });

  @override
  State<EnhancedDataLoggerCard> createState() => _EnhancedDataLoggerCardState();
}

class _EnhancedDataLoggerCardState extends State<EnhancedDataLoggerCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.selectedSensors > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EnhancedDataLoggerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSensors > 0 && oldWidget.selectedSensors == 0) {
      _pulseController.repeat(reverse: true);
    } else if (widget.selectedSensors == 0 && oldWidget.selectedSensors > 0) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
                if (widget.selectedSensors > 0)
                  BoxShadow(
                    color: const Color(0xFF4C6B3C).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
              ],
              border: widget.selectedSensors > 0
                  ? Border.all(
                color: const Color(0xFF4C6B3C).withOpacity(0.5),
                width: 2,
              )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _isHovered = !_isHovered;
                  });
                  if (_isHovered) {
                    _hoverController.forward();
                  } else {
                    _hoverController.reverse();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(),
                      const SizedBox(height: 12),
                      _buildDescription(),
                      const SizedBox(height: 16),
                      _buildSensorChips(),
                      const SizedBox(height: 20),
                      _buildActionRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C6B3C), Color(0xFF5A691A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sensors,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.logger.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C6B3C), Color(0xFF5A691A)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '\$${widget.logger.price.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.logger.description,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.black54,
        height: 1.4,
      ),
    );
  }

  Widget _buildSensorChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Sensors:',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.logger.sensors.asMap().entries.map((entry) {
            final index = entry.key;
            final sensor = entry.value;
            final isActive = index < widget.selectedSensors;

            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.elasticOut,
              child: Chip(
                label: Text(
                  sensor,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.black54,
                  ),
                ),
                backgroundColor: isActive
                    ? const Color(0xFF4C6B3C)
                    : Colors.grey.shade100,
                side: BorderSide(
                  color: isActive
                      ? const Color(0xFF4C6B3C)
                      : Colors.grey.shade300,
                ),
                avatar: isActive
                    ? Icon(Icons.check_circle, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _buildSensorSelector(),
        const Spacer(),
        _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildSensorSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSelectorButton(
            icon: Icons.remove,
            onPressed: widget.selectedSensors > 0
                ? () => widget.onSensorChanged(widget.selectedSensors - 1)
                : null,
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${widget.selectedSensors}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildSelectorButton(
            icon: Icons.add,
            onPressed: widget.selectedSensors < widget.logger.sensors.length
                ? () => widget.onSensorChanged(widget.selectedSensors + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: onPressed != null ? const Color(0xFF4C6B3C) : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    final isEnabled = widget.selectedSensors > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
          colors: [Color(0xFF4C6B3C), Color(0xFF5A691A)],
        )
            : null,
        color: isEnabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
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
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled ? widget.onAddToCart : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_shopping_cart,
                  color: isEnabled ? Colors.white : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add to Cart',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.white : Colors.grey,
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

class AddToCartAnimationWidget extends StatefulWidget {
  @override
  _AddToCartAnimationWidgetState createState() => _AddToCartAnimationWidgetState();
}

class _AddToCartAnimationWidgetState extends State<AddToCartAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C6B3C), Color(0xFF5A691A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C6B3C).withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloatingShapesPainter extends CustomPainter {
  final double animationValue;

  FloatingShapesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4C6B3C).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw floating circles
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        (size.width * 0.2) + (i * size.width * 0.2),
        (size.height * 0.3) + (animationValue * 20) + (i * 15),
      );
      canvas.drawCircle(offset, 30 + (animationValue * 10), paint);
    }

    // Draw floating rectangles
    paint.color = const Color(0xFF5A691A).withOpacity(0.03);
    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: Offset(
          size.width * 0.8,
          (size.height * 0.6) + (animationValue * -15) + (i * 50),
        ),
        width: 40,
        height: 40,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
class DataLogger {
  final String id;
  final String name;
  final String description;
  final List<String> sensors;
  final double price;

  DataLogger({
    required this.id,
    required this.name,
    required this.description,
    required this.sensors,
    required this.price,
  });
}

// Dummy catalog
final List<DataLogger> dummyLoggers = [
  DataLogger(
    id: 'dl1',
    name: 'AgriLogger 2000',
    description: 'Logs soil moisture, temperature, and humidity in real time.',
    sensors: ['Soil Moisture', 'Temp Sensor', 'Humidity Sensor'],
    price: 149.99,
  ),
  DataLogger(
    id: 'dl2',
    name: 'WaterWatch X',
    description: 'Specialized for water quality monitoring with pH and turbidity sensors.',
    sensors: ['pH Sensor', 'Turbidity Sensor'],
    price: 199.99,
  ),
  DataLogger(
    id: 'dl3',
    name: 'ClimateTrack Pro',
    description: 'Industrial-grade logger with CO₂, temp, humidity, and pressure sensors.',
    sensors: ['CO₂ Sensor', 'Pressure Sensor', 'Temp Sensor', 'Humidity Sensor'],
    price: 249.99,
  ),
];

class DataLoggerCard extends StatelessWidget {
  final DataLogger logger;
  final int selectedSensors;
  final ValueChanged<int> onSensorChanged;
  final VoidCallback onAddToCart;

  const DataLoggerCard({
    required this.logger,
    required this.selectedSensors,
    required this.onSensorChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  logger.name,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${logger.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              logger.description,
              style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Sensors list
            Text(
              'Available Sensors:',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 8,
              children: logger.sensors
                  .map((s) => Chip(label: Text(s, style: GoogleFonts.quicksand())))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Sensor selector + Add to cart
            Row(
              children: [
                // Sensor count selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: selectedSensors > 0 ? () => onSensorChanged(selectedSensors - 1) : null,
                      ),
                      Text(
                        '$selectedSensors',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: selectedSensors < logger.sensors.length
                            ? () => onSensorChanged(selectedSensors + 1)
                            : null,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: selectedSensors > 0 ? onAddToCart : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Add to Cart', style: GoogleFonts.quicksand(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartProvider extends ChangeNotifier {
  // Map of loggerId → count of sensors selected
  final Map<String, int> selectedSensors = {};

  // Simple list of items “in cart”
  final List<DataLogger> items = [];

  void updateSensorCount(String loggerId, int count) {
    selectedSensors[loggerId] = count;
    notifyListeners();
  }

  void addToCart(DataLogger logger) {
    if (!items.contains(logger)) {
      items.add(logger);
      notifyListeners();
    }
  }
}



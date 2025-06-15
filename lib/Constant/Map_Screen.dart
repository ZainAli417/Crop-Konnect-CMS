import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'farm_list_view.dart';
import 'map_screen_provider.dart';

class Map_Screen extends StatefulWidget {
  const Map_Screen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<Map_Screen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // Animation controllers for smooth transitions
  late AnimationController _overlayController;
  late AnimationController _mapController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _mapAnimation;

  bool _showOverlay = true;
  bool _isMapReady = false;
  GoogleMapController? mapController;

  // Performance optimization: Singleton places instance
  static final places = GoogleMapsPlaces(
      apiKey: "AIzaSyBqEb5qH08mSFysEOfSTIfTezbhJjJZSRs"
  );

  @override
  bool get wantKeepAlive => true; // Keep state alive for performance

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Overlay fade animation
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );

    // Map reveal animation
    _mapController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _mapAnimation = CurvedAnimation(
      parent: _mapController,
      curve: Curves.easeOutCubic,
    );

    _overlayController.forward();
  }

  void _startLoadingSequence() {
    // Simulate map loading with graceful transitions
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isMapReady = true);
        _mapController.forward();

        // Start overlay fade out after map is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _overlayController.reverse().then((_) {
              if (mounted) {
                setState(() => _showOverlay = false);
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Stack(
        children: [
          // Main content with fade-in animation
          AnimatedBuilder(
            animation: _mapAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _mapAnimation.value,
                child: Transform.scale(
                  scale: 0.95 + (0.05 * _mapAnimation.value),
                  child: _buildMainContent(),
                ),
              );
            },
          ),

          // Loading overlay with fade animation
          if (_showOverlay)
            AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _overlayAnimation.value,
                  child: _buildLoadingOverlay(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _buildMapContainer(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapContainer() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            // Background placeholder while map loads
            if (!_isMapReady)
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6B3C)),
                  ),
                ),
              ),

            // Optimized Google Map
            _buildOptimizedMap(),

            // Map controls overlay
            _buildMapControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedMap() {
    return Selector<MapDrawingProvider, _MapState>(
      selector: (context, provider) => _MapState(
        toolSelected: provider.toolSelected,
        currentTool: provider.currentTool,
        isDrawing: provider.isDrawing,
        mapType: provider.mapType,
        initialPoint: provider.initialPoint,
      ),
      builder: (context, mapState, child) {
        return _OptimizedMapGestureHandler(
          child: Consumer<MapDrawingProvider>(
            builder: (context, provider, child) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: mapState.initialPoint,
                  zoom: 15, // Reduced initial zoom for faster loading
                ),
                // Performance optimizations
                liteModeEnabled: false, // Keep interactive for drawing
                trafficEnabled: false,
                buildingsEnabled: true,
                indoorViewEnabled: false,

                // Gesture controls based on current tool
                scrollGesturesEnabled: provider.isMapInteractionAllowed(),
                rotateGesturesEnabled: provider.isMapInteractionAllowed(),
                tiltGesturesEnabled: provider.isMapInteractionAllowed(),
                zoomGesturesEnabled: provider.isMapInteractionAllowed(),

                // UI controls
                myLocationButtonEnabled: false, // We'll create custom button
                myLocationEnabled: true,
                compassEnabled: false, // Custom compass

                // Map overlays - only rebuild when necessary
                polygons: provider.allPolygons,
                polylines: provider.allPolylines,
                markers: provider.allMarkers,
                circles: provider.allCircles,
                mapType: mapState.mapType,

                onTap: (latLng) {
                  if (mapState.currentTool == "marker") {
                    provider.addMarkerAndUpdatePolyline(context, latLng);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 30,
      left: 20,
      child: Column(
        children: [
          // Map type selector with smooth animation
          _buildAnimatedMapControl(
            icon: Icons.layers,
            onTap: () => _showMapTypeSelector(context),
            tooltip: 'Map Layers',
          ),
          const SizedBox(height: 12),

          // My location button
          _buildAnimatedMapControl(
            icon: Icons.my_location,
            onTap: _goToMyLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMapControl({
    dynamic icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: onTap,
                child: Tooltip(
                  message: tooltip,
                  child: Center(
                    child: icon is IconData
                        ? Icon(icon, size: 24, color:Color(0xFF4C6B3C))
                        : Image.asset(
                      icon,
                      width: 24,
                      height: 24,

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

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Optimized Lottie animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'images/loading.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: _showOverlay,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Farms...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch your location',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final provider = Provider.of<MapDrawingProvider>(context, listen: false);
    provider.setMapController(context, controller);

    // Animate to user location after map is ready
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(provider.initialPoint, 16),
      );
    }
  }

  void _goToMyLocation() async {
    final provider = Provider.of<MapDrawingProvider>(context, listen: false);
    if (provider.mapController != null) {
      await provider.mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(provider.initialPoint, 18),
      );
    }
  }

  void _showMapTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMapTypeBottomSheet(),
    );
  }

  Widget _buildMapTypeBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Map Style',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                Consumer<MapDrawingProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: provider.mapTypes.map((mapType) {
                        final isSelected = provider.mapType == mapType;
                        final typeName = mapType.toString().split('.').last;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[50] : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Color(0xFF4C6B3C) : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isSelected ? Icons.check_circle : Icons.map,
                              color: isSelected ? Color(0xFF4C6B3C) : Colors.grey[600],
                            ),
                            title: Text(
                              typeName.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.inter(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Color(0xFF4C6B3C) : Colors.grey[700],
                              ),
                            ),
                            onTap: () {
                              provider.setMapType(mapType);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Optimized gesture handler to reduce rebuilds
class _OptimizedMapGestureHandler extends StatefulWidget {
  final Widget child;

  const _OptimizedMapGestureHandler({required this.child});

  @override
  State<_OptimizedMapGestureHandler> createState() => _OptimizedMapGestureHandlerState();
}

class _OptimizedMapGestureHandlerState extends State<_OptimizedMapGestureHandler> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }

  void _onPanStart(DragStartDetails details) async {
    final provider = Provider.of<MapDrawingProvider>(context, listen: false);
    if (provider.toolSelected && provider.mapController != null) {
      try {
        final point = await provider.mapController!.getLatLng(
          ScreenCoordinate(
            x: details.localPosition.dx.toInt(),
            y: details.localPosition.dy.toInt(),
          ),
        );
        provider.startDrawing(provider.currentTool, point);
      } catch (e) {
        debugPrint("Error getting LatLng: $e");
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) async {
    final provider = Provider.of<MapDrawingProvider>(context, listen: false);
    if (provider.isDrawing && provider.mapController != null) {
      try {
        final point = await provider.mapController!.getLatLng(
          ScreenCoordinate(
            x: details.localPosition.dx.toInt(),
            y: details.localPosition.dy.toInt(),
          ),
        );
        provider.updateDrawing(point);
      } catch (e) {
        debugPrint("Error updating drawing: $e");
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final provider = Provider.of<MapDrawingProvider>(context, listen: false);
    if (provider.isDrawing) {
      provider.finalizeDrawing(context);
    }
  }
}

// State class for efficient Selector usage
class _MapState {
  final bool toolSelected;
  final String currentTool;
  final bool isDrawing;
  final MapType mapType;
  final LatLng initialPoint;

  _MapState({
    required this.toolSelected,
    required this.currentTool,
    required this.isDrawing,
    required this.mapType,
    required this.initialPoint,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _MapState &&
              runtimeType == other.runtimeType &&
              toolSelected == other.toolSelected &&
              currentTool == other.currentTool &&
              isDrawing == other.isDrawing &&
              mapType == other.mapType &&
              initialPoint == other.initialPoint;

  @override
  int get hashCode =>
      toolSelected.hashCode ^
      currentTool.hashCode ^
      isDrawing.hashCode ^
      mapType.hashCode ^
      initialPoint.hashCode;
}
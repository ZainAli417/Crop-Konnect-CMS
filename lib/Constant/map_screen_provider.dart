import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turf/turf.dart' as turf;
import '../geoflutter/src/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

class MapDrawingProvider with ChangeNotifier {
  GoogleMapController? mapController;
  bool isDrawing = false;
  bool _toolSelected = false;
  String currentTool = "hand";
  LatLng? initialPointForDrawing;
  final Geoflutterfire geo = Geoflutterfire();

  // UI and state management
  bool isFarmSelected = false;
  FarmPlot? selectedFarm;
  final TextEditingController farmNameController = TextEditingController();
  LatLng initialPoint = const LatLng(37.7749, -122.4194);
  bool isMapInteractionAllowed() => !isFarmSelected && !_toolSelected;

  // Drawing state
  bool isLoading = false;
  LatLng? currentDragPoint;
  List<Polygon> polygons = [];
  List<Circle> circles = [];
  List<Marker> markers = [];
  List<LatLng> polylinePoints = [];
  List<Polyline> polylines = [];
  List<LatLng> currentPolygonPoints = [];
  double circleRadius = 0.0;
  List<FarmPlot> farms = [];

  bool get toolSelected => _toolSelected;
  final List<Polygon> _tempPolygons = [];
  final List<Marker> _tempMarkers = [];
  List<LatLng> currentPolylinePoints = [];

  Set<Marker> get allMarkers => {...markers, ..._tempMarkers};
  String _selectedAreaUnit = 'ha';
  String get selectedAreaUnit => _selectedAreaUnit;

  final List<Polyline> _tempPolylines = [];
  bool isFarmDetailsVisible = false;
  bool _isBottomSheetOpen = false;
  bool get isBottomSheetOpen => _isBottomSheetOpen;
  MapType _mapType = MapType.satellite;
  MapType get mapType => _mapType;
  final List<MapType> mapTypes = [MapType.normal, MapType.satellite, MapType.hybrid];

  
  
  
  Set<Polygon> get allPolygons => {
    ...polygons,
    if (isDrawing && (currentTool == "rectangle" || currentTool == "freehand"))
      Polygon(
        polygonId: const PolygonId('preview'),
        points: currentPolygonPoints,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
  };
  Set<Polyline> get allPolylines {
    final Set<Polyline> lines = {...polylines};

    if (currentTool == "marker") {
      if (currentPolylinePoints.length > 1) {
        lines.add(
          Polyline(
            polylineId: const PolylineId('preview_marker'),
            points: currentPolylinePoints,
            color: Colors.blue.withOpacity(0.3),
            width: 2,
            patterns: [PatternItem.dot],
          ),
        );
      }

      if (currentPolylinePoints.isNotEmpty && currentDragPoint != null) {
        lines.add(
          Polyline(
            polylineId: const PolylineId('preview_drag'),
            points: [currentPolylinePoints.last, currentDragPoint!],
            color: Colors.blue.withOpacity(0.3),
            width: 2,
            patterns: [PatternItem.dot],
          ),
        );
      }
    }

    if (isDrawing &&
        (currentTool == "rectangle" || currentTool == "freehand") &&
        currentPolygonPoints.isNotEmpty) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('preview_polygon'),
          points: currentPolygonPoints,
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      );
    }

    return lines;
  }
  Set<Circle> get allCircles => {
    ...circles,
    if (isDrawing &&
        currentTool == "circle" &&
        initialPointForDrawing != null)
      Circle(
        circleId: const CircleId('preview'),
        center: initialPointForDrawing!,
        radius: circleRadius,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
  };


  void setMapController(BuildContext context, GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(poistyle);
    loadFarms(context);
    getCurrentLocation();
  }
  static const String poistyle = '''
[
  {
    "featureType": "poi",
    "elementType": "labels",
    "stylers": [
      { "visibility": "off" }
    ]
  }
]
''';
  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      isLoading = false;
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        debugPrint("Location permissions are permanently denied.");
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    initialPoint = LatLng(position.latitude, position.longitude);
    await Future.delayed(const Duration(seconds: 2));
    animateCameraTo(initialPoint);

    isLoading = false;
    notifyListeners();
  }
  void animateCameraTo(LatLng latLng) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 20),
        ),
      );
    }
  }
  void setMapType(MapType newMapType) {
    _mapType = newMapType;
    notifyListeners();
  }
  void setBottomSheetOpen(bool value) {
    _isBottomSheetOpen = value;
    notifyListeners();
  }

  Future<void> register_farm(BuildContext context) async {
    final provider = Provider.of<MapDrawingProvider>(context, listen: false);
    provider.setBottomSheetOpen(true);
    final area = _calculatePolygonArea(currentPolygonPoints);
    final farmId = 'FARM-${DateTime.now().millisecondsSinceEpoch}';
    final TextEditingController controller = TextEditingController();

    String tempFarmName = '';

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Save Farm",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: const Color(0xFF643905),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: controller,
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: "Farm Name",
                          labelStyle: GoogleFonts.quicksand(
                              color: const Color(0xFF5D4037),
                              fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Color(0xFF643905)),
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        cursorColor: const Color(0xFF643905),
                        onChanged: (v) {
                          setState(() {
                            tempFarmName = v;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _FarmDetailsRow(title: "Farm ID:", value: farmId),
                      _FarmDetailsRow(
                          title: "Area:",
                          value: _formatArea(area, selectedAreaUnit)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              clearCurrentFarm();
                              Navigator.pop(context);
                              _resetToolSelection();
                              notifyListeners();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF757575),
                            ),
                            child: Text("Discard",
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w700)),
                          ),
                          ElevatedButton(
                            onPressed: tempFarmName.isNotEmpty
                                ? () {
                              _saveFarmPlot(context, farmId, area, tempFarmName);
                              polygons.addAll(_tempPolygons);
                              markers.addAll(_tempMarkers);
                              _tempPolygons.clear();
                              _tempMarkers.clear();
                              Navigator.pop(context);
                              _resetToolSelection();
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF643905),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            child: Text("Save",
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    provider.setBottomSheetOpen(false);
    _resetToolSelection();
  }



  void loadFarms(BuildContext context) {
    FarmPlot.loadFarms().listen((loadedFarms) async {
      farms.clear();
      if (loadedFarms.isNotEmpty) {
        farms.addAll(loadedFarms);
      }

      polygons.clear();
      markers.clear();

      for (var farm in farms) {
        polygons.add(
          Polygon(
            polygonId: PolygonId(farm.id),
            points: farm.coordinates,
            fillColor: Colors.green.withOpacity(0.3),
            strokeColor: Colors.green,
            strokeWidth: 3,
            consumeTapEvents: true,
            onTap: () => selectFarm(farm),
          ),
        );
        await _addFarmMarker(context, farm);
      }
      notifyListeners();
    });
  }

  void finalizePolylineAndCreateFarm(BuildContext context) {
    if (currentPolylinePoints.length < 3) return;

    List<LatLng> polygonPoints = List.from(currentPolylinePoints)
      ..add(currentPolylinePoints.first);

    double area = _calculatePolygonArea(polygonPoints);
    final geoPoint = geo.point(
      latitude: polygonPoints.first.latitude,
      longitude: polygonPoints.first.longitude,
    );

    FarmPlot farm = FarmPlot(
      id: 'farm_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Farm ${farms.length + 1}',
      area: area,
      coordinates: polygonPoints,
      createdAt: DateTime.now(),
      geoHash: geoPoint.hash,
    );

    farms.add(farm);

    polygons.add(
      Polygon(
        polygonId: PolygonId(farm.id),
        points: polygonPoints,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.4),
        strokeWidth: 3,
      ),
    );

    _addFarmMarker(context, farm);

    currentPolylinePoints.clear();
    polylines.clear();
    notifyListeners();
  }

  Future<void> _closeAndFillPolygon(BuildContext context) async {
    List<LatLng> closedPolygon = List.from(currentPolylinePoints)
      ..add(currentPolylinePoints.first);
    currentPolygonPoints = closedPolygon;

    _tempPolygons.add(
      Polygon(
        polygonId: PolygonId(DateTime.now().toString()),
        points: closedPolygon,
        fillColor: Colors.redAccent.withOpacity(0.4),
        strokeColor: Colors.red,
        strokeWidth: 3,
      ),
    );

    await register_farm(context);

    markers.addAll(_tempMarkers);
    polylines.addAll(_tempPolylines);

    if (farms.isNotEmpty) {
      FarmPlot lastFarm = farms.last;
      await _addFarmMarker(context, lastFarm, markerAsset: 'images/farmer.png');
    }

    _tempMarkers.clear();
    _tempPolylines.clear();
    currentPolylinePoints.clear();
    currentDragPoint = null;
    currentTool = '';
    notifyListeners();
  }

  Future<void> _saveFarmPlot(BuildContext context, String id, double area, String cropName) async {
    if (currentPolygonPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No coordinates found for the farm!")),
      );
      return;
    }

    try {
      final newFarm = FarmPlot(
        id: id,
        name: cropName,
        area: area,
        coordinates: List.from(currentPolygonPoints),
        createdAt: DateTime.now(),
        geoHash: geo.point(
          latitude: currentPolygonPoints.first.latitude,
          longitude: currentPolygonPoints.first.longitude,
        ).hash,
      );

      final farmDocRef = FirebaseFirestore.instance
          .collection('user_info')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('farms')
          .doc(id);

      await farmDocRef.set(newFarm.toMap());

      _resetToolSelection();
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving farm: ${e.toString()}')),
      );
    }
  }

  Future<void> _addFarmMarker(BuildContext context, FarmPlot farm, {String markerAsset = 'images/farmer.png'}) async {
    LatLng center = _calculateCentroid(farm.coordinates);

    BitmapDescriptor customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(50, 60)),
      markerAsset,
    );

    markers.add(
      Marker(
        markerId: MarkerId('farm_center_${farm.id}'),
        position: center,
        icon: customIcon,
        infoWindow: const InfoWindow(title: '', snippet: ''),
        onTap: () {
          final mapProvider = Provider.of<MapDrawingProvider>(context, listen: false);
          if (mapProvider.isBottomSheetOpen) return;
          _showCustomInfoWindow(context, farm);
        },
      ),
    );
  }

  void _showCustomInfoWindow(BuildContext context, FarmPlot farm) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 5,
        backgroundColor: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    farm.name,
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.quicksand(
                      fontSize: 16, color: Colors.black87, height: 1.4),
                  children: [
                    TextSpan(
                      text: "Farm Area: ",
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF555555)),
                    ),
                    TextSpan(text: "${_formatArea(farm.area, 'ha')}\n"),
                    const TextSpan(text: "\n"),
                    TextSpan(
                      text: "Farm ID: ",
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF555555)),
                    ),
                    TextSpan(text: "${farm.id}\n"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    double totalLat = 0;
    double totalLng = 0;
    for (var point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }
    return LatLng(totalLat / points.length, totalLng / points.length);
  }

  void addMarkerAndUpdatePolyline(BuildContext context, LatLng point) {
    if (currentTool != "marker") return;

    final String markerIdValue = 'temp_marker_${DateTime.now().millisecondsSinceEpoch}';
    final MarkerId markerId = MarkerId(markerIdValue);

    if (currentPolylinePoints.isEmpty) {
      currentPolylinePoints.add(point);
      _tempMarkers.add(
        Marker(
          markerId: markerId,
          position: point,
          onTap: () {
            if (currentPolylinePoints.isNotEmpty && point == currentPolylinePoints.first) {
              _closeAndFillPolygon(context);
            }
          },
        ),
      );
      notifyListeners();
      return;
    }

    final firstPoint = currentPolylinePoints.first;
    if (point == firstPoint) {
      _closeAndFillPolygon(context);
      return;
    }

    currentPolylinePoints.add(point);
    _tempMarkers.add(
      Marker(
        markerId: markerId,
        position: point,
      ),
    );

    _updatePolylines();
    currentDragPoint = null;
    notifyListeners();
  }

  void clearCurrentFarm() {
    currentPolygonPoints.clear();
    currentPolylinePoints.clear();
    _tempMarkers.clear();
    _tempPolylines.clear();

    markers.removeWhere((marker) => marker.markerId.value.startsWith('temp_marker_'));

    isDrawing = false;
    notifyListeners();
  }

  void _updatePolylines() {
    _tempPolylines.removeWhere((line) => line.polylineId.value.startsWith('temp_polyline_'));

    if (currentTool == "marker" &&
        currentPolylinePoints.isNotEmpty &&
        currentDragPoint != null) {
      _tempPolylines.add(
        Polyline(
          polylineId: PolylineId('temp_polyline_${DateTime.now().millisecondsSinceEpoch}'),
          points: [currentPolylinePoints.last, currentDragPoint!],
          color: Colors.blue,
          width: 2,
          patterns: [PatternItem.dash(2)],
        ),
      );
    }

    if (isDrawing &&
        (currentTool == "rectangle" || currentTool == "freehand") &&
        currentPolygonPoints.isNotEmpty) {
      _tempPolylines.removeWhere((line) => line.polylineId.value == 'temp_polyline_preview');
      _tempPolylines.add(
        Polyline(
          polylineId: const PolylineId('temp_polyline_preview'),
          points: currentPolygonPoints,
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      );
    }

    notifyListeners();
  }

  void setCurrentTool(String tool) {
    if (tool == "hand") {
      isDrawing = false;
      _toolSelected = false;
      currentTool = "hand";
    } else {
      currentTool = tool;
      _toolSelected = true;
    }
    notifyListeners();
  }

  void startDrawing(String tool, LatLng point) {
    isDrawing = true;
    currentTool = tool;
    initialPointForDrawing = point;
    currentPolygonPoints.clear();
    if (tool == "marker") polylinePoints.clear();
    notifyListeners();
  }

  void updateDrawing(LatLng point) {
    currentDragPoint = point;
    switch (currentTool) {
      case "circle":
        circleRadius = _calculateDistance(initialPointForDrawing!, currentDragPoint!);
        break;
      case "rectangle":
        currentPolygonPoints = _getRectanglePoints(initialPointForDrawing!, currentDragPoint!);
        break;
      case "freehand":
        currentPolygonPoints.add(point);
        break;
      case "marker":
        if (polylinePoints.isNotEmpty) polylinePoints.add(point);
        break;
    }
    notifyListeners();
  }

  void finalizeDrawing(BuildContext context) {
    if ((currentTool == "rectangle" ||
        currentTool == "freehand" ||
        currentTool == "marker") &&
        currentPolygonPoints.isNotEmpty) {
      _tempPolygons.add(
        Polygon(
          polygonId: PolygonId(DateTime.now().toString()),
          points: List.from(currentPolygonPoints),
          fillColor: Colors.redAccent.withOpacity(0.4),
          strokeColor: Colors.red,
          strokeWidth: 3,
        ),
      );

      register_farm(context);
    } else {
      currentPolygonPoints.clear();
      isDrawing = false;
    }
    notifyListeners();
  }

  double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    final turfPolygon = turf.Polygon(
      coordinates: [
        points.map((p) => turf.Position(p.longitude, p.latitude)).toList()
      ],
    );
    return (turf.area(turfPolygon) ?? 0.0).toDouble();
  }

  void updateSelectedAreaUnit(String? newUnit) {
    if (newUnit == null || newUnit == _selectedAreaUnit) return;
    _selectedAreaUnit = newUnit;
    notifyListeners();
  }

  String _formatArea(double area, String unit) {
    switch (unit) {
      case 'ha':
        final converted = area / 10000;
        return '${converted.toStringAsFixed(2)} ha';
      default:
        final converted = area * 0.000247105;
        return '${converted.toStringAsFixed(2)} Acres';
    }
  }

  void _resetToolSelection() {
    currentTool = "";
    _toolSelected = false;
    notifyListeners();
  }

  void selectFarm(FarmPlot farm) {
    selectedFarm = farm;
    farmNameController.text = farm.name;
    isFarmDetailsVisible = true;

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              farm.coordinates.map((c) => c.latitude).reduce(min),
              farm.coordinates.map((c) => c.longitude).reduce(min),
            ),
            northeast: LatLng(
              farm.coordinates.map((c) => c.latitude).reduce(max),
              farm.coordinates.map((c) => c.longitude).reduce(max),
            ),
          ),
          100,
        ),
      );
    }

    notifyListeners();
  }


  void placeMarker(LatLng point) {
    if (currentTool == "marker") {
      markers.add(
        Marker(
          markerId: MarkerId(DateTime.now().toString()),
          position: point,
        ),
      );

      if (markers.length >= 2) {
        if (markers.first.position == markers.last.position) {
          polylines.add(Polyline(
            polylineId: PolylineId(DateTime.now().toString()),
            points: markers.map((m) => m.position).toList(),
            color: Colors.blue,
            width: 3,
          ));
        }
      }

      notifyListeners();
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const radius = 6371e3;
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLng = _toRadians(p2.longitude - p1.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(p1.latitude)) *
            cos(_toRadians(p2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return radius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRadians(double degree) => degree * pi / 180;

  List<LatLng> _getRectanglePoints(LatLng start, LatLng end) => [
    start,
    LatLng(start.latitude, end.longitude),
    end,
    LatLng(end.latitude, start.longitude),
    start,
  ];

  void clearShapes() {
    polygons.clear();
    circles.clear();
    markers.clear();
    polylinePoints.clear();
    polylines.clear();
    isDrawing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}

class _FarmDetailsRow extends StatelessWidget {
  final String title;
  final String value;

  const _FarmDetailsRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title,
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.quicksand(color: Colors.black87)),
        ],
      ),
    );
  }
}

class FarmPlot {
  final String id;
  late final String name;
  final double area;
  final List<LatLng> coordinates;
  final DateTime createdAt;
  final String geoHash;

  FarmPlot({
    required this.id,
    required this.name,
    required this.area,
    required this.coordinates,
    required this.createdAt,
    required this.geoHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'coordinates': coordinates
          .map((latLng) => {'lat': latLng.latitude, 'lng': latLng.longitude})
          .toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'geoHash': geoHash,
    };
  }

  static Stream<List<FarmPlot>> loadFarms() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('user_info')
        .doc(user.uid)
        .collection('farms')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FarmPlot(
          id: data['id'] as String,
          name: data['name'] as String,
          area: (data['area'] as num).toDouble(),
          coordinates: (data['coordinates'] as List)
              .map((coord) => LatLng(
            (coord['lat'] as num).toDouble(),
            (coord['lng'] as num).toDouble(),
          ))
              .toList(),
          createdAt:
          DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
          geoHash: data['geoHash'] as String,
        );
      }).toList();
    });
  }
}

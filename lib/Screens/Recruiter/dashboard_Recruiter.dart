import 'package:flutter/material.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  _JobSeekerDashboardState createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  @override
  void initState() {
    super.initState();
    // Display the overlay for 6 seconds, then remove it.
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
      });
    });

    // Removed getCurrentLocation() from here.
    // Location fetching is handled in provider.setMapController.
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}


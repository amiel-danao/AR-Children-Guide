import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreDashboard extends StatefulWidget {
  const PreDashboard({super.key});

  @override
  State<PreDashboard> createState() => _PreDashboardState();
}

class _PreDashboardState extends State<PreDashboard> {
  Timer? timer;

  @override
  void initState() {
    setDashboard();
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
      setDashboard();
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  Future<void> setDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString("userType");

    if (userType == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    switch (userType) {
      case "admin":
        // set to parent dashboard;
        Navigator.pushReplacementNamed(context, "/dashboard_admin")
            .then((value) => timer!.cancel());
        break;
      case "parent":
        // set to parent dashboard;
        Navigator.pushReplacementNamed(context, "/dashboard_parent")
            .then((value) => timer!.cancel());
        break;
      case "child":
        // set to child dashboard;
        Navigator.pushReplacementNamed(context, "/dashboard_child")
            .then((value) => timer!.cancel());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

import 'dart:async';

import 'package:ar/auth/profiles/parent.dart';
import 'package:ar/dashboard/menubar/parent_menubar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../widget_builder.dart';
import 'maps/maps.dart';

class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  Timer? timer;

  int childCount = 0;
  int activeChild = 0;

  @override
  void initState() {
    super.initState();
    Parent().updateActiveStatus();
    getData();
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      Parent().updateActiveStatus();
      getData();
    });
  }

  Future getData() async {
    int childCountAwait = await Parent().getChildCount();
    int childActiveAwait = await Parent().getChildrenActive();
    if (!mounted) {
      return;
    }
    setState(() {
      childCount = childCountAwait;
      activeChild = childActiveAwait;
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ParentMenuBar(),
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/dashboard/child_management");
              },
              child: CountOverview(detail: "Child Users: ", count: childCount),
            ),
            Text("You have $activeChild children that are online")
          ],
        ),
      ),
    );
  }
}

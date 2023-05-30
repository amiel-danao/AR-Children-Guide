import 'dart:async';

import 'package:ar/auth/profiles/admin.dart';
import 'package:ar/dashboard/menubar/admin_menubar.dart';
import 'package:flutter/material.dart';

import '../widget_builder.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int parentCount = 0;
  int childCount = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initializeCountValues();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      initializeCountValues();
      Admin().updateActiveStatus();
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  Future<void> initializeCountValues() async {
    int parentCountAwait = await Admin().getParentCount();
    int childCountAwait = await Admin().getChildCount();
    if (!mounted) {
      return;
    }
    setState(() {
      parentCount = parentCountAwait;
      childCount = childCountAwait;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: const AdminMenuBar(),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/parent_management");
                },
                child: CountOverview(
                    detail: "Parent Users: ", count: parentCount)),
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/child_list");
                },
                child:
                    CountOverview(detail: "Child Users: ", count: childCount)),
          ],
        ),
      ),
    );
  }
}

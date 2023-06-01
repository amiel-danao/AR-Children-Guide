import 'dart:async';

import 'package:ar/dashboard/child_add_journey.dart';
import 'package:ar/dashboard/maps/map_child.dart';
import 'package:ar/widget_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../auth/profiles/child.dart';
import 'menubar/child_menubar.dart';

class ChildDashboardPage extends StatefulWidget {
  const ChildDashboardPage({super.key});

  @override
  State<ChildDashboardPage> createState() => _ChildDashboardPageState();
}

class _ChildDashboardPageState extends State<ChildDashboardPage> {
  List<Map<String, dynamic>> journeyList = [];
  int journeyCount = 0;
  Timer? timer;

  @override
  void initState() {
    getJourneys();
    Future.delayed(const Duration(seconds: 5)).then((value) {
      getJourneys();
    });
    Child().updateActiveStatus();
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      getJourneys();
      Child().updateActiveStatus();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  Future<void> getJourneys() async {
    try {
      List<Map<String, dynamic>> journeyListAwait = await Child().getJourneys();
      if (!mounted) {
        return;
      }
      setState(() {
        journeyList = journeyListAwait;
        journeyCount = journeyListAwait.length;
      });
    } catch (e) {
      return;
    }
  }

  Future openOptions(
      {required void Function() openMap,
      required void Function() deleteMap}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Options"),
        content: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                actionButton(context, "Open Maps", onPressed: openMap),
                actionButton(context, "Delete", onPressed: deleteMap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ChildMenuBar(),
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: journeyCount,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> child = journeyList[index];
              return ListTile(
                onTap: () {
                  openOptions(
                    openMap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapViewChildren(
                            startDestination: journeyList[index]["from"].toString(),
                            endDestination: journeyList[index]["to"].toString(),
                            startLocation: journeyList[index]["startLocation"],
                            endLocation: journeyList[index]["endLocation"],
                            journeyId: journeyList[index]["id"],
                          ),
                        ),
                      );
                    },
                    deleteMap: () async {
                      await Child().deleteJourney(child["id"]);
                      if (!mounted) {
                        return;
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/dashboard_child");
                    },
                  );
                },
                leading: const Icon(Icons.location_city),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From: ${child["from"]}"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("To: ${child["to"]}"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          "Created At: ${(child["created_at"] as Timestamp).toDate().toString().split(" ")[0]}"),
                    ],
                  ),
                ),
              );
            }),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          setState(() {
            journeyList = [];
            journeyCount = 0;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      JourneyForm(journeyId: journeyCount.toString())));
        },
        child: const Text("Add Journey"),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../auth/profiles/parent.dart';
import 'maps/map_parent.dart';

class ChildViewPage extends StatefulWidget {
  final String uid;
  const ChildViewPage({super.key, required this.uid});

  @override
  State<ChildViewPage> createState() => _ChildViewPageState();
}

class _ChildViewPageState extends State<ChildViewPage> {
  List<Map<String, dynamic>> childList = [];
  int childCount = 0;

  @override
  void initState() {
    getChildren();
    super.initState();
  }

  Future<void> getChildren() async {
    List<Map<String, dynamic>> childListAwait =
        await Parent().getChildJourneys(widget.uid);
    setState(() {
      childList = childListAwait;
      childCount = childListAwait.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child's Journeys"),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: childCount,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> child = childList[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapViewParent(
                        startDestination: childList[index]["from"].toString(),
                        endDestination: childList[index]["to"].toString(),
                        startLocation: childList[index]["startLocation"],
                        endLocation: childList[index]["endLocation"],
                        childID: widget.uid,
                      ),
                    ),
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
    );
  }
}

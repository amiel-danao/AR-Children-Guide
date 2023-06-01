import 'dart:async';

import 'package:ar/auth/profiles/parent.dart';
import 'package:ar/dashboard/menubar/parent_menubar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../auth/auth.dart';
import '../widget_builder.dart';
import 'maps/maps.dart';
import 'maps/notification.dart';

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
    updateChildrenParentId();
    listenForNotifications();
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

  Future<void> updateChildrenParentId() async {
    if(Auth().currentUser == null){
      return;
    }

    var db = FirebaseFirestore.instance;
    var email = Auth().currentUser!.email;
    // Get a new write batch
    final batch = db.batch();

// Set the value of 'NYC'
    var childrenRef = db.collection("users").doc("parent").collection('list').doc(email).collection("children");

    await childrenRef.get().then(
          (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          var parentChildRef = docSnapshot.reference;
          batch.set(parentChildRef, {"parentId": Auth().currentUser!.uid}, SetOptions(merge: true));

          var childRef = db.collection("users").doc("child").collection('list').doc(docSnapshot.data()['uid']);
          batch.set(childRef, {"parentId": Auth().currentUser!.uid}, SetOptions(merge: true));
        }
      },
      onError: (e) => print("Error completing: $e"),
    );




// Commit the batch
    batch.commit().then((_) {
      print('children updated for: $email');
    });
  }

  Future<void> listenForNotifications() async {
    if(Auth().currentUser == null){
      return;
    }

    var email = Auth().currentUser!.email;
    email ??= "";

    if(!await Auth().checkIfParent(email)){
    return;
    }

    FirebaseFirestore.instance.collection("Notifications")
        .where("viewed", isEqualTo: false)
        .snapshots()
        .listen((event) async {
          for (var change in event.docChanges) {
            if(change.type == DocumentChangeType.added){
            var notifierUsername = change.doc['username'];

            var childNotificationIsMine = change.doc['parentId'] == Auth().currentUser!.uid;

            if(childNotificationIsMine) {
              var message = '${change
                  .doc['username']} has arrived in their destination';

                NotificationAPI.showNotifications(
                  title: "Child arrived Notification",
                  body: message
                );

                await change.doc.reference.set({"viewed": true}, SetOptions(merge: true));
              }
            }
          }
    });
  }
}

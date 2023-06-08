import 'dart:async';

import 'package:ar/dashboard/child_add_journey.dart';
import 'package:ar/dashboard/maps/map_child.dart';
import 'package:ar/widget_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../auth/profiles/child.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'menubar/child_menubar.dart';

class ChildJourneysView extends StatefulWidget {
  const ChildJourneysView({super.key});

  @override
  State<ChildJourneysView> createState() => _ChildJourneysViewState();
}

class _ChildJourneysViewState extends State<ChildJourneysView> {
  List<Map<String, dynamic>> journeyList = [];
  int journeyCount = 0;
  Timer? timer;

  late Map<String, dynamic> profile = {
    "username": "Child"
  };

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
    getProfile();
    super.initState();
  }

  void getProfile() async{
    var p = await Child().getProfile();
    setState(() {
      profile = p;
    });
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
        title: Text("${profile['username']}'s Journey"),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: journeyCount,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> child = journeyList[index];
              return ListTile(
                onTap: () {
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
                leading: const Icon(Icons.location_city),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'From: ',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '${child["from"]}',
                              style: TextStyle(),
                            ),
                          ],
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium,
                        ),
                      ),
                      // Text("From: ${child["from"]}"),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'To: ',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '${child["to"]}',
                              style: TextStyle(),
                            ),
                          ],
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium,
                        ),
                      ),
                      Text(
                          "Created At: ${(child["created_at"] as Timestamp).toDate().toString().split(" ")[0]}"),
                    ],
                  ),
                ),
               trailing: IconButton(icon: const Icon(Icons.delete) , onPressed: (){
                    showViewDeleteDialog(
                        context,
                        profile["uid"],
                        journeyList[index]["id"]
                    );
                  }),
              );
            }),
      ),
      // floatingActionButton: ElevatedButton(
      //   onPressed: () {
      //     setState(() {
      //       journeyList = [];
      //       journeyCount = 0;
      //     });
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) =>
      //                 JourneyForm(journeyId: journeyCount.toString())));
      //   },
      //   child: const Text("Add Journey"),
      // ),
    );
  }
  void showViewDeleteDialog(BuildContext context, String childUid, String uid) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changes Made'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this child?'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () async {
                String path = "users/child/list/$childUid/journeys";
                await FirebaseFirestore.instance.collection(path).doc(uid).delete();
                Fluttertoast.showToast(
                    msg:
                    "Journey deletion successful",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );

                await getJourneys();

                Navigator.of(context).pop();

                // bool creationSucceeded = await Parent()
                //     .deleteChildAccount(email, password, userPath, parentPath);
                // print(creationSucceeded);
                // Fluttertoast.showToast(
                //     msg:
                //     "Account deletion ${creationSucceeded ? "successful" : "failed"}",
                //     toastLength: Toast.LENGTH_SHORT,
                //     gravity: ToastGravity.BOTTOM,
                //     timeInSecForIosWeb: 1,
                //     backgroundColor: Colors.red,
                //     textColor: Colors.white,
                //     fontSize: 16.0);
                // // Code to delete the document goes here
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                // Navigator.pushNamed(context, "/dashboard/child_management");
              },
            ),
          ],
        );
      },
    );
  }
}

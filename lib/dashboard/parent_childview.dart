import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../auth/profiles/parent.dart';
import '../flutter_flow/flutter_flow_theme.dart';
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
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          "Created At: ${(child["created_at"] as Timestamp).toDate().toString().split(" ")[0]}"),
                    ],
                  ),
                ),
                trailing: IconButton(icon: const Icon(Icons.delete) , onPressed: (){
                  showViewDeleteDialog(
                    context,
                    widget.uid,
                    child["uid"]
                  );
                }),
              );
            }),
      ),
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

                await getChildren();

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

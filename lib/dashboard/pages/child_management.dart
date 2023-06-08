import 'package:ar/dashboard/parent_childview.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth/profiles/parent.dart';
import '../../widget_builder.dart';
import '../menubar/parent_menubar.dart';

class ChildManagementPage extends StatefulWidget {
  const ChildManagementPage({super.key});

  @override
  State<ChildManagementPage> createState() => _ChildManagementPageState();
}

class _ChildManagementPageState extends State<ChildManagementPage> {
  int childCount = 0;

  List<Map<String, dynamic>> childList = [];

  @override
  void initState() {
    getChildren();
    super.initState();
  }

  Future<void> getChildCount() async {
    int childCountAwait = await Parent().getChildCount();
    setState(() {
      childCount = childCountAwait;
    });
  }

  Future<void> getChildren() async {
    List<Map<String, dynamic>> childListAwait =
        await Parent().getChildrenData();
    if (!mounted) {
      return;
    }
    setState(() {
      childList = childListAwait;
      childCount = childListAwait.length;
    });
  }

  void showViewDeleteDialog(BuildContext context, String uid, String email,
      String password, String userPath, String parentPath) {
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
                bool creationSucceeded = await Parent()
                    .deleteChildAccount(email, password, userPath, parentPath);
                print(creationSucceeded);
                Fluttertoast.showToast(
                    msg:
                        "Account deletion ${creationSucceeded ? "successful" : "failed"}",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // Code to delete the document goes here
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, "/dashboard/child_management");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Children"),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: childCount,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> child = childList[index];
            return ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildViewPage(uid: child["uid"])));
                },
                leading: Stack(
                  children: [
                    Icon(Icons.person),
                    Positioned(
                      top: 0,
                      right: 2,
                      child: OnlineStatusIcon(isOnline: child['isOnline']),
                    ),
                  ],
                ),
                trailing: IconButton(icon: const Icon(Icons.delete) , onPressed: (){
                  showViewDeleteDialog(
                    context,
                    child["uid"],
                    child["email"],
                    child["password"],
                    "users/child/list/${child["uid"]}",
                    "users/parent/list/${Parent().user!.email}/children/${child["username"]}",
                  );
                }),
                subtitle: Text(
                  child["email"],
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
                title: Text(child["username"]));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/dashboard/child_management/create");
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

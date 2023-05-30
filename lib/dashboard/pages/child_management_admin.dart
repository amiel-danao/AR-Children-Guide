import 'package:ar/dashboard/admin_child_view.dart';
import 'package:flutter/material.dart';

import '../../auth/profiles/admin.dart';
import '../../widget_builder.dart';

class ChildListAdmin extends StatefulWidget {
  const ChildListAdmin({super.key});

  @override
  State<ChildListAdmin> createState() => _ChildListAdminState();
}

class _ChildListAdminState extends State<ChildListAdmin> {
  int childCount = 0;
  List<Map<String, dynamic>> childList = [];

  @override
  void initState() {
    super.initState();
    getParents();
  }

  Future<void> getParents() async {
    List<Map<String, dynamic>> childListAwait = await Admin().getChildrenData();
    setState(() {
      childList = childListAwait;
      childCount = childListAwait.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Management"),
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
                      builder: (context) => AdminChildView(
                        uid: child["uid"],
                      ),
                    ),
                  );
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
                trailing: Text(
                  child["email"],
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
                title: Text(child["username"]));
          }),
    );
  }
}

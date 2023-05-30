import 'package:ar/dashboard/admin_parent_view.dart';
import 'package:flutter/material.dart';

import '../../auth/profiles/admin.dart';
import '../../widget_builder.dart';

class ParentManagement extends StatefulWidget {
  const ParentManagement({super.key});

  @override
  State<ParentManagement> createState() => _ParentManagementState();
}

class _ParentManagementState extends State<ParentManagement> {
  int parentCount = 0;
  List<Map<String, dynamic>> parentList = [];

  @override
  void initState() {
    super.initState();
    getParents();
    Future.delayed(Duration(seconds: 3), getParents);
  }

  Future<void> getParents() async {
    if (!mounted) {
      return;
    }
    List<Map<String, dynamic>> parentListAwait = await Admin().getParentsData();
    setState(() {
      parentList = parentListAwait;
      parentCount = parentListAwait.length;
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
          itemCount: parentCount,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> parent = parentList[index];
            print(parent);
            if (parent["email"] == null) {
              return Container();
            }
            return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminParentView(
                        email: parent["email"],
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
                      child: OnlineStatusIcon(isOnline: parent['isOnline']),
                    ),
                  ],
                ),
                trailing: Text(
                  parent["email"],
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
                title: Text(parent["name"]));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/dashboard/parent_management/create");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

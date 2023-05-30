import 'package:ar/auth/profiles/admin.dart';
import 'package:flutter/material.dart';
import '../../auth/auth.dart';
import '../../auth/profiles/parent.dart';

class AdminMenuBar extends StatefulWidget {
  const AdminMenuBar({super.key});

  @override
  State<AdminMenuBar> createState() => _AdminMenuBarState();
}

class _AdminMenuBarState extends State<AdminMenuBar> {
  Future<bool?> _showSignOutDialog() async {
    Future<bool?> didSignOut = showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return await didSignOut;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text(Admin().name),
              accountEmail: Text(Admin().user!.email.toString())),
          Column(
            children: [
              ListTile(
                title: const Text("Admins"),
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/admin_management");
                },
              ),
              ListTile(
                title: const Text("Parents"),
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/parent_management");
                },
              ),
              ListTile(
                title: const Text("Children"),
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/child_list");
                },
              ),
              ListTile(
                title: const Text("Signout"),
                onTap: () async {
                  bool? confirmed = await _showSignOutDialog();
                  if (confirmed == null) {
                    return;
                  }
                  if (!confirmed) {
                    return;
                  }
                  Auth().signOut().then((result) {
                    if (result == "Success") {
                      Navigator.pushReplacementNamed(context, "/home");
                    }
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

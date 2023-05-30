import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../auth/auth.dart';
import '../../auth/profiles/parent.dart';

class ParentMenuBar extends StatefulWidget {
  const ParentMenuBar({super.key});

  @override
  State<ParentMenuBar> createState() => _ParentMenuBarState();
}

class _ParentMenuBarState extends State<ParentMenuBar> {
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    getData();
  }

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

  Future<void> getData() async {
    String path = "profiles/" + Parent().user!.uid;
    final ref = FirebaseStorage.instance.ref().child(path);
    Uint8List? data;
    try {
      data = await ref.getData();
    } catch (e) {}
    if (data == null || data.isEmpty) {
      photoUrl = null;
    } else {
      photoUrl = await ref.getDownloadURL();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/profile_parent");
                },
                child: ClipOval(
                  child: Image.network(
                    photoUrl ??
                        'https://firebasestorage.googleapis.com/v0/b/mobile-ar-6984e.appspot.com/o/default%20profile%20picture.jpg?alt=media',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              accountName: Text(Parent().name),
              accountEmail: Text(Parent().user?.email.toString() ?? "")),
          Column(
            children: [
              ListTile(
                title: const Text("Children"),
                onTap: () {
                  Navigator.pushNamed(context, "/dashboard/child_management");
                },
              ),
              ListTile(
                title: const Text("View Profile"),
                onTap: () async {
                  Navigator.pushNamed(context, "/dashboard/profile_parent");
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
                      Navigator.pop(context);
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

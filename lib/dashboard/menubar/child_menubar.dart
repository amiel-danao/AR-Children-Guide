import 'dart:typed_data';

import 'package:ar/auth/profiles/child.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../auth/auth.dart';

class ChildMenuBar extends StatefulWidget {
  const ChildMenuBar({super.key});

  @override
  State<ChildMenuBar> createState() => _ChildMenuBarState();
}

class _ChildMenuBarState extends State<ChildMenuBar> {
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
    String path = "profiles/" + Child().user!.uid;
    final ref = FirebaseStorage.instance.ref().child(path);
    Uint8List? data = await ref.getData();
    if (data == null || data.isEmpty) {
      photoUrl = null;
    } else {
      photoUrl = await ref.getDownloadURL();
    }
    if (!mounted) {
      return;
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
                  Navigator.pushNamed(context, "/dashboard/profile_child");
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
              accountName: Text(Child().name),
              accountEmail: Text(Child().user!.email.toString())),
          Column(
            children: [
              ListTile(
                title: const Text("View Profile"),
                onTap: () async {
                  Navigator.pushNamed(context, "/dashboard/profile_child");
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
                  await Child().updateActiveStatus();
                  Auth().signOut().then((value) =>
                      Navigator.pushReplacementNamed(context, "/home"));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

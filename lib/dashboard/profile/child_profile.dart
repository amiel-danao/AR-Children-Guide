import 'dart:typed_data';

import 'package:ar/dashboard/profile/profile_edit.dart';
import 'package:ar/widget_builder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../auth/profiles/child.dart';

TextStyle infoTextStyle = const TextStyle(fontSize: 18);

class ChildProfile extends StatefulWidget {
  const ChildProfile({super.key});

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile> {
  String name = "N/A";
  String age = "N/A";
  String phoneNumber = "N/A";
  String email = Child().user!.email!;
  String region = "N/A";
  String province = "N/A";
  String city = "N/A";
  String? photoUrl;
  String birthDate = "N/A";

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    Map<String, dynamic> userData = await Child().getProfile();
    Map<String, dynamic> address = userData["address"] ?? {};
    String path = "profiles/" + Child().user!.uid;
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
    if (!mounted) {
      return;
    }
    setState(() {
      name = userData["name"] ?? name;
      age = userData["age"] ?? age;
      phoneNumber = userData["phoneNumber"] ?? phoneNumber;
      region = address["region"] ?? region;
      province = address["province"] ?? province;
      city = address["city"] ?? city;
      birthDate = userData["birthdate"] ?? birthDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEdit(),
                      ),
                    );
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
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  createProfileInfo(context, "Name", name,
                      style: infoTextStyle),
                  const SizedBox(
                    height: 10,
                  ),
                  createProfileInfo(context, "Birth Date", birthDate,
                      style: infoTextStyle),
                  const SizedBox(
                    height: 10,
                  ),
                  createProfileInfo(context, "Age", age, style: infoTextStyle),
                  const SizedBox(
                    height: 10,
                  ),
                  createProfileInfo(context, "Phone Number", phoneNumber,
                      style: infoTextStyle),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Address ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  createProfileInfo(context, "Region", region,
                      style: infoTextStyle),
                  const SizedBox(
                    height: 10,
                  ),
                  createProfileInfo(context, "Province", province,
                      style: infoTextStyle),
                  const SizedBox(
                    height: 10,
                  ),
                  createProfileInfo(context, "City", city,
                      style: infoTextStyle),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/dashboard/profile_child/edit");
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

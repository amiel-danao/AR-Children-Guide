import 'package:ar/auth/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AdminChildView extends StatefulWidget {
  final String uid;
  const AdminChildView({super.key, required this.uid});

  @override
  State<AdminChildView> createState() => _AdminChildViewState();
}

class _AdminChildViewState extends State<AdminChildView> {
  String userName = "";
  String age = "";
  String phoneNumber = "";
  String email = "";
  Map<String, dynamic> address = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    String path = "users/child/list/" + widget.uid;
    DocumentSnapshot dataSnapshot = await Database().getDocumentSnapshot(path);
    Map<String, dynamic> data = dataSnapshot.data() as Map<String, dynamic>;
    if (!mounted) {
      return;
    }
    setState(() {
      userName = data["username"] ?? "N/A";
      age = data["age"] ?? "N/A";
      phoneNumber = data["phoneNumber"] ?? "N/A";
      email = data["email"] ?? "N/A";
      address = data["address"] ?? {};
    });
  }

  TextStyle infoNameStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle infoDetailStyle = TextStyle(fontSize: 19);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(userName + "'s Profile")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Name: ",
                    style: infoNameStyle,
                  ),
                  SizedBox(width: 20),
                  Text(userName, style: infoDetailStyle)
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "Age: ",
                    style: infoNameStyle,
                  ),
                  SizedBox(width: 20),
                  Text(age, style: infoDetailStyle)
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "Phone Number: ",
                    style: infoNameStyle,
                  ),
                  SizedBox(width: 20),
                  Text(phoneNumber, style: infoDetailStyle)
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "Email: ",
                    style: infoNameStyle,
                  ),
                  SizedBox(width: 20),
                  Text(email, style: infoDetailStyle)
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Address",
                        style: infoNameStyle,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Region: ",
                                style: infoNameStyle,
                              ),
                              SizedBox(width: 20),
                              Text(address["region"] ?? "N/A",
                                  style: infoDetailStyle)
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "Province: ",
                                style: infoNameStyle,
                              ),
                              SizedBox(width: 20),
                              Text(address["province"] ?? "N/A",
                                  style: infoDetailStyle)
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "City: ",
                                style: infoNameStyle,
                              ),
                              SizedBox(width: 20),
                              Text(address["city"] ?? "N/A",
                                  style: infoDetailStyle)
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

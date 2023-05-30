import 'package:ar/auth/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AdminParentView extends StatefulWidget {
  final String email;
  const AdminParentView({super.key, required this.email});

  @override
  State<AdminParentView> createState() => _AdminParentViewState();
}

class _AdminParentViewState extends State<AdminParentView> {
  String name = "";
  String age = "";
  String phoneNumber = "";
  Map<String, dynamic> address = {};
  List<String> childrenEmails = [];
  List<Widget> childrenDataWidgets = [];

  @override
  void initState() {
    super.initState();
    getData();
    getChildCount();
  }

  Future getData() async {
    String path = "users/parent/list/" + widget.email;
    DocumentSnapshot dataSnapshot = await Database().getDocumentSnapshot(path);
    Map<String, dynamic> data = dataSnapshot.data() as Map<String, dynamic>;
    if (!mounted) {
      return;
    }
    setState(() {
      name = data["name"] ?? "N/A";
      age = data["age"] ?? "N/A";
      phoneNumber = data["phoneNumber"] ?? "N/A";
      address = data["address"] ?? {};
    });
  }

  Future getChildCount() async {
    if (!mounted) {
      return;
    }
    String path = "users/parent/list/" + widget.email + "/children";
    List<QueryDocumentSnapshot<Map<String, dynamic>>> childrenSnapshots =
        await Database().getDocs(path);
    print(path);
    print(childrenSnapshots.length);
    for (var childrenSnapshot in childrenSnapshots) {
      Map<String, dynamic> childrenData = childrenSnapshot.data();
      Widget childrenWidget = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(childrenData["username"] ?? "N/A"),
              Text(
                childrenData["email"] ?? "N/A",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width -
                (MediaQuery.of(context).size.width / 4),
            color: Colors.black38,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
      setState(() {
        childrenDataWidgets.add(childrenWidget);
      });
    }
    setState(() {});
  }

  TextStyle infoNameStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle infoDetailStyle = TextStyle(fontSize: 19);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name + "'s Profile")),
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
                  Text(name, style: infoDetailStyle)
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
                  Text(widget.email, style: infoDetailStyle)
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
              Card(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Children(" + childrenDataWidgets.length.toString() + ")",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: childrenDataWidgets,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

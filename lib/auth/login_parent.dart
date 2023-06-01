import 'package:ar/auth/forgot_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_builder.dart';
import 'auth.dart';

class ParentLoginPage extends StatefulWidget {
  const ParentLoginPage({super.key});

  @override
  State<ParentLoginPage> createState() => _ParentLoginPageState();
}

class _ParentLoginPageState extends State<ParentLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RegExp emailValidationExpression = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isParent = false;

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('I understand'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future checkCredentials(String email) async {
    email = email.trim();
    bool isParentAwait = await Auth().checkIfParent(email);
    print(isParentAwait);
    setState(() {
      isParent = isParentAwait;
    });
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 250,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                                height: 25,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/login_admin");
                                    },
                                    child: Text(
                                      "Admin",
                                      style: TextStyle(fontSize: 12),
                                    ))),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Parent",
                                  )),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              height: 25,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, "/login_child");
                                  },
                                  child: Text(
                                    "Child",
                                    style: TextStyle(fontSize: 12),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 168, 188, 191),
                                  borderRadius: BorderRadius.circular(
                                      10), // set the border radius to 10
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      createInput(context, 300, "Email",
                                          controller: emailController,
                                          color: Colors.white,
                                          onChanged: (email) async {
                                        print("changing");
                                        if (!emailValidationExpression
                                            .hasMatch(email)) {
                                          return;
                                        }
                                        bool isParentAwait = await Auth()
                                            .checkIfParent(
                                                emailController.text);
                                        print(isParentAwait);
                                        setState(() {
                                          isParent = isParentAwait;
                                        });
                                      }, validator: (email) {
                                        if (email == null) {
                                          return null;
                                        }
                                        if (!emailValidationExpression
                                            .hasMatch(email)) {
                                          return '\u26A0 Email is not valid';
                                        }
                                        if (email.isEmpty) {
                                          return '\u26A0 Email is empty.';
                                        }
                                        if (!isParent) {
                                          checkCredentials(
                                              emailController.text);
                                          return 'You are not a parent or is still being verified, try again after few seconds';
                                        }
                                        return null;
                                      }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width: 300,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              5), // set the border radius to 10
                                        ),
                                        child: PasswordField(
                                          hintText: "Password",
                                          controller: passwordController,
                                          inputBorder: InputBorder.none,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 300,
                                        height: 35,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ForgotPasswordWidget()));
                                                },
                                                child: const Text(
                                                    "Forgot Password"))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: actionButton(
                              context,
                              "Login",
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString("userType", "parent");
                                String result = await Auth()
                                    .signInWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passwordController.text);
                                if (result == "Success") {
                                  await updateFCMToken();
                                  Fluttertoast.showToast(
                                      msg: "Login success",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  Navigator.pushReplacementNamed(context, "/");
                                } else {
                                  if (!mounted) {
                                    return;
                                  }
                                  showAlert(context, result);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                              width: 200,
                              child: actionButton(context, "Create Account",
                                  onPressed: () {
                                Navigator.pushNamed(context, "/signup_parent");
                              })),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    var data = {
      "token": fcmToken
    };

    await FirebaseFirestore.instance.collection("Tokens").doc(Auth().currentUser!.uid).set(data);
  }
}

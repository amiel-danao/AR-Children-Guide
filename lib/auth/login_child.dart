import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_builder.dart';
import 'auth.dart';

class ChildLoginPage extends StatefulWidget {
  const ChildLoginPage({super.key});

  @override
  State<ChildLoginPage> createState() => _ChildLoginPageState();
}

class _ChildLoginPageState extends State<ChildLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RegExp emailValidationExpression = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isChild = false;

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
    bool isChildAwait = await Auth().checkIfChild(email);
    print(isChildAwait);
    setState(() {
      isChild = isChildAwait;
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
                              height: 25,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, "/login_parent");
                                  },
                                  child: Text(
                                    "Parent",
                                    style: TextStyle(fontSize: 12),
                                  )),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Child",
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Form(
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    createInput(
                                      context,
                                      300,
                                      "Email",
                                      controller: emailController,
                                      color: Colors.white,
                                      onChanged: (email) async {
                                        if (!emailValidationExpression
                                            .hasMatch(email)) {
                                          return;
                                        }
                                        bool isChildAwait =
                                            await Auth().checkIfChild(email);
                                        setState(() {
                                          isChild = isChildAwait;
                                        });
                                      },
                                      validator: (email) {
                                        if (email!.isEmpty) {
                                          return 'Email is empty';
                                        }
                                        if (!emailValidationExpression
                                            .hasMatch(email)) {
                                          return 'Invalid email';
                                        }
                                        if (!isChild) {
                                          checkCredentials(
                                              emailController.text);
                                          return 'You are not a child or it is still being verified';
                                        }
                                        return null;
                                      },
                                    ),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: actionButton(
                              context,
                              "Login",
                              onPressed: login,
                            ),
                          ),
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

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userType", "child");
    String result = await Auth().signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    if (result == "Success") {
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
  }
}

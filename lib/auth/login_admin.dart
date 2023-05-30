import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_builder.dart';
import 'auth.dart';
import 'forgot_password.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isAdmin = false;
  RegExp emailValidationExpression = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userType", "admin");
    String result = await Auth().signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim());
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

  Future checkCredentials(String email) async {
    email = email.trim();
    bool isAdminAwait = await Auth().checkIfAdmin(email);
    print(isAdminAwait);
    if (!mounted) {
      return;
    }
    setState(() {
      isAdmin = isAdminAwait;
    });
    if (_formKey.currentState!.validate()) {
      login();
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance.doc("users/email");
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
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
                                  height: 45,
                                  child: ElevatedButton(
                                      onPressed: () {}, child: Text("Admin"))),
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
                            Container(
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
                                    createInput(context, 300, "Email",
                                        controller: emailController,
                                        color: Colors.white,
                                        onChanged: (email) async {
                                      if (!emailValidationExpression
                                          .hasMatch(email)) {
                                        return;
                                      }
                                      isAdmin = await Auth()
                                          .checkIfAdmin(email.trim());
                                    }, validator: (email) {
                                      if (email == null) {
                                        return null;
                                      }
                                      if (!emailValidationExpression
                                          .hasMatch(email)) {
                                        return '\u26A0 Email is empty';
                                      }
                                      if (email.isEmpty) {
                                        return '\u26A0 Field is empty.';
                                      }
                                      if (!isAdmin) {
                                        checkCredentials(email.trim());
                                        return 'You are not an admin or is still being verified, try again after few seconds';
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
                                  ],
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SizedBox(
                                width: 300,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPasswordWidget(),
                                            ),
                                          );
                                        },
                                        child: const Text("Forgot Password"))
                                  ],
                                ),
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
      ),
    );
  }
}

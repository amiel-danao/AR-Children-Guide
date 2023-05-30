import 'package:ar/widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordWidget({super.key});

  void showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            createInput(context, 300, "Enter your email",
                controller: emailController),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: actionButton(
                context,
                "Send reset link",
                onPressed: () async {
                  String email = emailController.text;
                  if (email.isEmpty || !email.contains('@')) {
                    showErrorDialog('Please enter a valid email', context);
                    return;
                  }
                  Fluttertoast.showToast(
                      msg: "Please wait...",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  try {
                    await _auth.sendPasswordResetEmail(email: email);
                    showSuccessDialog(
                        'Password reset email sent. Might be in the spam folder',
                        context);
                  } on PlatformException catch (e) {
                    showErrorDialog(e.message!, context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:ar/auth/profiles/admin.dart';
import 'package:ar/widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminCreateForm extends StatefulWidget {
  const AdminCreateForm({super.key});

  @override
  State<AdminCreateForm> createState() => _AdminCreateFormState();
}

class _AdminCreateFormState extends State<AdminCreateForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Admin"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createInput(
                context,
                300,
                "Email",
                controller: emailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(
                width: 300,
                child: PasswordField(
                    hintText: "Password", controller: passwordController),
              ),
              SizedBox(
                width: 300,
                child: actionButton(
                  context,
                  "Create Admin",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Fluttertoast.showToast(
                          msg: "Please wait...",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      // Perform create admin action
                      bool creationSucceeded = await Admin().createAdmin(
                          emailController.text, passwordController.text);
                      if (creationSucceeded) {
                        if (!mounted) {
                          return;
                        }
                        Fluttertoast.showToast(
                            msg: "Admin creation succeeded",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, "/dashboard/admin_management");
                      } else {
                        showAlert(context,
                            "Admin creation failed, please try again later");
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

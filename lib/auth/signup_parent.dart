import 'dart:async';

import 'package:ar/auth/profiles/parent.dart';
import 'package:ar/dashboard/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_builder.dart';
import 'auth.dart';

class ParentSignUpPage extends StatefulWidget {
  const ParentSignUpPage({super.key});

  @override
  State<ParentSignUpPage> createState() => _ParentSignUpPageState();
}

class _ParentSignUpPageState extends State<ParentSignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNumberController = TextEditingController();
  List<AddressData> regionList = Address().regions();
  List<AddressData> provinceList = Address().provinces();
  List<AddressData> cityList = Address().cities();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? birthDate;

  RegExp emailValidationExpression = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  Timer? timer;

  void pickDate() {
    showDatePicker(
            context: context,
            initialDate: birthDate ?? DateTime.now(),
            firstDate: DateTime(2001),
            lastDate: DateTime(2036))
        .then((date) {
      if (date != null) {
        DateTime now = DateTime.now();
        Duration age = now.difference(date);
        ageController.text = (age.inDays / 365).toInt().toString();
        setState(() {
          birthDate = date;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    updateAddress();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateAddress();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    ageController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future updateAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String? region = prefs.getString("region");
    String? province = prefs.getString("province");
    String? city = prefs.getString("city");
    print("filtering");
    if (region == null || province == null || city == null) {
      return;
    }

    String regionID = Address().getIdFromNameRegion(region);
    String provinceID = Address().getIdFromNameProvince(province);

    List<AddressData> filteredProvinces =
        await Address().filterProvinces(regionID);
    List<AddressData> filteredCities = await Address().filterCities(provinceID);
    setState(() {
      provinceList = filteredProvinces;
      cityList = filteredCities;
    });
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
          Center(
            child: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  const Text(
                    "Create Parent Account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  createInput(context, 300, "Email",
                      controller: emailController,
                      color: Colors.white,
                      validator: validateEmailInput),
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
                    height: 10,
                  ),
                  createInput(context, 300, "Name",
                      color: Colors.white, controller: nameController),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      createInput(context, 195, "Phone Number",
                          color: Colors.white,
                          controller: phoneNumberController),
                      SizedBox(
                        width: 10,
                      ),
                      createInput(context, 95, "Age",
                          color: Colors.white, controller: ageController),
                    ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "Birthday: ",
                          style: TextStyle(fontSize: 19),
                        ),
                        Text(
                          birthDate == null
                              ? "Not set"
                              : birthDate.toString().split(" ")[0],
                          style: const TextStyle(fontSize: 19),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                            width: 50,
                            child: TextButton(
                                onPressed: pickDate,
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                ))),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Region: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          AddressDropdown(
                            values: regionList,
                            type: "region",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Province: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          AddressDropdown(
                            values: provinceList,
                            type: "province",
                            parentType: "region",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "City: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          AddressDropdown(
                            values: cityList,
                            type: "city",
                            parentType: "region",
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    child: actionButton(
                      context,
                      "Sign Up",
                      onPressed: signUp,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, "/login_parent");
                      },
                      child: const Text("Have an account? Login")),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  String? validateEmailInput(email) {
    if (email == null) {
      return '\u26A0 Email is empty';
    }
    if (!emailValidationExpression.hasMatch(email)) {
      return '\u26A0 Email is empty';
    }
    if (email.isEmpty) {
      return '\u26A0 Field is empty.';
    }
    return null;
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Fluttertoast.showToast(
        msg: "Signing Up, please wait",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userType", "parent");

    String region = prefs.getString("region")!;
    String province = prefs.getString("province")!;
    String city = prefs.getString("city")!;
    var data = {
      "email": emailController.text,
      "created_at": Timestamp.fromDate(DateTime.now()),
      "name": nameController.text,
      "age": ageController.text,
      "phoneNumber": phoneNumberController.text,
      "birthdate": birthDate.toString().split(" ")[0],
      "address": {
        "region": region,
        "province": province,
        "city": city,
      }
    };
    await Parent().setProfile(data, email: emailController.text);
    String result = await Auth().createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    if (result == "Success") {
      Fluttertoast.showToast(
          msg: "Sign Up success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (!mounted) {
        return;
      }
      showAlert(context, result);
    }
  }
}

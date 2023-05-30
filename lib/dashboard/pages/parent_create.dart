import 'dart:async';

import 'package:ar/auth/profiles/parent.dart';
import 'package:ar/dashboard/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/auth.dart';
import '../../auth/profiles/admin.dart';
import '../../widget_builder.dart';

class ParentCreation extends StatefulWidget {
  const ParentCreation({super.key});

  @override
  State<ParentCreation> createState() => _ParentCreationState();
}

class _ParentCreationState extends State<ParentCreation> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNumberController = TextEditingController();
  List<AddressData> regionList = Address().regions();
  List<AddressData> provinceList = Address().provinces();
  List<AddressData> cityList = Address().cities();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegExp emailValidationExpression = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  Timer? timer;

  @override
  void initState() {
    super.initState();
    updateAddress();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateAddress();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Create a parent account"),
              createInput(context, 300, "Email",
                  controller: emailController,
                  onChanged: checkCorrectEmail,
                  validator: validateEmailInput),
              SizedBox(
                width: 300,
                child: PasswordField(
                    hintText: "Password", controller: passwordController),
              ),
              createInput(context, 300, "Name", controller: nameController),
              createInput(context, 300, "Age", controller: ageController),
              createInput(context, 300, "Phone Number",
                  controller: phoneNumberController),
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
              SizedBox(
                width: 300,
                child: actionButton(
                  context,
                  "Create",
                  onPressed: signUp,
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  String? validateEmailInput(email) {
    if (email == null) {
      return null;
    }
    if (!emailValidationExpression.hasMatch(email)) {
      return '\u26A0 Email is empty';
    }
    if (email.isEmpty) {
      return '\u26A0 Field is empty.';
    }
    return null;
  }

  void checkCorrectEmail(email) async {
    if (!emailValidationExpression.hasMatch(email)) {
      return;
    }
  }

  Future<void> signUp() async {
    if (passwordController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please input password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Fluttertoast.showToast(
        msg: "Creating account",
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
      "address": {
        "region": region,
        "province": province,
        "city": city,
      },
    };
    bool creationSucceeded = await Admin()
        .createParent(emailController.text, passwordController.text, data);
    if (creationSucceeded) {
      if (!mounted) {
        return;
      }
      Fluttertoast.showToast(
          msg: "Admin creation succeeded, changes may take a while",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushNamed(context, "/dashboard/parent_management");
    } else {
      showAlert(context, "Admin creation failed, please try again later");
    }
  }
}

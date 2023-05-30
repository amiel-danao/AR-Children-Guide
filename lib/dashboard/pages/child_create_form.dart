import 'dart:async';

import 'package:ar/dashboard/address.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/profiles/parent.dart';
import '../../widget_builder.dart';

class CreateChildPage extends StatefulWidget {
  const CreateChildPage({super.key});

  @override
  State<CreateChildPage> createState() => _CreateChildPageState();
}

class _CreateChildPageState extends State<CreateChildPage> {
  TextEditingController nicknameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  List<AddressData> regionList = Address().regions();
  List<AddressData> provinceList = Address().provinces();
  List<AddressData> cityList = Address().cities();

  DateTime? birthDate;

  bool setting = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    updateAddress();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateAddress();
    });
  }

  Future updateAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String? region = prefs.getString("region");
    String? province = prefs.getString("province");
    String? city = prefs.getString("city");
    if (region == null || province == null || city == null) {
      return;
    }

    String regionID = Address().getIdFromNameRegion(region);
    String provinceID = Address().getIdFromNameProvince(province);

    List<AddressData> filteredProvinces =
        await Address().filterProvinces(regionID);
    List<AddressData> filteredCities = await Address().filterCities(provinceID);
    if (!mounted) {
      return;
    }
    setState(() {
      provinceList = filteredProvinces;
      cityList = filteredCities;
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: !setting
          ? displayForm(context)
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget displayForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createInput(context, 300, "Nickname", controller: nicknameController),
          SizedBox(
            width: 300,
            child: PasswordField(
                hintText: "Password", controller: passwordController),
          ),
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
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Birthday: ",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                birthDate == null
                    ? "Not set"
                    : birthDate.toString().split(" ")[0],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 50,
                  child: ElevatedButton(
                      onPressed: pickDate,
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                      ))),
            ],
          ),
          actionButton(
            context,
            "Create",
            onPressed: () async {
              Fluttertoast.showToast(
                  msg: "Creating account",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              setState(() {
                setting = true;
              });
              final prefs = await SharedPreferences.getInstance();
              String region = prefs.getString("region")!;
              String province = prefs.getString("province")!;
              String city = prefs.getString("city")!;
              var data = {
                "age": ageController.text,
                "phoneNumber": phoneNumberController.text,
                "password": passwordController.text,
                "birthdate": birthDate.toString().split(" ")[0],
                "address": {
                  "region": region,
                  "province": province,
                  "city": city,
                },
              };
              bool creationSucceeded = await Parent().createChild(
                  nicknameController.text, passwordController.text, data);
              print(creationSucceeded);
              if (creationSucceeded) {
                if (!mounted) {
                  return;
                }
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, "/dashboard/child_management");
              } else {
                setState(() {
                  setting = false;
                });
              }
            },
          ),
        ],
      )),
    );
  }
}

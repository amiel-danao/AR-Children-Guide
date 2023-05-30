import 'dart:async';

import 'package:ar/auth/profiles/child.dart';
import 'package:ar/widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../address.dart';

class ChildProfileEdit extends StatefulWidget {
  const ChildProfileEdit({super.key});

  @override
  State<ChildProfileEdit> createState() => _ChildProfileEditState();
}

class _ChildProfileEditState extends State<ChildProfileEdit> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  List<AddressData> regionList = Address().regions();
  List<AddressData> provinceList = Address().provinces();
  List<AddressData> cityList = Address().cities();
  DateTime? birthDate;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    updateAddress();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateAddress();
    });

    getData();
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

  Future updateAddress() async {
    if (!mounted) return;
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

  Future<void> getData() async {
    Map<String, dynamic> userData = await Child().getProfile();
    Map<String, dynamic> address = userData["address"] ?? {};
    if (!mounted) {
      return;
    }
    setState(() {
      nameController.text = userData["name"] ?? "";
      ageController.text = userData["age"] ?? 0;
      phoneNumberController.text = userData["phoneNumber"] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: SingleChildScrollView(
        child: Column(children: [
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
          SizedBox(
            width: 300,
            child: actionButton(
              context,
              "Submit",
              onPressed: saveProfile,
            ),
          )
        ]),
      )),
    );
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String region = prefs.getString("region")!;
    String province = prefs.getString("province")!;
    String city = prefs.getString("city")!;

    var data = {
      "name": nameController.text,
      "age": ageController.text,
      "phoneNumber": phoneNumberController.text,
      "birthdate": birthDate.toString().split(" ")[0],
      "address": {
        "region": region,
        "province": province,
        "city": city,
      },
    };
    await Child().setProfile(data);
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, "/home");
  }
}

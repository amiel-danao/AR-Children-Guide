import 'package:ar/address/city.dart';
import 'package:ar/address/philippines.dart';
import 'package:ar/address/province.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../address/region.dart';

Map<String, dynamic> address = {
  "regions": [
    {
      "name": "Region VII (Central Visayas)",
      "provinces": {
        [
          {
            "name": "Negros Oriental",
            "cities": [
              {
                "name": "City of Bayawan",
                "barangays": [
                  {"name": ""}
                ]
              },
            ],
          },
        ],
      },
    },
  ],
};

class Address {
  List<AddressData> regions() {
    List<AddressData> result = [];

    List<Region> regionList = getRegions();
    for (var region in regionList) {
      AddressData addressData = AddressData(region.name, region.id);
      result.add(addressData);
    }

    return result;
  }

  String getIdFromNameRegion(String name) {
    List<Region> regionList = getRegions();
    for (var region in regionList) {
      if (region.name == name) {
        return region.id;
      }
    }
    return "";
  }

  String getIdFromNameProvince(String name) {
    List<Province> provinceList = getProvinces();
    for (var province in provinceList) {
      if (province.name == name) {
        return province.id;
      }
    }
    return "";
  }

  List<AddressData> provinces() {
    List<AddressData> result = [];

    List<Province> provinceLIst = getProvinces();
    for (var province in provinceLIst) {
      AddressData addressData = AddressData(province.name, province.id);
      result.add(addressData);
    }

    return result;
  }

  Future<List<AddressData>> filterProvinces(String id) async {
    List<AddressData> result = [];

    List<Province> provinceLIst = getProvinces();
    for (var province in provinceLIst) {
      if (province.region == id) {
        AddressData addressData = AddressData(province.name, province.name);
        result.add(addressData);
      }
    }
    return result;
  }

  Future<List<AddressData>> filterCities(String id) async {
    List<AddressData> result = [];

    List<City> citiesList = getCities();
    for (var city in citiesList) {
      if (city.province == id) {
        print(id);
        AddressData addressData = AddressData(city.name, city.name);
        result.add(addressData);
      }
    }
    return result;
  }

  List<AddressData> cities() {
    List<AddressData> result = [];

    List<City> cityList = getCities();
    for (var city in cityList) {
      AddressData addressData = AddressData(city.name, city.name);
      result.add(addressData);
    }

    return result;
  }
}

class AddressData {
  final String name;
  final String key;
  const AddressData(this.name, this.key);
}

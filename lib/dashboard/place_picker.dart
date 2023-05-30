import 'dart:async';

import 'package:ar/dashboard/maps/location_service.dart';
import 'package:ar/dashboard/maps/maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PlacePicker extends StatefulWidget {
  final String positionType;
  final FutureOr<Iterable<String>> Function(TextEditingValue) optionsBuilder;
  final void Function(String) stateUpdate;
  final Future<LatLng?> Function({String? address}) getLocation;
  final void Function(GeoPoint) stateLocationUpdate;

  const PlacePicker(
      {super.key,
      required this.positionType,
      required this.optionsBuilder,
      required this.stateUpdate,
      required this.stateLocationUpdate,
      required this.getLocation});
  @override
  _PlacePickerState createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  Set<Marker> markers = Set<Marker>();
  GoogleMapController? controller;
  LatLng? targetPosition;
  PlaceInfo? placeInfo;

  void _selectLocation(LatLng position) async {
    Marker marker = Marker(
      markerId: MarkerId('Your location'),
      position: position,
    );

    setState(() {
      markers.add(marker);
    });
    // String? placeId = await getPlaceID(position);
    // if (placeId == null) {
    //   return;
    // }
    // PlaceInfo? placeInfo = await getPlaceInfo(placeId);
    placeInfo = await getGooglePlacesInfo(position);
    if (placeInfo != null) {
      Fluttertoast.showToast(
          msg: "Selected " + placeInfo!.address,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future goToPlace({bool isLocation = false}) async {
    if (controller == null) {
      return;
    }
    Fluttertoast.showToast(
        msg: "Getting your current location",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    LocationData? locationdata =
        isLocation ? await MapFunctions().getCurrentLocation() : null;
    targetPosition = !isLocation
        ? await widget.getLocation()
        : LatLng(locationdata!.latitude!, locationdata.longitude!);
    if (targetPosition == null) {
      return;
    }
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(target: targetPosition!, zoom: 15));
    controller!.animateCamera(cameraUpdate);
    print(targetPosition);
    Marker marker = Marker(
      markerId: MarkerId('Your location'),
      position: targetPosition!,
    );
    setState(() {
      markers.add(marker);
    });
    _selectLocation(targetPosition!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Place Picker"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.422, -122.084),
              zoom: 17.0,
            ),
            onTap: _selectLocation,
            markers: markers,
            onMapCreated: (controller) {
              setState(() {
                this.controller = controller;
              });
              goToPlace();
            },
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      color: Colors.white,
                      child: SizedBox(
                        width: 300,
                        child:
                            Autocomplete(optionsBuilder: widget.optionsBuilder),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: goToPlace,
                        child: const Icon(Icons.search),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if(targetPosition == null && placeInfo == null){
                    Fluttertoast.showToast(
                        msg: "Please place a marker first!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                  else{
                    widget.stateUpdate(placeInfo!.address);
                    widget.stateLocationUpdate(GeoPoint(placeInfo!.coordinates!.latitude, placeInfo!.coordinates!.longitude));
                    Navigator.pop(context);
                  }
                },
                child: Text("Confirm"),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(62, 154, 171, 1),
        onPressed: () {
          goToPlace(isLocation: true);
        },
        child: Icon(Icons.gps_fixed),
      ),
    );
  }
}

class PlaceInfo {
  final String name;
  final String address;
  LatLng? coordinates;

  PlaceInfo({required this.name, required this.address, this.coordinates});

  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    return PlaceInfo(
      name: json['name'],
      address: json['formatted_address']
    );
  }
}

Future<String?> getPlaceID(LatLng location) async {
  final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
      'types=establishment&rankby=distance'
      '&location=${location.latitude},${location.longitude}'
      '&key=AIzaSyA036peXUIQNZBVdCKs6n3Ymin6K8OLenQ';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = convert.jsonDecode(response.body);
    final results = data['results'][0];
    if (results.length > 0) {
      return results["place_id"];
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Future<PlaceInfo> getPlaceInfo(String placeId) async {
  final url = 'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&key=AIzaSyA036peXUIQNZBVdCKs6n3Ymin6K8OLenQ';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = convert.jsonDecode(response.body);
    final result = data['result'];
    return PlaceInfo(
      name: result['name'],
      address: result['formatted_address'],
    );
  } else {
    throw Exception('Failed to get place');
  }
}


Future<PlaceInfo> getGooglePlacesInfo(LatLng position) async {
  String apiKey = 'AIzaSyA036peXUIQNZBVdCKs6n3Ymin6K8OLenQ';
  // String url = 'https://maps.googleapis.com/maps/api/geocode/json?result_type=street_address&latlng=${position.latitude},${position.longitude}&key=$apiKey';
  String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

  // Make the API request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      String keyToCheck = 'plus_code';
      if (data.containsKey(keyToCheck)) {
        final plusCodeData = data['plus_code'];
        if (plusCodeData.containsKey('compound_code')) {
          final compoundCodeData = plusCodeData['compound_code'];
          return PlaceInfo(
            name: compoundCodeData,
            address: compoundCodeData,
            coordinates: position
          );
        }
        else{
          throw Exception('Failed to get place');
        }
      } else {
        throw Exception('Failed to get place');
      }

      // final result = data['results'][0];
      // return PlaceInfo(
      //   name: result['name'],
      //   address: result['formatted_address'],
      // );
    } else {
      throw Exception('Failed to get place');
    }
  }
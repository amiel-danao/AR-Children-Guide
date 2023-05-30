import 'dart:async';

import 'package:ar/dashboard/place_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/profiles/child.dart';
import '../widget_builder.dart';
import 'maps/location_service.dart';

class JourneyForm extends StatefulWidget {
  final String journeyId;
  const JourneyForm({super.key, required this.journeyId});

  @override
  State<JourneyForm> createState() => _JourneyFormState();
}

class _JourneyFormState extends State<JourneyForm> {
  String startPosition = "";
  String destination = "";
  GeoPoint? startLocation;
  GeoPoint? endLocation;

  List<String> searchHints = List.empty(growable: true);
  final debouncer = Debouncer(milliseconds: 3000);
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    debouncer.cancel();
    super.dispose();
  }

  void updateStartLocation(String address) {
    setState(() {
      startPosition = address;
    });
  }

  void updateEndLocation(String address) {
    setState(() {
      destination = address;
    });
  }

  void updateStartCoordinate(GeoPoint coordinate) {
    setState(() {
      startLocation = coordinate;
    });
  }

  void updateEndCoordinate(GeoPoint coordinate) {
    setState(() {
      endLocation = coordinate;
    });
  }

  Future<LatLng?> goToPlaceStart({String? address}) async {
    if (startPosition == "") {
      return null;
    }
    List<Location> locations = await locationFromAddress(startPosition);
    Location location = locations.first;
    return LatLng(location.latitude, location.longitude);
  }

  Future<LatLng?> goToPlaceEnd({String? address}) async {
    if (destination == "") {
      return null;
    }
    try {
      List<Location> locations = await locationFromAddress(destination);
      Location location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Journey")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // createInput(context, 300, "StartLocation"),
              // createInput(context, 300, "Destination"),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Start Position",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 300,
                        child: Text(
                          startPosition,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: actionButton(
                          context,
                          "Pick",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  positionType: "startPosition",
                                  getLocation: goToPlaceStart,
                                  stateUpdate: updateStartLocation,
                                  stateLocationUpdate: updateStartCoordinate,
                                  optionsBuilder: (TextEditingValue
                                      textEditingValue) async {
                                    return debouncer.run(() async {
                                      List<String> searchHintsAwait =
                                          await LocationService()
                                              .getPlaces(textEditingValue.text);
                                      if (mounted) {
                                        setState(() {
                                          print("hello");
                                          startPosition = textEditingValue.text;
                                          searchHints = searchHintsAwait;
                                        });
                                      }
                                      return searchHints;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Destination",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        width: 300,
                        child: Text(
                          destination,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: actionButton(
                          context,
                          "Pick",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  positionType: "endPosition",
                                  getLocation: goToPlaceEnd,
                                  stateUpdate: updateEndLocation,
                                  stateLocationUpdate: updateEndCoordinate,
                                  optionsBuilder: (TextEditingValue
                                      textEditingValue) async {
                                    return debouncer.run(() async {
                                      List<String> searchHintsAwait =
                                          await LocationService()
                                              .getPlaces(textEditingValue.text);
                                      print(searchHintsAwait.length);
                                      if (mounted) {
                                        setState(() {
                                          print("hellos");
                                          destination = textEditingValue.text;
                                          searchHints = searchHintsAwait;
                                        });
                                      }
                                      return searchHints;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),

              SizedBox(
                width: 300,
                child: actionButton(
                  context,
                  "Add",
                  onPressed: () async {
                    var journey = {
                      "from": startPosition,
                      "to": destination,
                      "created_at": Timestamp.fromDate(DateTime.now()),
                      "startLocation": startLocation,
                      "endLocation": endLocation
                    };
                    Child().addJourney(journey).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Wait for few seconds to see changes")));
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, "/dashboard_child");
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;
  bool isCancelled = false;

  Debouncer({required this.milliseconds});

  Future<List<String>> run(Future<List<String>> Function() action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    final completer = Completer<List<String>>();
    _timer = Timer(Duration(milliseconds: milliseconds), () async {
      if (!isCancelled) {
        completer.complete(await action());
      }
    });
    return completer.future;
  }

  void cancel() {
    isCancelled = true;
  }
}

import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ar/dashboard/maps/arrow_widget.dart';
import 'package:ar/dashboard/maps/maps.dart';
import 'package:ar/dashboard/maps/notification.dart';
import 'package:ar/dashboard/maps/streetview.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../auth/auth.dart';
import '../../auth/profiles/child.dart';
import '../../main.dart';
import 'package:vector_math/vector_math_64.dart' show radians, degrees;

import '../../models/ChildNotification.dart';
import '../../widget_builder.dart';
import 'location_service.dart';

class ARView extends StatefulWidget {

  const ARView(
      {super.key,
      required this.startDestination,
      required this.endDestination,
      required this.endLocation,
      required this.polylines,
      required this.journeyId});
  final LatLng startDestination;
  final LatLng endDestination;
  final String journeyId;
  final GeoPoint? endLocation;
  final Set<Polyline> polylines;

  @override
  State<ARView> createState() => _ARViewState();
}

class _ARViewState extends State<ARView> {
  LatLng? currentLocation;
  Timer? timer;
  CameraController? controller;
  var cameraIndex = 0;
  double compassAngle = 0;
  double directionAngle = 0;
  // final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController googleMapController;
  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  BitmapDescriptor? customMarkerIcon;
  Set<Polyline> polylines = <Polyline>{};
  int _polylineIdCounter = 1000;
  static LatLng? endDen;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 24,
  );

  static Future<void> callback() async {
    print("hello");
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final prefs = await SharedPreferences.getInstance();

    LatLng myCurrentLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    final currentLat = myCurrentLocation.latitude;
    final currentLng = myCurrentLocation.longitude;
    final endLat = double.parse(prefs.getString("endLat")!);
    final endLng = double.parse(prefs.getString("endLong")!);
    if (currentLat != null && currentLng != null) {
      final distance =
          calculateDistance(currentLat, currentLng, endLat, endLng);
      print(distance);
      NotificationAPI.showNotifications(
          title: "Distance to destination",
          body: 'Distance: ${distance.toInt()} meters');
    }
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    final R = 6371;
    final dLat = radians(lat2 - lat1);
    final dLon = radians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final d = R * c * 1000;
    return d;
  }

  void plotJourney() async {
    if (currentLocation == null) {
      return;
    }

    dynamic end = widget.endDestination;

    if(widget.endLocation != null){
      end = widget.endLocation;
    }

    var directions = await LocationService().getDirections(
      GeoPoint(currentLocation!.latitude, currentLocation!.longitude),
      end,
    );
    if (directions == null) {
      return;
    }

    _setPolyline(directions['polyline_decoded']);
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.green,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString(
          "endLat", widget.endDestination.latitude.toString());
      await prefs.setString(
          "endLong", widget.endDestination.longitude.toString());
      print("initialized");
      print(await NotificationAPI.init());
      AndroidAlarmManager.periodic(const Duration(minutes: 1), 0, callback,
              wakeup: true)
          .then((value) {
        print('value: $value');
        callback();
      });
    });
  }

  void initializeEverything(){
    initializeCameraController();
    getCurrentLocation();
    timer = Timer.periodic(
        const Duration(seconds: 1), (timer) => getCurrentLocation());
    FlutterCompass.events!.listen((event) {
      if (mounted) {
        setState(() {
          compassAngle = event.heading!;
        });
      }
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/marker.png')
        .then((onValue) {
      if (!mounted) {
        return;
      }
      setState(() {
        customMarkerIcon = onValue;
      });
    });

    polylines.addAll(widget.polylines);
  }

  @override
  void dispose() {
    AndroidAlarmManager.cancel(0);
    super.dispose();
  }

  Future getCurrentLocation() async {
    LocationData locationData = await MapFunctions().getCurrentLocation();
    if (mounted) {
      setState(() {
        currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        directionAngle = calculateBearing(
            currentLocation!.latitude,
            currentLocation!.longitude,
            widget.endDestination.latitude,
            widget.endDestination.longitude);
      });
    }
    await moveToLocation();
    plotJourney();
  }

  Future<void> moveToLocation() async {
    // GoogleMapController controller = await _controller.future;
    if (currentLocation == null) {
      return;
    }
    try {
      double zoomLevel = await googleMapController.getZoomLevel();
      CameraPosition newPosition = CameraPosition(
          bearing: compassAngle + 180,
          zoom: zoomLevel,
          target:
              LatLng(currentLocation!.latitude, currentLocation!.longitude));
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(newPosition));
      if (mounted) {
        setState(() {
          _markers.add(createMarker("currentLocation", "Your Current Location",
              LatLng(currentLocation!.latitude, currentLocation!.longitude),
              icon: customMarkerIcon, onTap: () {
            showCustomMarkerDialog(
                LatLng(currentLocation!.latitude, currentLocation!.longitude));
          }));
        });
      }
      _setMarker(widget.startDestination, "startlocation");
      _setMarker(widget.endDestination, "endlocation");

      final distance =
      calculateDistance(currentLocation!.latitude, currentLocation!.longitude, widget.endDestination.latitude, widget.endDestination.longitude);
      if(distance <= 2) {
        sendArriveNotification();
      }
      print('distance: $distance');
    } catch (e) {
      return;
    }
  }

  void _setMarker(LatLng point, String markerID) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerID),
          position: point,
          onTap: () {
            showCustomMarkerDialog(point);
          },
        ),
      );
    });
  }

  void showCustomMarkerDialog(LatLng positon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ElevatedButton(
            onPressed: () {
              showStreetView(
                positon.latitude.toString(),
                positon.longitude.toString(),
              );
              Navigator.of(context).pop();
            },
            child: const Text("Street View"),
          ),
        );
      },
    );
  }

  Future<void> showStreetView(String lat, String lng) async {
    // GoogleMapController controller = await _controller.future;
    CameraPosition newPosition = CameraPosition(
      zoom: await googleMapController.getZoomLevel(),
      target: LatLng(
        double.parse(lat),
        double.parse(lng),
      ),
    );
    await googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(newPosition),
    );
    StreetViewer.showStreetView(
      lat,
      lng,
      "139.26709247816694",
      "8.931085777681233",
    );
  }

  Future<void> initializeCameraController() async {
    setState(() {
      controller = CameraController(cameras[0], ResolutionPreset.max);
      cameraIndex = 0;
    });

    await controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    var dLon = radians(lon2 - lon1);
    var y = sin(dLon) * cos(radians(lat2));
    var x = cos(radians(lat1)) * sin(radians(lat2)) -
        sin(radians(lat1)) * cos(radians(lat2)) * cos(dLon);
    var brng = atan2(y, x);
    return (degrees(brng) + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR View"),
      ),
      body: Stack(
        children: [
          controller != null
              ? Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          // switch to the next camera in the list
                          final index = cameraIndex;
                          final nextCamera =
                              cameras[(index + 1) % cameras.length];
                          setState(() {
                            cameraIndex = (index + 1) % cameras.length;
                            controller = CameraController(
                                nextCamera, ResolutionPreset.max);
                          });
                        },
                        child: SizedBox(
                            height:
                                MediaQuery.of(context).size.height * (3 / 5),
                            child: CameraPreview(controller!)),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: ArrowWidget(directionAngle + compassAngle),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * (2 / 5),
              child: GoogleMap(
                mapType: MapType.satellite,
                markers: _markers,
                polygons: _polygons,
                polylines: polylines,
                initialCameraPosition: _kGooglePlex,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 24),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    googleMapController = controller;
                  });

                  initializeEverything();

                  // _controller.complete(controller);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> sendArriveNotification() async {
    final uid = Auth().currentUser!.uid;
    DocumentReference documentRef = FirebaseFirestore.instance.collection('Notifications').doc(widget.journeyId);

    DocumentSnapshot documentSnapshot = await documentRef.get();

    if (documentSnapshot.exists) {
      print('Document exists');
    } else {
      print('Document does not exist');

      var profile = await Child().getProfile();

      var parentId = profile['parentId']??"";

      ChildNotification childNotification = ChildNotification(
        uid: uid,
        username: profile['username'],
        parentId: parentId,
        dateNotified: Timestamp.now(), // Replace with your desired timestamp
        viewed: false
      );

      CollectionReference notificationsCollection = FirebaseFirestore.instance.collection('Notifications');
      await notificationsCollection.doc(widget.journeyId).set(childNotification.toMap());

    }
  }
}

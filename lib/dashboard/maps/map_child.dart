import 'dart:async';
import 'package:ar/dashboard/maps/ar_view.dart';
import 'package:ar/dashboard/maps/notification.dart';
import 'package:ar/dashboard/maps/streetview.dart';
import 'package:ar/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';
import '../../auth/profiles/child.dart';
import '../../widget_builder.dart';
import 'location_service.dart';
import 'maps.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class MapViewChildren extends StatefulWidget {
  final String startDestination;
  final String endDestination;
  final GeoPoint? startLocation;
  final GeoPoint? endLocation;
  final String journeyId;

  const MapViewChildren(
      {super.key,
      required this.startDestination,
      required this.endDestination, this.startLocation, this.endLocation, required this.journeyId});

  @override
  State<MapViewChildren> createState() => _MapViewChildrenState();
}

class _MapViewChildrenState extends State<MapViewChildren> {
  GeoCode geoCode = GeoCode();
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polylineIdCounter = 1;

  List<String> searchHints = List<String>.empty(growable: true);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Timer? timer;

  LocationData? currentLocation;
  Marker? currentLocationMarker;

  LatLng? destinationPosition;
  LatLng? startPosition;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void showDistanceNotification(LatLng destination) async {
    LocationData currentLocation = await MapFunctions().getCurrentLocation();
    // double distance = Geolocator.distanceBetween(
    //     currentLocation.latitude!,
    //     currentLocation.longitude!,
    //     destination.latitude,
    //     destination.longitude);
    // NotificationAPI.showNotifications(
    //     title: "Distance to destination", body: 'Distance: $distance meters');
  }

  @override
  void initState() {
    setState(() {
      _originController.text = widget.startDestination;
      _destinationController.text = widget.endDestination;
    });

    super.initState();

    timer =
        Timer.periodic(const Duration(seconds: 60), (Timer t) => getLocation());


  }

  void initialPositions() async{
    // await moveToLocation();
    await getLocation();
    GoogleMapController controller = await _controller.future;
    CameraPosition newPosition = CameraPosition(
        zoom: await controller.getZoomLevel(),
        target:
        LatLng(startPosition!.latitude!, startPosition!.longitude!));
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    plotJourney();
  }

  @override
  void dispose() {
    timer!.cancel();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> moveToLocation() async {
    GoogleMapController controller = await _controller.future;
    await getLocation();
    if (currentLocation == null) {
      await moveToLocation();
      return;
    }
    CameraPosition newPosition = CameraPosition(
        zoom: await controller.getZoomLevel(),
        target:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  Future<void> getLocation() async {
    LocationData currentLocationAwait =
        await MapFunctions().getCurrentLocation();

    if (mounted) {
      setState(() {
        currentLocation = currentLocationAwait;
        _markers.add(createMarker("currentLocation", "Your Current Location",
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            onTap: () {
          showCustomMarkerDialog(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
        }));
      });
    }
    Child().updateLocation(
        currentLocationAwait.latitude!, currentLocationAwait.longitude!);

    if (destinationPosition != null) {
      showDistanceNotification(destinationPosition!);
    } else {
      dynamic start = widget.startDestination;
      dynamic end = widget.endDestination;

      if(widget.startLocation != null){
        start = widget.startLocation;
      }

      if(widget.endLocation != null){
        end = widget.endLocation;
      }

      final directions = await LocationService().getDirections(
        start,
        end,
      );
      if (directions == null) {
        return;
      }
      setState(() {
        startPosition = LatLng(
          directions['start_location']['lat'],
          directions['start_location']['lng'],
        );
        destinationPosition = LatLng(
          directions['end_location']['lat'],
          directions['end_location']['lng'],
        );
      });
      showDistanceNotification(destinationPosition!);
    }
  }

  void _setMarker(LatLng point, String markerID) async{
    var icon = BitmapDescriptor.defaultMarker;
    if(markerID == "endlocation") {
      icon = await BitmapDescriptorHelper.getBitmapDescriptorFromSvgAsset(
          "assets/images/destination.svg");
    }
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerID),
          position: point,
          icon: icon,
          onTap: () {
            showCustomMarkerDialog(point);
          },
        ),
      );
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Future<void> showStreetView(double? lat, double? lng) async {
    GoogleMapController controller = await _controller.future;
    CameraPosition newPosition = CameraPosition(
      zoom: await controller.getZoomLevel(),
      target: LatLng(
        lat??37.42796133580664,
        lng??-122.085749655962,
      ),
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newPosition),
    );
    StreetViewer.showStreetView(
      lat.toString(),
      lng.toString(),
      "139.26709247816694",
      "8.931085777681233",
    );
  }

  void showCustomMarkerDialog(LatLng positon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ElevatedButton(
            onPressed: () {
              showStreetView(
                positon.latitude,
                positon.longitude,
              );
              Navigator.of(context).pop();
            },
            child: const Text("Street View"),
          ),
        );
      },
    );
  }

  Widget renderMap(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Column(
                  children: [
                    TextFormField(
                      autofillHints: searchHints,
                      controller: _originController,
                      decoration: const InputDecoration(hintText: ' Origin'),
                      onChanged: (value) {},
                    ),
                    TextFormField(
                      autofillHints: searchHints,
                      controller: _destinationController,
                      decoration:
                          const InputDecoration(hintText: ' Destination'),
                      onChanged: (value) {
                        LocationService().getPlaces(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: plotJourney,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(flex: 2, child: ElevatedButton(
              onPressed: (){
                showStreetView(currentLocation!.latitude, currentLocation!.longitude);
                },
              child: const Text("Street View", style: TextStyle(color: Colors.red, fontSize: 20),),
            ),

          ),
            const SizedBox(
              width: 10,
            ),
          Expanded(child: ElevatedButton(
            onPressed: moveToLocation,
            child: Icon(Icons.gps_fixed),
          ))
          ,
          const SizedBox(
            width: 10,
          ),
          Expanded(flex: 2, child: ElevatedButton(
            onPressed: renderAr,
            child: const Text("Start AR", style: TextStyle(color: Colors.red, fontSize: 20),),
          ))
          ,
        ],),
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.hybrid,
                markers: _markers,
                polygons: _polygons,
                polylines: _polylines,
                // myLocationEnabled: true,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  initialPositions();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void renderAr() {
    if (destinationPosition == null && startPosition == null) {
      getLocation().then((value) => {toArView()});
      return;
    } else {
      toArView();
    }
  }

  void toArView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARView(
          startDestination: startPosition!,
          endDestination: destinationPosition!,
          endLocation: widget.endLocation,
          polylines: _polylines,
          journeyId: widget.journeyId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: renderMap(context));
  }

  void plotJourney() async {
    dynamic start = widget.startDestination;
    dynamic end = widget.endDestination;

    if(widget.startLocation != null){
      start = widget.startLocation;
    }

    if(widget.endLocation != null){
      end = widget.endLocation;
    }

    var directions = await LocationService().getDirections(
      start,
      end,
    );
    if (directions == null) {
      return;
    }
    print(directions);
    _goToPlace(
      LatLng(directions['start_location']['lat'],
          directions['start_location']['lng']),
      LatLng(
          directions['end_location']['lat'], directions['end_location']['lng']),
      directions['bounds_ne'],
      directions['bounds_sw'],
    );

    _setPolyline(directions['polyline_decoded']);
  }

  Future<void> _goToPlace(
    // Map<String, dynamic> place,

    LatLng startPosition,
    LatLng endPosition,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: startPosition, zoom: 14.4746),
      ),
    );
    print("he");

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    print("animated");
    _setMarker(startPosition, "startlocation");
    _setMarker(endPosition, "endlocation");
    showDistanceNotification(endPosition);
  }

}

class BitmapDescriptorHelper {

  static Future<BitmapDescriptor> getBitmapDescriptorFromSvgAsset(
      String assetName, [
        Size size = const Size(48, 48),
      ]) async {
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);

    double devicePixelRatio = ui.window.devicePixelRatio;
    int width = (size.width * devicePixelRatio).toInt();
    int height = (size.height * devicePixelRatio).toInt();

    final scaleFactor = min(
      width / pictureInfo.size.width,
      height / pictureInfo.size.height,
    );

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final rasterPicture = recorder.endRecording();

    final image = rasterPicture.toImageSync(width, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }
}
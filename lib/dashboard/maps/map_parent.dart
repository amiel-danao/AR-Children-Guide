import 'dart:async';
import 'package:ar/dashboard/maps/streetview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../auth/profiles/parent.dart';
import '../../widget_builder.dart';
import 'location_service.dart';
import 'map_child.dart';
import 'maps.dart';

class MapViewParent extends StatefulWidget {
  final String startDestination;
  final String endDestination;
  final GeoPoint? startLocation;
  final GeoPoint? endLocation;

  final String childID;
  const MapViewParent(
      {super.key,
      required this.startDestination,
      required this.endDestination,
      required this.startLocation,
      required this.endLocation,
      required this.childID});

  @override
  State<MapViewParent> createState() => _MapViewParentState();
}

class _MapViewParentState extends State<MapViewParent> {
  GeoCode geoCode = GeoCode();
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];

  LocationData? currentLocation;
  LatLng? childrenLocation;
  Marker? currentLocationMarker;

  int _polylineIdCounter = 1;

  List<String> searchHints = List<String>.empty(growable: true);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Timer? timer;

  @override
  void initState() {
    searchHints.add("hello");

    setState(() {
      _originController.text = widget.startDestination;
      _destinationController.text = widget.endDestination;
    });

    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 60), (Timer t) => getLocation());


  }

  @override
  void dispose() {
    timer!.cancel();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> moveToChildren() async {
    GoogleMapController controller = await _controller.future;
    childrenLocation = await Parent().getChildLocation(widget.childID);

    CameraPosition newPosition =
        CameraPosition(zoom: 14.4746, target: childrenLocation!);
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));

    if (!mounted) {
      return;
    }
    setState(() {
      _markers.add(createMarker(
          "childrenLocation", "Your Child's Latest Location", childrenLocation!,
          onTap: () {
        showCustomMarkerDialog(childrenLocation!);
      }));
    });
  }

  Future<void> moveToLocation() async {
    GoogleMapController controller = await _controller.future;
    await getLocation();
    if (currentLocation == null) {
      await getLocation();
      return;
    }
    CameraPosition newPosition = CameraPosition(
        zoom: 14.4746,
        target:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    if (mounted) {
      var icon = await BitmapDescriptorHelper.getBitmapDescriptorFromSvgAsset(
          "assets/images/parent_icon.svg");

      setState(() {
        _markers.add(createMarker("currentLocation", "Your Current Location",
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            onTap: () {
          showCustomMarkerDialog(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
        }, icon: icon)
        );
      });
    }
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
    GoogleMapController controller = await _controller.future;
    CameraPosition newPosition = CameraPosition(
      zoom: 14.4746,
      target: LatLng(
        double.parse(lat),
        double.parse(lng),
      ),
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newPosition),
    );
    StreetViewer.showStreetView(
      lat,
      lng,
      "139.26709247816694",
      "8.931085777681233",
    );
  }

  Future<void> getLocation() async {
    if (!mounted) {
      return;
    }

    LocationData currentLocationAwait =
        await MapFunctions().getCurrentLocation();
    currentLocation = currentLocationAwait;
    LatLng latLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    var icon = await BitmapDescriptorHelper.getBitmapDescriptorFromSvgAsset(
        "assets/images/parent_icon.svg");

    setState(() {
      _markers.add(

          createMarker("currentLocation", "Your Current Location", latLng, icon: icon));
    });
  }

  void _setMarker(LatLng point, String markerID) {
    if (!mounted) {
      return;
    }
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerID),
          position: point,
        ),
      );
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    var polyline = Polyline(
      polylineId: PolylineId(polylineIdVal),
      width: 2,
      color: Colors.blue,
      points: points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
    );
    _polylines.add(
      polyline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: renderMap(context));
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
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.satellite,
                markers: _markers,
                polygons: _polygons,
                polylines: _polylines,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  await moveToChildren();
                  plotJourney();
                },
              ),
              Positioned(
                bottom: 10,
                right: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Row(
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: moveToChildren,
                    //       child: Stack(children: [
                    //         Icon(Icons.child_care),
                    //         Positioned(
                    //           right: 1,
                    //           child: SizedBox(
                    //               child: Icon(
                    //             Icons.gps_fixed,
                    //             size: 12,
                    //             color: Colors.lightGreenAccent,
                    //           )),
                    //         )
                    //       ]),
                    //     ),
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: moveToLocation,
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(60, 60), // Increase the button size by adjusting the width and height
                            padding: const EdgeInsets.all(20), // Increase the button size by adjusting the padding
                          ),
                          child: const Icon(Icons.gps_fixed),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: plotJourney,
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(60, 60), // Increase the button size by adjusting the width and height
                            padding: const EdgeInsets.all(20), // Increase the button size by adjusting the padding
                          ),
                          child: const Icon(Icons.route),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    if (mounted) {
      setState(() {
        _markers.add(createMarker(
          "startPosition",
          widget.startDestination,
          startPosition,
          onTap: () => showCustomMarkerDialog(startPosition),
        ));
        _markers.add(createMarker(
          "endPosition",
          widget.endDestination,
          endPosition,
          onTap: () => showCustomMarkerDialog(endPosition),
        ));
      });
    }
  }
}

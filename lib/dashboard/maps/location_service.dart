import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final String key = 'AIzaSyA036peXUIQNZBVdCKs6n3Ymin6K8OLenQ';

  Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;
    return placeId;
  }

  Future<List<String>> getPlaces(String input) async {
    List<String> places = List.empty(growable: true);

    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    List<dynamic> results = json['results'] as List<dynamic>;

    for (var result in results) {
      Map<String, dynamic> resultMap = result as Map<String, dynamic>;
      places.add(resultMap["formatted_address"]);
    }

    // for (int i = 0; i < placeIDs.length; i++) {
    //   dynamic placeID = placeIDs[i];
    //   Map<String, dynamic> placeDetail =
    //       await getPlaceFromID((placeID as Map<String, dynamic>)["place_id"]);
    //   places.add(placeDetail["formatted_address"]);
    // }
    return places;
  }

  Future<Map<String, dynamic>> getPlaceFromID(String placeID) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    return results;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);

    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    return results;
  }

  Future<Map<String, dynamic>?> getDirections(
      dynamic origin, dynamic destination) async {
    if (origin is GeoPoint) {
      origin = "${origin.latitude},${origin.longitude}";
    }
    if (destination is GeoPoint) {
      destination = "${destination.latitude},${destination.longitude}";
    }
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';
    try {
      var response = await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);

      var results = {
        'bounds_ne': json['routes'][0]['bounds']['northeast'],
        'bounds_sw': json['routes'][0]['bounds']['southwest'],
        'start_location': json['routes'][0]['legs'][0]['start_location'],
        'end_location': json['routes'][0]['legs'][0]['end_location'],
        'polyline': json['routes'][0]['overview_polyline']['points'],
        'polyline_decoded': PolylinePoints()
            .decodePolyline(json['routes'][0]['overview_polyline']['points']),
      };
      return results;
    } catch (e) {
      // Fluttertoast.showToast(
      //     msg:
      //         "Getting directions error(internet connection problem), please try again later",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      return null;
    }
  }
}

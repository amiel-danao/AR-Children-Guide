import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import 'profile.dart';

class Child extends Profile {
  String type = "Child";

  @override
  String name = "Child";

  Future<Map<String, dynamic>> getProfile() async {
    String path = "users/child/list/${user!.uid}";
    DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
        await Database().getDocumentSnapshot(path);
    Map<String, dynamic> profileData = profileSnapshot.data()!;
    return profileData;
  }

  Future<UserCredential?> create(
      FirebaseApp app, String username, String password) async {
    try {
      return await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(
              email: "$username@armobile.com", password: password);
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return null;
    }
  }

  Future<bool> delete(FirebaseApp app, String username, String password) async {
    try {
      UserCredential? credential = await FirebaseAuth.instanceFor(app: app)
          .signInWithEmailAndPassword(email: username, password: password);
      User? childUser = credential.user!;
      AuthCredential? authCredential = credential.credential;
      if (authCredential == null) {
        if (childUser == null) {
          return false;
        }
        credential = await childUser.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: username, password: password));
      }
      credential.user!.delete();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<void> addJourney(Map<String, dynamic> data) async {
    String journeyId = const Uuid().v1();
    Database().setDocumentData(
        "users/child/list/${user!.uid}/journeys/$journeyId", data);
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    Database().setDocumentData(
      "users/child/list/${user!.uid}",
      {
        "location": {"latitude": latitude, "longitude": longitude},
      },
    );
  }

  Future<List<Map<String, dynamic>>> getJourneys() async {
    String path = "users/child/list/${user!.uid}/journeys";
    List<QueryDocumentSnapshot<Map<String, dynamic>>> collectionList =
        await Database().getDocs(path);

    List<Map<String, dynamic>> journeyList = [];
    await Future.forEach(collectionList, (journeySnapshot) {
      var data = journeySnapshot.data();
      data["id"] = journeySnapshot.id;
      journeyList.add(data);
    });
    return journeyList;
  }

  Future<void> deleteJourney(String id) async {
    String path = "users/child/list/${user!.uid}/journeys/$id";
    DocumentReference<Map<String, dynamic>> documentReference =
        Database().getDocumentReference(path);
    documentReference.delete();
    return;
  }

  Future<void> setProfile(Map<String, dynamic> data) async {
    String path = "users/child/list/${user!.uid}";
    Database().setDocumentData(path, data);
  }

  Future<void> updateActiveStatus() async {
    if (user == null) {
      return;
    }
    String path = "users/child/list/${user!.uid}";
    DateTime currentTime = DateTime.now();
    Timestamp currentTimeStamp = Timestamp.fromDate(currentTime);
    var data = {
      "active_at": currentTimeStamp,
    };
    await Database().setDocumentData(path, data);
  }
}

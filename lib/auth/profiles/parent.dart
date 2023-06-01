import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../database.dart';
import 'child.dart';
import 'profile.dart';

class Parent extends Profile {
  @override
  String name = "Parent";

  Future<void> setProfile(Map<String, dynamic> data, {String? email}) async {
    String? path;
    if (email != null) {
      path = "users/parent/list/$email";
    } else {
      path = "users/parent/list/${user!.email}";
    }
    await Database().setDocumentData(path, data);
  }

  Future<void> updateActiveStatus() async {
    if (user == null) {
      return;
    }
    String path = "users/parent/list/${user!.email}";
    DateTime currentTime = DateTime.now();
    Timestamp currentTimeStamp = Timestamp.fromDate(currentTime);
    var data = {
      "active_at": currentTimeStamp,
    };
    await Database().setDocumentData(path, data);
  }

  Future<Map<String, dynamic>> getProfile() async {
    String path = "users/parent/list/${user!.email}";
    DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
        await Database().getDocumentSnapshot(path);
    Map<String, dynamic> profileData = profileSnapshot.data()!;
    return profileData;
  }

  Future<int> getChildCount() async {
    if (user == null) {
      return 0;
    }
    String path = "users/parent/list/${user!.email}/children";
    int childCount = await Database().getCollectionCount(path);
    return childCount;
  }

  Future<int> getChildrenActive() async {
    if (user == null) {
      return 0;
    }
    String path = "users/parent/list/${user!.email}/children";
    int childCount = 0;
    List<QueryDocumentSnapshot<Map<String, dynamic>>> collectionList =
        await Database().getDocs(path);

    await Future.forEach(collectionList, (childSnapshot) async {
      Map<String, dynamic> data = childSnapshot.data();
      Timestamp? activeAt = await checkIfActive(data["uid"]);
      if (activeAt != null) {
        final activeDate = activeAt.toDate();
        final now = DateTime.now();
        final twoMinutesAgo = now.subtract(const Duration(minutes: 5));
        if (activeDate.isAfter(twoMinutesAgo) && activeDate.isBefore(now)) {
          childCount += 1;
        }
      }
    });
    return childCount;
  }

  Future<List<Map<String, dynamic>>> getChildrenData() async {
    String path = "users/parent/list/${user!.email}/children";
    List<QueryDocumentSnapshot<Map<String, dynamic>>> collectionList =
        await Database().getDocs(path);

    List<Map<String, dynamic>> childList = [];
    await Future.forEach(collectionList, (childSnapshot) async {
      Map<String, dynamic> data = childSnapshot.data();
      Timestamp? activeAt = await checkIfActive(data["uid"]);
      if (activeAt != null) {
        final activeDate = activeAt.toDate();
        final now = DateTime.now();
        final twoMinutesAgo = now.subtract(const Duration(minutes: 5));
        print(twoMinutesAgo);
        data["isOnline"] =
            activeDate.isAfter(twoMinutesAgo) && activeDate.isBefore(now);
      } else {
        data["isOnline"] = false;
      }
      childList.add(data);
    });

    return childList;
  }

  Future<Timestamp?> checkIfActive(String uid) async {
    String path = "users/child/list/$uid";
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await Database().getDocumentSnapshot(path);
    if (!documentSnapshot.exists) {
      print("not exists");
      return null;
    }
    Map<String, dynamic>? data = documentSnapshot.data();
    print(data);
    if (data == null) {
      return null;
    }
    return data["active_at"];
  }

  Future<bool> createChild(
      String username, String password, Map<String, dynamic> info) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: "secondary", options: Firebase.app().options);

    UserCredential? creationResult =
        await Child().create(app, username, password);
    if (creationResult != null) {
      // data for child
      User child = creationResult.user!;
      String path = "users/child/list/${child.uid}";
      Map<String, dynamic> data = {
        "username": username,
        "email": child.email,
        "password": password,
        "uid": child.uid,
        "parentId": user!.uid
      };
      await Database().setDocumentData(path, data);
      await Database().setDocumentData(path, info);

      // data for parent
      path = "users/parent/list/${user!.email}/children/$username";
      await Database().setDocumentData(path, data);
      await Database().setDocumentData(path, info);
    }
    await app.delete();
    return creationResult != null;
  }

  Future<bool> deleteChildAccount(String username, String password,
      String userpath, String parentPath) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: "secondary", options: Firebase.app().options);
    bool? result = await Child().delete(app, username, password);
    print(userpath);
    print(parentPath);
    if (!result) {
      print("deletion failed");
      return false;
    }
    await Database().deleteDocument(userpath);
    await Database().deleteDocument(parentPath);
    await app.delete();
    return result;
  }

  Future<List<Map<String, dynamic>>> getChildJourneys(String uid) async {
    String path = "users/child/list/$uid/journeys";
    List<QueryDocumentSnapshot<Map<String, dynamic>>> collectionList =
        await Database().getDocs(path);

    List<Map<String, dynamic>> journeyList = [];
    await Future.forEach(collectionList, (journeySnapshot) {
      journeyList.add(journeySnapshot.data());
    });
    return journeyList;
  }

  Future<LatLng> getChildLocation(String uid) async {
    String path = "users/child/list/$uid";
    DocumentSnapshot<Map<String, dynamic>> userDataReference =
        await Database().getDocumentSnapshot(path);
    Map<String, dynamic> userData = userDataReference.data()!;
    double latitude = userData["location"]["latitude"];
    double longitude = userData["location"]["longitude"];
    return LatLng(latitude, longitude);
  }
}

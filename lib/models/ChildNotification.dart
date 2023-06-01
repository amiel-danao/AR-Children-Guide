import 'package:cloud_firestore/cloud_firestore.dart';

class ChildNotification {
  String uid;
  String username;
  String parentId;
  Timestamp dateNotified;
  bool viewed;

  ChildNotification({
    required this.uid,
    required this.username,
    required this.dateNotified,
    required this.parentId,
    required this.viewed,
  });

  factory ChildNotification.fromMap(Map<String, dynamic> map) {
    return ChildNotification(
      uid: map['uid'],
      username: map['username'],
      parentId: map['parentId'],
      dateNotified: map['dateNotified'],
      viewed: map['viewed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'parentId': parentId,
      'dateNotified': dateNotified,
      'viewed': viewed
    };
  }
}

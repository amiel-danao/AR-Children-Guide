import 'dart:io';

import 'package:ar/auth/profiles/profile.dart';
import 'package:ar/widget_builder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_app/restart_app.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _imageFile = File(result.files.first.path!);
    });
  }

  Future uploadImage() async {
    if (_imageFile == null) {
      showToast("Select a file first!");
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    Fluttertoast.showToast(
        msg: "Uploading...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    String path = "profiles/" + FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(_imageFile!).then((p0) async {
      Fluttertoast.showToast(
          msg: "Uploaded, app will restart in 2 seconds",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      await Future.delayed(Duration(seconds: 2));
      Restart.restartApp();
    }).catchError((e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                color: Color.fromARGB(179, 200, 198, 198),
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';

class Upload extends StatefulWidget {
  final User? currentUser;

  Upload({this.currentUser});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? file;

  handleTakePhoto() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker.platform.pickImage(
        source: ImageSource.camera,
        maxHeight: 675,
        maxWidth: 960,
        preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final pickedFile =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(""),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('Create Post'),
                        children: [
                          SimpleDialogOption(
                            child: const Text(
                              'Photo with Camera',
                            ),
                            onPressed: ()=> handleTakePhoto(),
                          ),
                          SimpleDialogOption(
                            child: const Text('Photo from Gallery'),
                            onPressed: ()=> handleChooseFromGallery(),
                          ),
                          SimpleDialogOption(
                            child: const Text('Cancel'),
                            onPressed: ()=> Navigator.pop(context),
                          ),
                        ],
                      );
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              child: const Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          onPressed: clearImage,
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
              onPressed: () {},
              child: const Text(
                'Post',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
        ],
      ),
      body: ListView(
        children: [
          // Container(
          //   height: 220,
          //   width: MediaQuery.of(context).size.width * 0.8,
          //   child: Center(
          //     child: AspectRatio(
          //       aspectRatio: 16/9,
          //       child: Container(
          //         decoration: BoxDecoration(
          //           image: DecorationImage(
          //               image: MemoryImage(),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}

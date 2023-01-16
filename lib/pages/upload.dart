import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user.dart';

class Upload extends StatefulWidget {
  final User? currentUser;

  Upload({this.currentUser});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File? file;
  bool fileIsUploading = false;
  String postId = Uuid().v4();

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
          //Image.asset(""),
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
                            onPressed: () => handleTakePhoto(),
                          ),
                          SimpleDialogOption(
                            child: const Text('Photo from Gallery'),
                            onPressed: () => handleChooseFromGallery(),
                          ),
                          SimpleDialogOption(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
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

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    if (imageFile != null) {
     final compressedImageFile = File("$path/img_$postId.jpg")
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
     setState(() {
       file = compressedImageFile;
     });
    }
  }
  Future<String> uploadImage(imageFile)async{
    UploadTask uploadTask = storageReference.child("post_$postId.jpg").putFile(imageFile);
    //TaskSnapshot storageSnap =  uploadTask.snapshot;
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }
  createPostInFirestore({required String mediaUrl, String? location, String? description}){
    if(widget.currentUser != null){
      postsRef.doc(widget.currentUser!.id).collection("userPosts").doc(postId).set({
        "postId": postId,
        "ownerId": widget.currentUser!.id,
        "username": widget.currentUser!.username,
        "mediaUrl": mediaUrl,
        "description": description,
        "location": location,
        "likes": {},
      });
    }
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      fileIsUploading = false;
      postId = Uuid().v4();
    });
  }

  handleSubmit() async{
    setState(() {
      fileIsUploading = true;
    });
    //Compress image
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(mediaUrl: mediaUrl, location: locationController.text, description: captionController.text);
    if(!mounted) return;
    Navigator.pop(context);
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
              onPressed: fileIsUploading ? null : () => handleSubmit(),
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
          fileIsUploading ? linearProgress() : const Text(''),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file!),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser!.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
                onPressed: () {
                  //Get user location
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    )),
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: Text(
                  "Use Current Location",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}

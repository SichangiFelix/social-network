import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  const EditProfile({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;
  User? user;

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user!.displayName;
    bioController.text = user!.bio;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Display Name',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: const InputDecoration(hintText: "Update display name"),
        ),
      ],
    );
  }

  buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Bio',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: const InputDecoration(hintText: "Update bio"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.done,
                color: Colors.green,
                size: 30,
              ))
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              CachedNetworkImageProvider(user!.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "Update Profile",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:social_network/widgets/progress.dart';

import '../widgets/header.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile', implyLeading: true),
      body: circularProgress(),
    );
  }
}
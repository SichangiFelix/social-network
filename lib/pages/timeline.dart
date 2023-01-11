import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../widgets/header.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, implyLeading: true),
      body: null,
    );
  }
}
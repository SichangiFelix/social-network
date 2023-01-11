import 'package:flutter/material.dart';

header(BuildContext context , {bool isAppTitle = false, String? titleText, required bool implyLeading}){
  return AppBar(
    automaticallyImplyLeading: implyLeading,
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
    title: Text(
      isAppTitle? 'Social Network': titleText!,
      style: TextStyle(
      color: Colors.white,
      fontSize: 30.0,
    ),),
  );
}
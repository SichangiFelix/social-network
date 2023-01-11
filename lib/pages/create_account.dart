import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/header.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

   final _formKey = GlobalKey<FormState>();
  String? username;

  submit(){
    FormState? form = _formKey.currentState;
    if(form!.validate()){
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Set up your profile", implyLeading: false),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text("Create a username", style: TextStyle(fontSize: 25.0),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (val){
                          if(val!.trim().length < 3 || val.isEmpty){
                            return "Username is too short";
                          }else if(val!.trim().length > 10){
                            return "Username is too long";
                          }else{
                            return null;
                          }
                        },
                        onSaved: (val){
                          username = val;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'username',
                          labelStyle: TextStyle(fontSize: 15),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text("Submit",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

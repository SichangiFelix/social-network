import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_network/pages/profile.dart';
import 'package:social_network/pages/search.dart';
import 'package:social_network/pages/timeline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_network/pages/upload.dart';

import '../models/user.dart';
import 'create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User currentUser;
  bool isAuth = false;

  int pageIndex = 0;

 late  PageController pageController;

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

onPageChanged(int pageIndex){
  setState(() {
    this.pageIndex = pageIndex;
  });
}

onTap(int pageIndex){
  pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
}
  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Timeline(),
          ElevatedButton(onPressed: (){
            googleSignIn.signOut();
          }, child: Text('Logout')),
          // ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot),),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active),),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35.0,),),
          BottomNavigationBarItem(icon: Icon(Icons.search),),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
              ),
              const Text(
                'Social Network',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 60,
                width: 260,
                child: ElevatedButton(
                    onPressed: (){
                      login();
                    },
                    child: const Text(
                      'Sign in with Google',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ]),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    pageController = PageController();
    //detects if user is signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('There is an error $err');
    });
    //Reauthenticate users when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print(err);
    });
  }

  @override 
  void dispose(){
    super.dispose();
    pageController.dispose();
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //check if user exsists in users collection in db according to id
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.id).get();

    if(!doc.exists){
      //If user does not exsist , we take them to create acc page
      print('Testing... to navigate to create account screeen');
      final username =  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccount()));
      //get username from create acc page and add as new doc in collection

      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
      });
      doc = await usersRef.doc(user!.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

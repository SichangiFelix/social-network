import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  Future<QuerySnapshot>? searchResultFuture;
  TextEditingController searchController = TextEditingController();

  buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          //fillColor: ,
          filled: true,
          prefixIcon: const Icon(Icons.account_box, size: 28,),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: (){
              searchController.clear();
            },
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  handleSearch(String query){
    Future<QuerySnapshot> users =  usersRef.where("displayName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultFuture = users;
    });
  }

  buildNoContent(){
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Image.asset('assets/images/search.jpg', height: 200,),
            const Text('Find users', textAlign: TextAlign.center, style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60,
            ),),
          ],
        ),
      ),
    );
  }
  buildSearchResult(){
    return FutureBuilder(
      future: searchResultFuture,
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }

          List<UserResult> searchResults = [];
          snapshot.data!.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user: user);
            print(user.displayName);
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body: searchResultFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {

  User user;

  UserResult({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white60,
      child: Column(
        children: [
          GestureDetector(
            onTap: (){},
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white12,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(user.displayName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              subtitle: Text(user.username == null? 'Null': user.username!, style: const TextStyle(
                color: Colors.black,
              ),),
            ),
          ),
          const Divider(
            height: 2,
              color: Colors.white,
          ),
        ],
      ),
    );
  }
}


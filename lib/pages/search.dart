import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mku_gossip/models/user.dart';
import 'package:mku_gossip/pages/timeline.dart';
import 'package:mku_gossip/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  Future<QuerySnapshot> searchResultsFuture;
  TextEditingController searchController = TextEditingController();

  handleSearch(String query) {
    Future<QuerySnapshot> users = userRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      // backgroundColor: Theme.of(context).accentColor.withOpacity(0.8),
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        onFieldSubmitted: handleSearch,
        decoration: InputDecoration(
            hintText: "Find your friends",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )),
      ),
    );
  }

  Container buildBlank(context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          children: [
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 400 : 200,
            ),
            Text(
              'Find Friends',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 45,
                fontStyle: FontStyle.italic,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).accentColor.withOpacity(0.4),
      backgroundColor: Colors.white,
      appBar: buildSearchField(),

      body:  searchResultsFuture == null
          ? buildBlank(context)
          : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {

  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 80,
      // width: 200,
      child: Column(children: [GestureDetector(
        onTap:()=> print('Tapped'),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:CachedNetworkImageProvider(user.photoUrl),
          ),
          title:Text(user.displayName, style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
          subtitle: Text('@${user.username}', style:TextStyle(color:Colors.black,),),
        ),
      ),
        Divider(height: 4,color:Colors.grey),

      ],
      ),
    );
  }
}

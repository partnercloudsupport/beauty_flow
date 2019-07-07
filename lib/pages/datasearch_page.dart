import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/pages/profile_page.dart';
import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  DataSearch({this.queryResultSet, this.auth, this.onSignedOut});

  List queryResultSet;
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  List<Widget> buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    String userId = queryResultSet
            .where((element) =>
                element['username'].toLowerCase() == query).toList()[0]["uid"];
    return ProfilePage(userId: userId, auth: auth, onSignedOut: onSignedOut);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : queryResultSet
            .where((element) =>
                element['username'].toLowerCase().startsWith(query))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
            onTap: () {
              this.query = suggestionList[index]["username"];
              showResults(context);
            },
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              height: 40.0,
              width: 40.0,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: suggestionList[index]["photoURL"] == null
                        ? AssetImage("assets/img/person.png")
                        : NetworkImage(suggestionList[index]["photoURL"]),
                  )),
            ),
            title: RichText(
              text: TextSpan(
                text: suggestionList[index]["username"]
                    .substring(0, query.length),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: suggestionList[index]["username"]
                        .substring(query.length),
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            subtitle: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(suggestionList[index]["displayName"] == null ? suggestionList[index]["email"] : suggestionList[index]["displayName"],
                      style: TextStyle(color: Colors.black)),
                )
              ],
            ),
          ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/pages/postdetails_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SavedPostsPage extends StatefulWidget {
  SavedPostsPage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  _SavedPostsPageState createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Posts> feedData;

  void _onRefresh() async {
    // monitor network fetch
    await _getFeed();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _getFeed() async {
    print("Staring getSaved");

    var url =
        'https://us-central1-beauty-flow.cloudfunctions.net/getSaved?uid=' +
            widget.userId.toString();
    var httpClient = HttpClient();

    List<Posts> listOfPosts;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();

        List<Map<String, dynamic>> data =
            jsonDecode(json).cast<Map<String, dynamic>>();
        listOfPosts = _generateFeed(data);
        result = "Success in http request for saved";
      } else {
        result =
            'Error getting a saved: Http status ${response.statusCode} | userId ${widget.userId.toString()}';
      }
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    print(result);

    setState(() {
      feedData = listOfPosts;
    });
  }

  List<Posts> _generateFeed(List<Map<String, dynamic>> feedData) {
    List<Posts> listOfPosts = [];

    for (var postData in feedData) {
      listOfPosts.add(Posts.fromJSON(postData));
    }

    return listOfPosts;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Beauty Flow"),
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropMaterialHeader(
          backgroundColor: Color.fromRGBO(0, 60, 126, 1),
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: feedData == null
            ? Container()
            : GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(
                  feedData.length,
                  (index) {
                    var posts = feedData[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsPage(posts),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              spreadRadius: 2,
                              blurRadius: 4,
                            ),
                          ],
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: Hero(
                            tag: posts.postId,
                            child: CachedNetworkImage(
                              imageUrl: posts.mediaUrl,
                              fit: BoxFit.cover,
                              // fadeInDuration: Duration(milliseconds: 500),
                              // fadeInCurve: Curves.easeIn,
                              placeholder: (context, url) =>
                                  SpinKitFadingCircle(
                                color: Colors.blueAccent,
                                size: 30.0,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

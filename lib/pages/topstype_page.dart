import 'package:beauty_flow/Model/Style.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/pages/postdetails_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TopStylePage extends StatefulWidget {
  TopStylePage(this.style);

  final Style style;

  @override
  _TopStylePageState createState() => _TopStylePageState();
}

class _TopStylePageState extends State<TopStylePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.style.styleName),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('beautyPosts')
              .where('style', isEqualTo: widget.style.styleName)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SpinKitChasingDots(
                  color: Colors.blueAccent,
                  size: 60.0,
                ),
              );
            }
            int length = snapshot.data.documents.length;
            if (length > 0) {
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //two columns
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemCount: length,
                  padding: EdgeInsets.all(2.0),
                  itemBuilder: (_, int index) {
                    final DocumentSnapshot doc = snapshot.data.documents[index];
                    return new GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetailsPage(Posts.fromDocument(doc)),
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
                            tag: doc.data["postId"],
                            transitionOnUserGestures: true,
                            child: CachedNetworkImage(
                              imageUrl: doc.data["mediaUrl"],
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
                  });
            } else {
              return Center(
                child: Text("No Posts Found"),
              );
            }
          }),
    );
  }
}

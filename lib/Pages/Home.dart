import 'dart:convert';
import 'dart:ui';
import 'package:awapp/Pages/Article.dart';
import 'package:awapp/Styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  var postsList;
  var postslength = 0;
  var txt = [];
  var titles = [];
  var img = [];
  var authors = [];
  var dates = [];
  var links = [];
  int postamount = 0;

  void mainStream(int post) async {
    var response = await http.get(
        'https://androidwedakarayo.com/ghost/api/v3/content/posts?key=8aff8bccef419606356a20bf70&limit=1&page=${post.toString()}&include=authors');

    if (response.statusCode == 200) {
      var posts = jsonDecode(response.body);
      setState(() {
        postslength = posts['meta']['pagination']['pages'];
        print(postamount);
        titles.add(posts['posts'][0]['title']);
        txt.add(posts['posts'][0]['html']);
        img.add(posts['posts'][0]['feature_image']);
        authors.add(posts['posts'][0]['authors'][0]['name']);
        dates.add(posts['posts'][0]['published_at']);
        links.add(posts['posts'][0]['url']);
      });
      postsList = posts;
    }
    postamount += 1;
    if (post < postslength) {
      mainStream(post + 1);
    } else {
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    }
  }

  void refresh() async {
    postslength = 0;
    txt.clear();
    titles.clear();
    img.clear();
    authors.clear();
    dates.clear();
    setState(() {
      postamount = 0;
      mainStream(1);
    });
  }

  @override
  void initState() {
    super.initState();
    mainStream(1);
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: drawer(h, w),
      endDrawer: RaisedButton(onPressed: () {}),
      backgroundColor: Colors.green,
      
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Android වැඩකාරයෝ'),
          ],
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropMaterialHeader(),
        onRefresh: () {
          refresh();
        },
        controller: refreshController,
        child: ListView.builder(
            itemCount: postamount,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(8),
                width: w * 0.9,
                child: InkWell(
                  splashColor: Colors.green[900],
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Article(
                                  img: img[index],
                                  post: txt[index],
                                  title: titles[index],
                                  author: authors[index],
                                  dates: dates[index],
                                  url: links[index],
                                )));
                  },
                  child: Card(
                    elevation: 8,
                    shape: rounded(16.0),
                    child: Column(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          ),
                          child: new CachedNetworkImage(
                            imageUrl: img[index],
                            placeholder: (context, url) => Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(4),
                          padding: EdgeInsets.all(4),
                          child: Text(
                            titles[index],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Column drawer(h, w) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: w * 0.2,
          width: w * 0.2,
          child: Card(
              shape: rounded(256.0),
              child: Icon(
                Icons.android,
                size: 48,
                color: Colors.green,
              )),
        ),
        SizedBox(height: h/4,),
        Column(
          children: <Widget>[
            Container(
              
              margin: EdgeInsets.only(bottom: 8),
              width: w * 0.6,
              height: 48,
              
              child: RaisedButton(
                elevation: 8,
                color: Colors.green,
                child: Text(
                  'Join Android වැඩකාරයෝ',
                  style: whitetxt(16),
                ),
                shape: roundedSideMenu(32.0),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              width: w * 0.6,
              height: 48,
              child: RaisedButton(
                elevation: 8,
                color: Colors.green,
                child: Text(
                  'Menu Item',
                  style: whitetxt(16),
                ),
                shape: roundedSideMenu(32.0),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
           
          ],
        ),
      ],
    );
  }
}

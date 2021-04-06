import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:viewgoal/screens/loginPage.dart';
import 'package:viewgoal/screens/playPage.dart';
import 'package:viewgoal/screens/settingsPage.dart';
import 'package:viewgoal/screens/userPage.dart';
import 'package:viewgoal/settings/Account/manage_profile.dart';

import '../config.dart';
import 'addCamera.dart';

List<dynamic> cJson = [];
var req = {};
var myME = {};

var cSave = [];
var cFollowing = [];

class MePage extends StatefulWidget {
  MePage({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MePage> {
  String dropdownValue = 'One';

  int user_id;
  var img = NetworkImage(hostname + '/images-profile/null.png');

  int likeme = 0;
  int followers = 0;

  Future<void> ch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_id = await prefs.get('user_id');
    if (user_id > 0) {
      getMe(user_id.toString());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  Future<void> getMe(id) async {
    var request =
        await http.Request('GET', Uri.parse(hostname + '/me?user_id=' + id));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String receivedJson = await response.stream.bytesToString();

      req = jsonDecode(receivedJson);
      myME = req["user"];
      cJson = req["camera"];

      cSave = myME["favorite"];
      cFollowing = myME["following"];
      for (var i = 0; i < myME["likeme"].length; i++) {
        likeme++;
      }
      for (var i = 0; i < myME["followers"].length; i++) {
        followers++;
      }
/*
      list = await json.decode(receivedJson);
      cJson = await list[1];
       */
      img = NetworkImage(hostname + '/images-profile/${id}.png');
      setState(() {});
    }
  }

  Future<void> startcam(idcam) async {
    var request = await http.Request(
        'GET', Uri.parse(hostname + '/startcam?_id=' + idcam));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        getMe(user_id.toString());
      });
    }
  }

  Future<void> stopcam(idcam) async {
    var request = await http.Request(
        'GET', Uri.parse(hostname + '/stopcam?_id=' + idcam));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        getMe(user_id.toString());
      });
    }
  }

  Future<void> removedcam(idcam) async {
    var request = await http.Request(
        'GET', Uri.parse(hostname + '/removedcam?_id=' + idcam));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        getMe(user_id.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
                Text(
                  "Setting",
                  style: TextStyle(color: Colors.black54),
                )
              ],
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManagerProfile(
                              user_id: user_id,
                              myme: myME,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: img,
                        radius: 50,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      myME["name"] != null ? myME["name"].toString() : " ",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          child: Column(
                            children: [
                              Text(followers.toString()),
                              Text("ผู้ติดตาม")
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          child: Column(
                            children: [Text(likeme.toString()), Text("ถูกใจ")],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.65,
              height: 60,
              margin: EdgeInsets.only(top: 5),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: Text(
                myME["note"] ?? "ข้อความ...",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
            ),
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Scaffold(
                  body: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(
                            child: Text(
                              "Camera",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Record",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Following",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddCameraPage(
                                                id: user_id.toString()),
                                          ),
                                        );
                                      },
                                      child: Text("Add Camera"),
                                      // shape: RoundedRectangleBorder(
                                      //   side: BorderSide(
                                      //       color: Colors.blue,
                                      //       width: 10,
                                      //       style: BorderStyle.solid),
                                      //   borderRadius: BorderRadius.circular(50),

                                      // ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Colors.blue,
                                            width: 10,
                                            style: BorderStyle.solid),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: ListView.builder(
                                        itemCount: cJson.length,
                                        itemBuilder: (context, index) {
                                          return TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PlayPage(
                                                            idcam: cJson[
                                                            index]
                                                            ["_id"])),
                                              );
                                            },
                                            child: Container(
                                              child: Card(
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 150,
                                                      height: 100,
                                                      color:
                                                      Color(0xFFF1771A),
                                                      child: Icon(
                                                        Icons
                                                            .play_circle_outline_outlined,
                                                        color: Colors.white,
                                                        size: 50,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                                '${cJson[index]['title']}'),
                                                          ),
                                                          /*
                                                          Container(
                                                            child: Text(cJson[0]['loaction']['name']??''),
                                                          ),
                                                           */
                                                          Container(
                                                            padding:
                                                            EdgeInsets
                                                                .all(1),
                                                            child: Text(
                                                              cJson[index][
                                                              'status'] ==
                                                                  true
                                                                  ? 'playing...'
                                                                  : 'stop',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black45),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      child: PopupMenuButton(
                                                        onSelected: (result) {
                                                          print(result);
                                                          if (result == 1) {
                                                            startcam(
                                                                cJson[index]
                                                                ["_id"]);
                                                          } else if (result ==
                                                              2) {
                                                            stopcam(
                                                                cJson[index]
                                                                ["_id"]);
                                                          } else if (result ==
                                                              3) {
                                                            removedcam(
                                                                cJson[index]
                                                                ["_id"]);
                                                          }
                                                        },
                                                        itemBuilder:
                                                            (context) => [
                                                          PopupMenuItem(
                                                            value: 1,
                                                            child:
                                                            Text("Start"),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 2,
                                                            child:
                                                            Text("Stop"),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 3,
                                                            child: Text(
                                                                "Removed"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: ListView.builder(
                                itemCount: cSave.length,
                                itemBuilder: (context, index) {
                                  return TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PlayPage(idcam: cSave[index])),
                                      );
                                    },
                                    child: Container(
                                      child: Card(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 100,
                                              color: Color(0xFFF1771A),
                                              child: Icon(
                                                Icons
                                                    .play_circle_outline_outlined,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(""),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: Text(''),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              child: ListView.builder(
                                itemCount: 0,
                                itemBuilder: (context, index) {
                                  return TextButton(
                                    onPressed: () {},
                                    child: Container(
                                      child: Card(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 100,
                                              color: Color(0xFFF1771A),
                                              child: Icon(
                                                Icons
                                                    .play_circle_outline_outlined,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(''),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: Text(''),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              child: ListView.builder(
                                itemCount: cFollowing.length,
                                itemBuilder: (context, index) {
                                  return TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserPage(
                                              userid: cFollowing[index]),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child: Card(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    hostname +
                                                        '/images-profile/${cFollowing[index]}.png'),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                        cFollowing[index]
                                                            .toString()),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    child: Text(''),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;

import 'main_page.dart';
import 'network_config.dart';

class ExperimentalPage extends StatefulWidget {
  const ExperimentalPage({Key key}) : super(key: key);

  @override
  _ExperimentalPageState createState() => _ExperimentalPageState();
}

class _ExperimentalPageState extends State<ExperimentalPage> {
  List<String> imageURLs = [];
  bool _initialized = false;
  bool _error = false;

  Stream cycleThroughViews(List data) async* {
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      int selection = Random().nextInt(data.length);
      yield data[selection];
    }
  }

  Future<List> getAllImagesFromServer() async {
    List<Reference> images = [];
    firebase_storage.ListResult result = await firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("screenshots")
        .listAll();

    result.items.forEach((element) async {
      // String url = await element.getDownloadURL();
      images.add(element);
    });

    return images;
  }

  Future initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      return Firebase.initializeApp();
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  void showLoadGridDialog(bool canEdit) {
    GlobalKey<FormState> loadGridKey = GlobalKey();
    TextEditingController gridLoadNameController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Load grid",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(
                      "Please enter the name of the grid",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Form(
                    key: loadGridKey,
                    child: TextFormField(
                      controller: gridLoadNameController,
                      decoration: InputDecoration(labelText: "Grid name"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Grid name required";
                        }
                        return null;
                      },
                    ),
                  )
                ],
              )),
          actions: <Widget>[
            TextButton(
              child: const Text('Load'),
              onPressed: () {
                doesGridExist(gridLoadNameController.text).then((value) {
                  Navigator.of(context).pop();

                  if (value != "not_found") {
                    if (loadGridKey.currentState.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GridPage(gridLoadNameController.text, canEdit)),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Grid does not exist'),
                    ));
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createGridDialog() async {
    GlobalKey<FormState> newGridFormKey = GlobalKey();
    TextEditingController gridLoadNameController = TextEditingController();
    TextEditingController numberOfColumnsController = TextEditingController();
    TextEditingController numberOfRowsController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create a new grid'),
          content: SingleChildScrollView(
              child: Form(
                  key: newGridFormKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: gridLoadNameController,
                      decoration: InputDecoration(labelText: 'Grid name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Grid name required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: numberOfColumnsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Grid column'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Grid column required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: numberOfRowsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Grid row'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Grid row required';
                        }
                        return null;
                      },
                    ),
                  ]))),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                // Validate returns true if the form is valid, otherwise false.
                if (newGridFormKey.currentState.validate()) {
                  isServerLive().then((value) {
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GridPage.createNewGridAndSave(
                                gridLoadNameController.text,
                                int.parse(numberOfColumnsController.text),
                                int.parse(numberOfRowsController.text))),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('An error occured'),
                      ));
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> isServerLive() async {
    try {
      var response = await http.Client().get(Uri.http(
          NetworkConfig.serverAddr + NetworkConfig.serverPort, "/ping"));

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future doesGridExist(String name) {
    Map<String, String> data = {"grid_name": name};

    return postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
        "/load_grid", data);
  }

  ///Post changes made to the UI grid to the server
  Future<String> postGridToServer(
      String addr, String path, Map<String, String> data) async {
    try {
      var response = await http.Client().post(Uri.http(addr, path), body: data);
      String grid;

      if (response.statusCode == 200) {
        grid = response.body;
      } else {
        grid = '';
      }
      return grid;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('An error occured'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire().then((value) {
      setState(() {
        _initialized = true;
      });
    }).whenComplete(() {
      getAllImagesFromServer().then((value) {
        List<Reference> images = value;
        images.forEach((ref) {
          setState(() {
            ref.getDownloadURL().then((url) {
              imageURLs.add(url);
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                child: Stack(
                  children: [
                    Container(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      MediaQuery.of(context).size.width / 2,
                                  mainAxisExtent:
                                      MediaQuery.of(context).size.height / 2,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0),
                          itemCount: 4,
                          itemBuilder: (BuildContext ctx, index) {
                            return StreamBuilder(
                              stream: cycleThroughViews(imageURLs),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  String image = snapshot.data;
                                  return Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: NetworkImage(
                                            image,
                                          )),
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        print("ds");
                                      },
                                      onLongPress: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GridPage("b", false)),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Container(
                                    color: Colors.white,
                                  );
                                }
                              },
                            );
                          }),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        width: double.maxFinite,
                        color: Colors.black.withOpacity(0.935),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                child: Text(
                              "Tskr",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            )),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  showLoadGridDialog(false);
                                },
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Text(
                                      "LOAD GRID",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  createGridDialog();
                                },
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Text(
                                      "CREATE GRID",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  showLoadGridDialog(true);
                                },
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Text(
                                      "EDIT GRID",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}

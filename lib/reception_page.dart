import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/main_page.dart';
import 'package:http/http.dart' as http;

import 'network_config.dart';

class ReceptionPage extends StatefulWidget {
  const ReceptionPage({Key key}) : super(key: key);

  @override
  _ReceptionPageState createState() => _ReceptionPageState();
}

class _ReceptionPageState extends State<ReceptionPage> {
  void showLoadGridDialog() {
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
                                GridPage(gridLoadNameController.text)),
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
                        if (value.isEmpty) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: () {
                  showLoadGridDialog();
                },
                child: Container(
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Text(
                      "LOAD GRID",
                      style: TextStyle(
                        fontFamily: "JetBrainMono",
                      ),
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
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Text(
                      "CREATE GRID",
                      style: TextStyle(
                        fontFamily: "JetBrainMono",
                      ),
                    )),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

// "assets/json/test_grid.json"
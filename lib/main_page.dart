import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:http/http.dart' as http;
import 'network_config.dart';

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  Grid grid;
  GridUIView gridView;
  bool areBtnsHidden = false;

  @override
  void initState() {
    super.initState();
    grid = Grid.getInstance();
    grid.initGridView("assets/json/test_grid.json").then((value) {
      setState(() {
        gridView = value;
      });
    });
  }

  ///Retrieve a Grid layout from the url specified
  Future<String> getGridFromServer(String url) async {
    if (url != "" && url.isEmpty) {
      throw Exception("URL value required");
    } else {
      http.Response response = await http.get(url);
      String grid;

      if (response.statusCode == 200) {
        grid = response.body;
      } else {
        grid = '';
      }

      return grid;
    }
  }

  Widget loadGridView(GridUIView gridView) {
    return grid.combinedGroups == null ? CircularProgressIndicator() : gridView;
  }

  GlobalKey<FormState> newGridFormKey = new GlobalKey<FormState>();
  TextEditingController numberOfColumnsController = new TextEditingController();
  TextEditingController numberOfRowsController = new TextEditingController();

  GlobalKey<FormState> newGridBackgroundFormKey = new GlobalKey<FormState>();
  TextEditingController imageOrGifController = new TextEditingController();

  Future<void> createGridDialog(BuildContext context) async {
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
                      controller: numberOfColumnsController,
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
                  createNewGrid(numberOfColumnsController.text,
                      numberOfRowsController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> changeGridBackgroundDialog(BuildContext context) async {
    bool image_or_color = true;
    imageOrGifController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Change grid's background",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
                child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text(
                        "Image/GIF",
                        style: TextStyle(
                            color: image_or_color ? Colors.red : Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          image_or_color = !image_or_color;
                          imageOrGifController.clear();
                        });
                      },
                    ),
                    TextButton(
                      child: Text(
                        "Color",
                        style: TextStyle(
                            color: image_or_color ? Colors.black : Colors.red),
                      ),
                      onPressed: () {
                        setState(() {
                          image_or_color = !image_or_color;
                          imageOrGifController.clear();
                        });
                      },
                    )
                  ],
                ),
                Form(
                    key: newGridBackgroundFormKey,
                    child: TextFormField(
                      controller: imageOrGifController,
                      decoration: InputDecoration(
                          labelText: image_or_color ? 'Image/GIF' : 'Color'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Grid row required';
                        }
                        return null;
                      },
                    )),
              ],
            )),
            actions: <Widget>[
              TextButton(
                child: Text('Approve'),
                onPressed: () {
                  // Validate returns true if the form is valid, otherwise false.
                  if (newGridBackgroundFormKey.currentState.validate()) {
                    changeGridBackground(!image_or_color, image_or_color,
                        imageOrGifController.text);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void changeGridBackground(bool isColor, bool isImage, String colorOrImage) {
    Map<String, String> data = {
      "grid_json": grid.grid_json,
      "is_image": isImage ? "1" : "0",
      "is_color": isColor ? "1" : "0",
      "value": colorOrImage
    };

    postGridToServer(
            "http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/change_background",
            data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
          grid.grid_json = val;

          gridView.changeGridJSON(value.grid_json);
          gridView.changeCustomBackground(value.gridCustomBackground);
        });
      });
    });
  }

  void createNewGrid(
    String numberOfColumns,
    String numberOfRows,
  ) {
    Map<String, String> data = {
      "number_of_columns": numberOfColumns,
      "number_of_rows": numberOfRows
    };

    postGridToServer(
            "http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/create_grid",
            data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
          grid.grid_json = val;
          grid.gridColumns = value.gridColumns;
          grid.gridRows = value.gridRows;
          grid.combinedGroups = value.combinedGroups;

          print("cols = ${value.gridColumns}");
          print("rows = ${value.gridRows}");
          print("combinedGroups = ${value.combinedGroups}");
          print("grid_json = ${value.grid_json}");
          print("gridCustomBackground = ${value.gridCustomBackground}");

          gridView.changeCols(value.gridColumns);
          gridView.changeRows(value.gridRows);
          gridView.changeGrid(value.combinedGroups);
          gridView.changeGridJSON(value.grid_json);
          gridView.changeCustomBackground(value.gridCustomBackground);
        });
      });
    });
  }

  ///Post changes made to the UI grid to the server
  Future<String> postGridToServer(String url, Map<String, String> data) async {
    http.Response response = await http.post(url, body: data);
    String grid;

    if (response.statusCode == 200) {
      grid = response.body;
    } else {
      grid = '';
    }

    return grid;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              /* ====
               * Grid
               =====*/
              loadGridView(gridView),

              /* ==============
               * Bottom buttons
               ===============*/
              Visibility(
                visible: areBtnsHidden,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 10, left: 30),
                          child: Text(
                            "Pre-defined layouts:",
                            style: TextStyle(color: Colors.white),
                          )),
                      Container(
                        child: Wrap(
                          spacing: 10,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                "New grid",
                              ),
                              onPressed: () {
                                createGridDialog(context);
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                "from JSON",
                              ),
                              onPressed: () {
                                grid
                                    .loadJSON("assets/json/test_grid.json",
                                        fromNetwork: false, grid: "")
                                    .then((value) {
                                  setState(() {
                                    grid.grid_json = value.grid_json;
                                    print(value.grid_json);

                                    grid.gridColumns = value.gridColumns;
                                    grid.gridRows = value.gridRows;
                                    grid.combinedGroups = value.combinedGroups;

                                    gridView.changeCols(grid.gridColumns);
                                    gridView.changeRows(grid.gridRows);
                                    gridView.changeGrid(grid.combinedGroups);
                                    gridView.changeGridJSON(grid.grid_json);
                                    gridView.changeCustomBackground(
                                        value.gridCustomBackground);
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                "Default",
                              ),
                              onPressed: () {
                                getGridFromServer(
                                        'http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/default')
                                    .then((value1) {
                                  grid
                                      .loadJSON("",
                                          fromNetwork: true, grid: value1)
                                      .then((value) {
                                    setState(() {
                                      grid.grid_json = value1;
                                      grid.gridColumns = value.gridColumns;
                                      grid.gridRows = value.gridRows;
                                      grid.combinedGroups =
                                          value.combinedGroups;

                                      gridView.changeCols(grid.gridColumns);
                                      gridView.changeRows(grid.gridRows);
                                      gridView.changeGrid(grid.combinedGroups);
                                      gridView.changeGridJSON(grid.grid_json);
                                      gridView.changeCustomBackground(
                                          value.gridCustomBackground);
                                    });
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                "Preset 1",
                              ),
                              onPressed: () {
                                getGridFromServer(
                                        'http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/preset1')
                                    .then((value1) {
                                  grid
                                      .loadJSON("",
                                          fromNetwork: true, grid: value1)
                                      .then((value) {
                                    setState(() {
                                      grid.grid_json = value1;
                                      grid.gridColumns = value.gridColumns;
                                      grid.gridRows = value.gridRows;
                                      grid.combinedGroups =
                                          value.combinedGroups;

                                      gridView.changeCols(grid.gridColumns);
                                      gridView.changeRows(grid.gridRows);
                                      gridView.changeGrid(grid.combinedGroups);
                                      gridView.changeGridJSON(grid.grid_json);
                                      gridView.changeCustomBackground(
                                          value.gridCustomBackground);
                                    });
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                "Preset 2",
                              ),
                              onPressed: () {
                                getGridFromServer(
                                        'http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/preset2')
                                    .then((value1) {
                                  grid
                                      .loadJSON("",
                                          fromNetwork: true, grid: value1)
                                      .then((value) {
                                    setState(() {
                                      grid.grid_json = value1;
                                      grid.gridColumns = value.gridColumns;
                                      grid.gridRows = value.gridRows;
                                      grid.combinedGroups =
                                          value.combinedGroups;

                                      gridView.changeCols(grid.gridColumns);
                                      gridView.changeRows(grid.gridRows);
                                      gridView.changeGrid(grid.combinedGroups);
                                      gridView.changeGridJSON(grid.grid_json);
                                      gridView.changeCustomBackground(
                                          value.gridCustomBackground);
                                    });
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                "Preset 3",
                              ),
                              onPressed: () {
                                getGridFromServer(
                                        'http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/preset3')
                                    .then((value1) {
                                  grid
                                      .loadJSON("",
                                          fromNetwork: true, grid: value1)
                                      .then((value) {
                                    setState(() {
                                      grid.grid_json = value1;
                                      grid.gridColumns = value.gridColumns;
                                      grid.gridRows = value.gridRows;
                                      grid.combinedGroups =
                                          value.combinedGroups;

                                      gridView.changeCols(grid.gridColumns);
                                      gridView.changeRows(grid.gridRows);
                                      gridView.changeGrid(grid.combinedGroups);
                                      gridView.changeGridJSON(grid.grid_json);
                                      gridView.changeCustomBackground(
                                          value.gridCustomBackground);
                                    });
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Menu buttons 2
                      Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 10, left: 30),
                          child: Text(
                            "Options:",
                            style: TextStyle(color: Colors.white),
                          )),
                      Container(
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 10,
                          children: [
                            FlatButton(
                              color: Colors.white,
                              child: Text("Customise grid background"),
                              onPressed: () {
                                changeGridBackgroundDialog(context);
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text("Toggle edit mode"),
                              onPressed: () {
                                setState(() {
                                  gridView.state.editMode =
                                      !gridView.state.editMode;
                                  gridView
                                      .changeEditMode(gridView.state.editMode);
                                });
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text("Create combined block"),
                              onPressed: () {
                                gridView.state
                                    .createCombinedBlockialog(context, false);
                              },
                            ),
                            FlatButton(
                              color: Colors.white,
                              child: Text("Delete combined block"),
                              onPressed: () {
                                gridView.state
                                    .deleteCombinedBlockialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FlatButton(
                color: Colors.white,
                child: Text(areBtnsHidden ? "Hide buttons" : "Show butttons"),
                onPressed: () {
                  setState(() {
                    areBtnsHidden = !areBtnsHidden;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

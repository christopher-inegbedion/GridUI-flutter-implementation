import 'package:constraint_view/main.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:http/http.dart' as http;
import 'network_config.dart';

class GridPage extends StatefulWidget {
  String path;
  int numOfCols = 0;
  int numOfRows = 0;
  bool canEdit = false;
  _GridPageState state;

  GridPage(this.path, this.canEdit) {
    state = _GridPageState(path, canEdit);
  }

  GridPage.createNewGridAndSave(this.path, this.numOfCols, this.numOfRows) {
    state = _GridPageState.createNewGridAndSave(
        path, true, numOfCols, numOfRows);
  }

  @override
  _GridPageState createState() => state;
}

class _GridPageState extends State<GridPage> {
  Grid grid;
  GridUIView _gridUIView = GridUIView.empty();
  bool areBtnsHidden = false;
  bool newGridCreated = false;
  String path;
  int initialNumOfCols;
  int initialNumOfRows;
  bool canEdit = false;

  _GridPageState(this.path, this.canEdit);

  _GridPageState.createNewGridAndSave(
      this.path, this.canEdit, this.initialNumOfCols, this.initialNumOfRows) {
    newGridCreated = true;
  }

  @override
  void initState() {
    super.initState();
    grid = Grid.getInstance();
    grid.setGridUI(_gridUIView);

    Future.delayed(Duration.zero, () {
      if (newGridCreated) {
        createAndSaveNewGrid(
            initialNumOfCols.toString(), initialNumOfRows.toString(), path);
        grid.toggleEditMode();
      } else {
        loadGrid(path);
      }
    });
  }

  ///Retrieve a Grid layout from the url specified
  Future<String> getGridFromServer(String addr, String path) async {
    String grid;
    try {
      http.Response response = await http.Client().get(Uri.http(addr, path));

      if (response.statusCode == 200) {
        grid = response.body;
      } else {
        grid = '';
      }
    } catch (e, stacktrace) {
      Scaffold.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("An error occured. Try again."),
      ));
    }

    return grid;
  }

  Widget loadGridView(GridUIView gridView) {
    return grid.combinedGroups == null ? CircularProgressIndicator() : gridView;
  }

  GlobalKey<FormState> newGridFormKey = new GlobalKey<FormState>();
  TextEditingController numberOfColumnsController = new TextEditingController();
  TextEditingController numberOfRowsController = new TextEditingController();

  GlobalKey<FormState> newGridBackgroundFormKey = new GlobalKey<FormState>();
  TextEditingController imageOrGifController = new TextEditingController();

  GlobalKey<FormState> saveGridFormKey = new GlobalKey<FormState>();
  TextEditingController gridNameController = new TextEditingController();

  GlobalKey<FormState> loadGridFromKey = new GlobalKey<FormState>();
  TextEditingController gridLoadNameController = new TextEditingController();

  Future<void> addNewRowDialog() async {
    GlobalKey<FormState> newRowsKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new rows'),
          content: SingleChildScrollView(
              child: Form(
                  key: newRowsKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Number of rows'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Number of rows required';
                        }
                        return null;
                      },
                    ),
                  ]))),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                // Validate returns true if the form is valid, otherwise false.
                if (newRowsKey.currentState.validate()) {
                  addNewRow(int.parse(controller.text));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteRowDialog() async {
    GlobalKey<FormState> rowsKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete rows'),
          content: SingleChildScrollView(
              child: Form(
                  key: rowsKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Number of rows'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Number of rows required';
                        }
                        return null;
                      },
                    ),
                  ]))),
          actions: <Widget>[
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Validate returns true if the form is valid, otherwise false.
                if (rowsKey.currentState.validate()) {
                  deleteRows(int.parse(controller.text));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addNewColDialog() async {
    GlobalKey<FormState> newColsKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add new columns'),
          content: SingleChildScrollView(
              child: Form(
                  key: newColsKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration:
                          InputDecoration(labelText: 'Number of columns'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Number of columns required';
                        }
                        return null;
                      },
                    ),
                  ]))),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                // Validate returns true if the form is valid, otherwise false.
                if (newColsKey.currentState.validate()) {
                  addNewCol(int.parse(controller.text));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteColDialog() async {
    GlobalKey<FormState> colsKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete columns'),
          content: SingleChildScrollView(
              child: Form(
                  key: colsKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration:
                          InputDecoration(labelText: 'Number of columns'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Number of columns required';
                        }
                        return null;
                      },
                    ),
                  ]))),
          actions: <Widget>[
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Validate returns true if the form is valid, otherwise false.
                if (colsKey.currentState.validate()) {
                  deleteCol(int.parse(controller.text));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

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
                Row(
                  children: [
                    Expanded(
                      child: Form(
                          key: newGridBackgroundFormKey,
                          child: TextFormField(
                            controller: imageOrGifController,
                            decoration: InputDecoration(
                                labelText:
                                    image_or_color ? 'Image/GIF' : 'Color'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Input required';
                              }
                              return null;
                            },
                          )),
                    ),
                    Visibility(
                        visible: !image_or_color,
                        child: TextButton(
                            onPressed: () {
                              showColorPickerDialog().then((value) {
                                setState(() {
                                  imageOrGifController.text = "#${value.hex}";
                                });
                              });
                            },
                            child: Text("Pick color")))
                  ],
                ),
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

  Future<Color> showColorPickerDialog() {
    Color selectedColor = Colors.blue; // Material blue.

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                copyPasteBehavior: ColorPickerCopyPasteBehavior(
                    copyFormat: ColorPickerCopyFormat.hexRRGGBB),
                showRecentColors: true,
                showColorCode: true,
                pickersEnabled: {
                  ColorPickerType.wheel: true,
                  ColorPickerType.accent: false,
                  ColorPickerType.primary: false
                },
                // Use the screenPickerColor as start color.
                color: selectedColor,
                // Update the screenPickerColor using the callback.
                onColorChanged: (Color color) =>
                    setState(() => selectedColor = color),
                width: 44,
                height: 44,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it'),
                onPressed: () {
                  // setState(() => currentColor = pickerColor);
                  Navigator.of(context).pop(selectedColor);
                },
              ),
            ],
          );
        });
  }

  Future<void> saveGridDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return AlertDialog(
                title: Text(
                  "Save Grid's config",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: saveGridFormKey,
                        child: TextFormField(
                          controller: gridNameController,
                          decoration: InputDecoration(
                              labelText: "Set a name for the grid"),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Grid name required";
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text("Save"),
                    onPressed: () {
                      if (saveGridFormKey.currentState.validate()) {
                        saveGrid(gridNameController.text, grid.gridJson);
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              );
            },
          );
        });
  }

  Future<void> loadGridDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return AlertDialog(
                title: Text(
                  "Load grid",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                        key: loadGridFromKey,
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
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text("Load"),
                    onPressed: () {
                      if (loadGridFromKey.currentState.validate()) {
                        loadGrid(gridLoadNameController.text);
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              );
            },
          );
        });
  }

  void saveGrid(String gridName, String gridJson) {
    Map<String, String> data = {"grid_name": gridName, "grid": gridJson};

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/save_grid", data)
        .then((val) {
      if (val == "") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('An error occured'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Grid '$gridName' saved"),
        ));
      }
    });
  }

  void loadGrid(String gridName) {
    Map<String, String> data = {"grid_name": gridName};

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/load_grid", data)
        .then((value1) {
      if (value1 == "") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('An error occured'),
        ));
      } else {
        Grid.getInstance()
            .loadJSON("", fromNetwork: true, grid: value1)
            .then((value) {
          setState(() {
            grid.setData(value.gridJson, value.gridColumns, value.gridRows,
                value.combinedGroups, value.gridCustomBackground);

            grid.buildGridView();
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Grid '$gridName' loaded"),
          ));
        });
      }
    });
  }

  void changeGridBackground(bool isColor, bool isImage, String colorOrImage) {
    Map<String, String> data = {
      "grid_json": grid.gridJson,
      "is_image": isImage ? "1" : "0",
      "is_color": isColor ? "1" : "0",
      "value": colorOrImage
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/change_background", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
          grid.gridJson = val;

          grid.buildGridView();
        });
      });
    });
  }

  void createNewGrid(String numberOfColumns, String numberOfRows) {
    Map<String, String> data = {
      "number_of_columns": numberOfColumns,
      "number_of_rows": numberOfRows
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/create_grid", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        grid.buildGridView();
        print(grid.gridJson);
      });
    });
  }

  void addNewRow(int rows) {
    Map<String, String> data = {
      "rows": rows.toString(),
      "grid_json": grid.gridJson
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/add_row", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        grid.buildGridView();
      });
    });
  }

  void deleteRows(int rows) {
    Map<String, String> data = {
      "rows": rows.toString(),
      "grid_json": grid.gridJson
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/delete_row", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        grid.buildGridView();
      });
    });
  }

  void addNewCol(int columns) {
    Map<String, String> data = {
      "columns": columns.toString(),
      "grid_json": grid.gridJson
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/add_column", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        grid.buildGridView();
      });
    });
  }

  void deleteCol(int columns) {
    Map<String, String> data = {
      "columns": columns.toString(),
      "grid_json": grid.gridJson
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/delete_col", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        grid.buildGridView();
      });
    });
  }

  void createAndSaveNewGrid(
      String numberOfColumns, String numberOfRows, String gridName) {
    Map<String, String> data = {
      "number_of_columns": numberOfColumns,
      "number_of_rows": numberOfRows
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/create_grid", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        grid.buildGridView();
        saveGrid(gridName, grid.gridJson);
      });
    });
  }

  ///Post changes made to the UI grid to the server
  Future<String> postGridToServer(
      String addr, String path, Map<String, String> data) async {
    http.Response response =
        await http.Client().post(Uri.http(addr, path), body: data);
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ListView(
          children: [
            /*====
            * Grid
            =====*/
            grid.buildViewLayout(),

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
                          TextButton(
                            child: Text(
                              "Add column",
                            ),
                            onPressed: () {
                              addNewColDialog();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Delete column",
                            ),
                            onPressed: () {
                              deleteColDialog();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Add row",
                            ),
                            onPressed: () {
                              addNewRowDialog();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Delete row",
                            ),
                            onPressed: () {
                              deleteRowDialog();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "New grid",
                            ),
                            onPressed: () {
                              createGridDialog(context);
                            },
                          ),
                          TextButton(
                            child: Text(
                              "from JSON",
                            ),
                            onPressed: () {
                              grid
                                  .loadJSON("assets/json/test_grid.json",
                                      fromNetwork: false, grid: "")
                                  .then((value) {
                                setState(() {
                                  grid.setData(
                                      value.gridJson,
                                      value.gridColumns,
                                      value.gridRows,
                                      value.combinedGroups,
                                      value.gridCustomBackground);

                                  grid.buildGridView();
                                });
                              });
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Default",
                            ),
                            onPressed: () {
                              getGridFromServer(
                                      NetworkConfig.serverAddr +
                                          NetworkConfig.serverPort,
                                      '/default')
                                  .then((value1) {
                                grid
                                    .loadJSON("",
                                        fromNetwork: true, grid: value1)
                                    .then((value) {
                                  setState(() {
                                    grid.setData(
                                        value.gridJson,
                                        value.gridColumns,
                                        value.gridRows,
                                        value.combinedGroups,
                                        value.gridCustomBackground);

                                    grid.buildGridView();
                                  });
                                });
                              });
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Preset 1",
                            ),
                            onPressed: () {
                              getGridFromServer(
                                      NetworkConfig.serverAddr +
                                          NetworkConfig.serverPort,
                                      '/preset1')
                                  .then((value1) {
                                grid
                                    .loadJSON("",
                                        fromNetwork: true, grid: value1)
                                    .then((value) {
                                  setState(() {
                                    grid.setData(
                                        value.gridJson,
                                        value.gridColumns,
                                        value.gridRows,
                                        value.combinedGroups,
                                        value.gridCustomBackground);

                                    grid.buildGridView();
                                  });
                                });
                              });
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Preset 2",
                            ),
                            onPressed: () {
                              getGridFromServer(
                                      NetworkConfig.serverAddr +
                                          NetworkConfig.serverPort,
                                      '/preset2')
                                  .then((value1) {
                                grid
                                    .loadJSON("",
                                        fromNetwork: true, grid: value1)
                                    .then((value) {
                                  setState(() {
                                    grid.setData(
                                        value.gridJson,
                                        value.gridColumns,
                                        value.gridRows,
                                        value.combinedGroups,
                                        value.gridCustomBackground);

                                    grid.buildGridView();
                                  });
                                });
                              });
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Preset 3",
                            ),
                            onPressed: () {
                              getGridFromServer(
                                      NetworkConfig.serverAddr +
                                          NetworkConfig.serverPort,
                                      '/preset3')
                                  .then((value1) {
                                grid
                                    .loadJSON("",
                                        fromNetwork: true, grid: value1)
                                    .then((value) {
                                  setState(() {
                                    grid.setData(
                                        value.gridJson,
                                        value.gridColumns,
                                        value.gridRows,
                                        value.combinedGroups,
                                        value.gridCustomBackground);

                                    grid.buildGridView();
                                  });
                                });
                              });
                            },
                          ),
                          TextButton(
                            child: Text("Load grid"),
                            onPressed: () {
                              loadGridDialog(context);
                            },
                          )
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
                          TextButton(
                            child: Text("Constraint view"),
                            onPressed: () {
                              print(MainApp().userID);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainApp()),
                              );
                            },
                          ),
                          TextButton(
                            child: Text("Customise grid background"),
                            onPressed: () {
                              changeGridBackgroundDialog(context);
                            },
                          ),
                          TextButton(
                            child: Text("Toggle edit mode"),
                            onPressed: () {
                              setState(() {
                                grid.toggleEditMode();
                              });
                            },
                          ),
                          TextButton(
                            child: Text("Create combined block"),
                            onPressed: () {
                              grid.getGridUIView.state
                                  .createCombinedBlockialog(context, false);
                            },
                          ),
                          TextButton(
                            child: Text("Delete combined block"),
                            onPressed: () {
                              grid.getGridUIView.state
                                  .deleteCombinedBlockialog(context);
                            },
                          ),
                          TextButton(
                            child: Text("Save grid"),
                            onPressed: () {
                              saveGrid(path, grid.gridJson);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              child: Text(canEdit
                  ? areBtnsHidden
                      ? "Hide buttons"
                      : "Show butttons"
                  : "Grid cannot be edited"),
              onPressed: () {
                if (canEdit) {
                  setState(() {
                    areBtnsHidden = !areBtnsHidden;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

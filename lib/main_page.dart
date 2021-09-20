import 'dart:io';

import 'package:constraint_view/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'network_config.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
    state =
        _GridPageState.createNewGridAndSave(path, true, numOfCols, numOfRows);
  }

  @override
  _GridPageState createState() => state;
}

class _GridPageState extends State<GridPage> {
  Grid grid;
  bool areBtnsHidden = false;
  bool newGridCreated = false;
  String path;
  int initialNumOfCols;
  int initialNumOfRows;
  bool canEdit = false;
  Color backgroundColor;
  Color devToolsBtnColor = Colors.blue;
  ScreenshotController _screenshotController = ScreenshotController();

  _GridPageState(this.path, this.canEdit);

  _GridPageState.createNewGridAndSave(
      this.path, this.canEdit, this.initialNumOfCols, this.initialNumOfRows) {
    newGridCreated = true;
  }

  @override
  void initState() {
    super.initState();
    grid = Grid.getInstance();
    grid.onViewInitComplete = setBackgroundColor;

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

  Future<void> createGridDialog() async {
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

  Future<void> changeGridBackgroundDialog() async {
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
                Column(
                  children: [
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
                                      imageOrGifController.text =
                                          "#${value.hex}";
                                    });
                                  });
                                },
                                child: Text("Pick color"))),
                      ],
                    ),
                    Visibility(
                      visible: image_or_color,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                GiphyGif gif = await GiphyGet.getGif(
                                  context: context, //Required
                                  apiKey:
                                      "ShudUpzvLP3cWyNuNyfpZjF771JmVfhL", //Required.
                                  lang: GiphyLanguage
                                      .english, //Optional - Language for query.
                                  tabColor: Colors
                                      .teal, // Optional- default accent color.
                                );
                                setState(() {
                                  imageOrGifController.text =
                                      gif.images.fixedHeight.url;
                                });
                              },
                              child: Text("Select a GIF")),
                          TextButton(
                              onPressed: () {
                                selectImageFromServerDialog(
                                    imageOrGifController);
                              },
                              child: Text("Select from upload")),
                        ],
                      ),
                    )
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

  Future<String> selectImageFromServerDialog(TextEditingController controller) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  "Select an image",
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
                ),
                content: FutureBuilder(
                  future: getAllImagesFromServer(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Reference> links = snapshot.data;
                      return Container(
                        height: 400,
                        width: double.maxFinite,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: links.length,
                            itemBuilder: (context, i) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                    onPressed: () {
                                      links[i].getDownloadURL().then((url) {
                                        setState(() {
                                          controller.text = url;
                                        });
                                        Navigator.of(context).pop(url);
                                      });
                                    },
                                    child: Wrap(
                                      alignment: WrapAlignment.start,
                                      direction: Axis.vertical,
                                      children: [
                                        FutureBuilder(
                                          future: links[i].getDownloadURL(),
                                          builder: (context, imageSnapshot) {
                                            if (imageSnapshot.hasData) {
                                              return Image.network(
                                                imageSnapshot.data,
                                                width: 50,
                                              );
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text(links[i].name)),
                                      ],
                                    )),
                              );
                            }),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              );
            },
          );
        });
  }

  Future<List> getAllImagesFromServer() async {
    List<Reference> images = [];
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref().listAll();

    result.items.forEach((element) async {
      // String url = await element.getDownloadURL();
      images.add(element);
    });

    return images;
  }

  Future<void> saveGridDialog() async {
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

  Future<void> loadGridDialog() async {
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text("Saving..."),
    ));
    takeScreenshot().onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("An error occured. Screenshot could not be saved"),
      ));

      _saveGrid(gridName, data);
    }).whenComplete(() {
      _saveGrid(gridName, data);
    });
  }

  void _saveGrid(String gridName, Map<String, String> data) {
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

  Future loadGrid(String gridName) async {
    Map<String, String> data = {"grid_name": gridName};

    String gridJson = await postGridToServer(
        NetworkConfig.serverAddr + NetworkConfig.serverPort,
        "/load_grid",
        data);
    if (gridJson == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('An error occured'),
      ));
    } else {
      Grid grid = await Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: gridJson);
      setState(() {
        grid.setData(grid.gridJson, grid.gridColumns, grid.gridRows,
            grid.combinedGroups, grid.gridCustomBackground);

        grid.buildGridView();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Grid '$gridName' loaded"),
      ));
    }

    return true;
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

  void setBackgroundColor() async {
    if (grid.gridCustomBackground.is_link) {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
              Image.network(grid.gridCustomBackground.link_or_color).image);
      setState(() {
        backgroundColor = generator.dominantColor.color;
        devToolsBtnColor = generator.dominantColor.bodyTextColor;
      });
    } else {
      final PaletteGenerator generator = PaletteGenerator.fromColors(
          [PaletteColor(HexColor(grid.gridCustomBackground.link_or_color), 1)]);
      setState(() {
        backgroundColor = HexColor(grid.gridCustomBackground.link_or_color);
        devToolsBtnColor = generator.dominantColor.bodyTextColor;
      });
    }
  }

  Widget buildDevTooldBtn(String text, Function action) {
    return TextButton(
      child: Text(
        text,
        style: TextStyle(color: devToolsBtnColor),
      ),
      onPressed: () {
        action();
      },
    );
  }

  Future takeScreenshot() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();

    _screenshotController.capture().then((value) async {
      final result = await ImageGallerySaver.saveImage(value, name: "test");

      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      try {
        firebase_storage.SettableMetadata metadata =
            firebase_storage.SettableMetadata(customMetadata: {"name": path});
        storage
            .ref("screenshots/$fileName")
            .putData(value, metadata)
            .then((p0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text("Screenshot captured")));
        });
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("An error occured")));
        throw e;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: RefreshIndicator(
          onRefresh: () {
            return loadGrid(path);
          },
          child: ListView(
            children: [
              /*====
              * Grid
              =====*/
              Screenshot(
                  controller: _screenshotController,
                  child: grid.buildViewLayout()),

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
                            style: GoogleFonts.sora(
                                color: devToolsBtnColor,
                                fontWeight: FontWeight.bold),
                          )),
                      Container(
                        child: Wrap(
                          spacing: 10,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            buildDevTooldBtn("Add column", addNewColDialog),
                            buildDevTooldBtn("Delete column", deleteColDialog),
                            buildDevTooldBtn("Add row", addNewRowDialog),
                            buildDevTooldBtn("Delete row", deleteRowDialog),
                            buildDevTooldBtn("New grid", createGridDialog),
                            buildDevTooldBtn("from JSON", () {
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
                            }),
                            buildDevTooldBtn("Default", () {
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
                            }),
                            buildDevTooldBtn("Preset 1", () {
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
                            }),
                            buildDevTooldBtn("Preset 2", () {
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
                            }),
                            buildDevTooldBtn("Preset 3", () {
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
                            }),
                            buildDevTooldBtn("Load grid", loadGridDialog),
                          ],
                        ),
                      ),

                      // Menu buttons 2
                      Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 10, left: 30),
                          child: Text(
                            "Options:",
                            style: GoogleFonts.sora(
                                color: devToolsBtnColor,
                                fontWeight: FontWeight.bold),
                          )),
                      Container(
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 10,
                          children: [
                            buildDevTooldBtn("Constraint view", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainApp()),
                              );
                            }),
                            buildDevTooldBtn("Upload image asset", () {
                              firebase_storage.FirebaseStorage storage =
                                  firebase_storage.FirebaseStorage.instance;
                              final ImagePicker _picker = ImagePicker();
                              _picker
                                  .pickImage(source: ImageSource.gallery)
                                  .then((XFile value) {
                                String path = value.path;
                                File file = File(path);
                                try {
                                  storage
                                      .ref(value.name)
                                      .putFile(file)
                                      .then((p0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("'$path' uploaded!")));
                                  });
                                } on FirebaseException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("An error occured")));
                                  print(e);
                                }
                              });
                            }),
                            buildDevTooldBtn("Customise grid background", () {
                              changeGridBackgroundDialog().then((value) {
                                setBackgroundColor();
                              });
                            }),
                            buildDevTooldBtn("Toggle edit mode", () {
                              setState(() {
                                grid.toggleEditMode();
                              });
                            }),
                            buildDevTooldBtn("Create combined block", () {
                              grid.gridUIView.state
                                  .createCombinedBlockialog(context, false);
                            }),
                            buildDevTooldBtn("Delete combined block", () {
                              grid.gridUIView.state
                                  .deleteCombinedBlockialog(context);
                            }),
                            buildDevTooldBtn("Save grid", () {
                              saveGrid(path, grid.gridJson);
                            }),
                            buildDevTooldBtn(
                                "Take preview screenshot", takeScreenshot)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                child: Visibility(
                  visible: canEdit,
                  child: Text(
                    canEdit
                        ? areBtnsHidden
                            ? "Hide buttons"
                            : "Show butttons"
                        : "Grid cannot be edited",
                    style: TextStyle(
                        color: devToolsBtnColor, fontWeight: FontWeight.bold),
                  ),
                ),
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
      ),
    );
  }
}

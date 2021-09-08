import 'dart:convert';
import 'dart:math';

import 'package:constraint_view/custom_views/task_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/block_content/color_combined_block_content.dart';
import 'package:grid_ui_implementation/models/block_content/image_combined_block_content.dart';
import 'package:grid_ui_implementation/models/block_content/task_combined_block_content.dart';
import 'package:grid_ui_implementation/models/comb_block_drag_info.dart';
import 'package:grid_ui_implementation/models/combined_block_content.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:grid_ui_implementation/models/block_content/text_combined_block_content.dart';
import 'package:grid_ui_implementation/models/grid_custom_background.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:grid_ui_implementation/network_config.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:string_validator/string_validator.dart';

class GridUIView extends StatefulWidget {
  int rows;
  int columns;
  List<CombinedGroup> data;
  String gridJson;
  CustomGridBackground gridBackgroundData;
  _GridUIViewState state;

  GridUIView(this.gridJson, this.columns, this.rows, this.gridBackgroundData,
      this.data);

  GridUIView.empty() {
    this.gridJson = null;
    this.columns = 0;
    this.rows = 0;
    this.gridBackgroundData = null;
    this.data = null;
  }

  @override
  _GridUIViewState createState() {
    state = _GridUIViewState(columns, rows, data,
        gridJson: gridJson, gridCustomBackgroudData: gridBackgroundData);

    return state;
  }

  void changeCols(int cols) {
    state.changeCols(cols);
  }

  void changeRows(int rows) {
    state.changeRows(rows);
  }

  void changeGrid(List<CombinedGroup> data) {
    state.data = data;
  }

  void changeEditMode(bool val) {
    state.changeEditState(val);
  }

  void changeGridJSON(String value) {
    state.gridJson = value;
  }

  void changeCustomBackground(CustomGridBackground customGridBackground) {
    state.changeGridBackround(customGridBackground);
  }

  final _editCombinedBlockKey = GlobalKey<FormState>();
  final combinedBlockContentController = TextEditingController();
}

class _GridUIViewState extends State<GridUIView> {
  int columns;
  int rows;
  List<CombinedGroup> data;
  CustomGridBackground gridCustomBackgroudData;
  String gridJson;
  double blockSize;
  bool editMode = false;
  GlobalKey<FormState> _createCombinedBlockKey = GlobalKey<FormState>();
  GlobalKey<FormState> _enterTextGlobalKey = GlobalKey<FormState>();
  final enterBlockTextController = TextEditingController();
  final enterBlockFontSizeController = TextEditingController();
  final enterBlockTextColorController = TextEditingController();

  final _enterURLGlobalKey = GlobalKey<FormState>();
  final enterBlockURLController = TextEditingController();

  final _enterColorGlobalKey = GlobalKey<FormState>();
  final enterBlockColorController = TextEditingController();

  final _enterTaskIDGlobalKey = GlobalKey<FormState>();
  final _enterTaskIDController = TextEditingController();
  final _enterTaskImageController = TextEditingController();

  int selectedBlockContentType = -1;

  final blockHeightController = TextEditingController();
  final blockWidthController = TextEditingController();
  final blockStartColumnController = TextEditingController();
  final blockStartRowController = TextEditingController();
  _GridUIViewState(this.columns, this.rows, this.data,
      {String gridJson, CustomGridBackground gridCustomBackgroudData}) {
    this.gridJson = gridJson;
    this.gridCustomBackgroudData = gridCustomBackgroudData;
    _createCombinedBlockKey = GlobalKey<FormState>();
    _enterTextGlobalKey = GlobalKey<FormState>();
  }

  ///Combined block creation dialog
  Future<void> createCombinedBlockialog(
      BuildContext context, bool fromDragging) async {
    String contentType = "";
    String content = "";

    //Text content preview settings
    Alignment textPreviewAlignment = Alignment.center;
    String textPreview = "None";
    double textSizePreview = 13;
    String textColorPreview = "#000000";
    String blockColorPreview = "#ffffff";

    List<String> allFonts = GoogleFonts.asMap().keys.toList();
    String selectedFont = allFonts[Random().nextInt(allFonts.length)];

    int _yPositionData = 1;
    int _xPositionData = 1;

    Map<String, dynamic> textContent = {
      "font_family": "",
      "position": 5,
      "font": selectedFont,
      "x_pos": _xPositionData,
      "y_pos": _yPositionData
    };
    Map<String, dynamic> taskContent = {"image": 5};
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create a combined block'),
              content: SingleChildScrollView(
                  child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 40),
                    child: Opacity(
                      opacity: fromDragging ? 0.5 : 1,
                      child: IgnorePointer(
                        ignoring: fromDragging,
                        child: Form(
                            key: _createCombinedBlockKey,
                            child: Column(children: <Widget>[
                              TextFormField(
                                controller: blockHeightController,
                                decoration: InputDecoration(
                                    labelText: 'Combined block height'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Height required';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: blockWidthController,
                                decoration: InputDecoration(
                                    labelText: 'Combined block width'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Width required';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: blockStartColumnController,
                                decoration: InputDecoration(
                                    labelText: 'Grid start column'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Column required';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: blockStartRowController,
                                decoration: InputDecoration(
                                    labelText: 'Grid start row'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Row required';
                                  }
                                  return null;
                                },
                              ),
                            ])),
                      ),
                    ),
                  ),

                  // Select content type
                  Visibility(
                    child: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select content type",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        //Content type options
                        Container(
                          alignment: Alignment.center,
                          child: Wrap(
                            alignment: WrapAlignment.spaceAround,
                            children: [
                              TextButton(
                                child: Text("Text"),
                                onPressed: () {
                                  setState(() {
                                    selectedBlockContentType = 1;
                                  });
                                },
                              ),
                              TextButton(
                                child: Text("Image/GIF"),
                                onPressed: () {
                                  setState(() {
                                    selectedBlockContentType = 2;
                                  });
                                },
                              ),
                              TextButton(
                                child: Text("Color"),
                                onPressed: () {
                                  setState(() {
                                    selectedBlockContentType = 3;
                                  });
                                },
                              ),
                              TextButton(
                                child: Text("Task"),
                                onPressed: () {
                                  setState(() {
                                    selectedBlockContentType = 4;
                                  });
                                },
                              )
                            ],
                          ),
                        ),

                        //Text
                        Visibility(
                          visible: selectedBlockContentType == 1,
                          child: Column(
                            children: [
                              //Text preview
                              Container(
                                  decoration: BoxDecoration(
                                      color: HexColor(blockColorPreview),
                                      border: Border.all(width: 1)),
                                  height: 100,
                                  child: Align(
                                      alignment: textPreviewAlignment,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: _yPositionData >= 0
                                                ? _yPositionData
                                                    .toDouble()
                                                    .abs()
                                                : 0,
                                            top: _yPositionData < 0
                                                ? (_yPositionData.toDouble())
                                                    .abs()
                                                : 0,
                                            left: _xPositionData >= 0
                                                ? _xPositionData
                                                    .toDouble()
                                                    .abs()
                                                : 0,
                                            right: _xPositionData < 0
                                                ? (_xPositionData.toDouble())
                                                    .abs()
                                                : 0),
                                        child: Text(textPreview,
                                            style: GoogleFonts.getFont(
                                                selectedFont,
                                                color:
                                                    HexColor(textColorPreview),
                                                fontSize: textSizePreview)),
                                      ))),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text(
                                  "Text preview",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),

                              //Text options
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Form(
                                    key: _enterTextGlobalKey,
                                    child: Column(
                                      children: [
                                        //Block text
                                        TextFormField(
                                          onChanged: (text) {
                                            setState(() {
                                              if (text == "") {
                                                textPreview = "None";
                                              } else {
                                                textPreview = text;
                                              }
                                            });
                                          },
                                          controller: enterBlockTextController,
                                          decoration: InputDecoration(
                                              labelText: 'Text'),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Text required';
                                            }
                                            contentType = "text";
                                            textContent["value"] = value;
                                            return null;
                                          },
                                        ),

                                        //Text font
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 30, bottom: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  "Text font",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DropdownButton(
                                                  value: selectedFont,
                                                  onChanged: (String newFont) {
                                                    contentType = "text";
                                                    textContent["font"] =
                                                        newFont;
                                                    setState(() {
                                                      selectedFont = newFont;
                                                    });
                                                  },
                                                  items: allFonts.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        //Block text font size
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                onChanged: (size) {
                                                  setState(() {
                                                    if (size == "") {
                                                      textSizePreview = 13;
                                                    } else {
                                                      textSizePreview =
                                                          double.tryParse(size);
                                                    }
                                                  });
                                                },
                                                controller:
                                                    enterBlockFontSizeController,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        'Combined block font size'),
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Font size required';
                                                  }
                                                  contentType = "text";
                                                  textContent["font_size"] =
                                                      value;
                                                  return null;
                                                },
                                              ),
                                            ),
                                            IconButton(
                                                iconSize: 13,
                                                onPressed: (() {
                                                  if (isNumeric(
                                                      enterBlockFontSizeController
                                                          .text)) {
                                                    setState(() {
                                                      textSizePreview =
                                                          double.parse(
                                                                  enterBlockFontSizeController
                                                                      .text) +
                                                              1;
                                                      enterBlockFontSizeController
                                                              .text =
                                                          (textSizePreview
                                                                  .toInt())
                                                              .toString();
                                                    });
                                                  }
                                                }),
                                                icon: Icon(Icons.add)),
                                            IconButton(
                                                iconSize: 13,
                                                onPressed: (() {
                                                  if (isNumeric(
                                                      enterBlockFontSizeController
                                                          .text)) {
                                                    setState(() {
                                                      textSizePreview =
                                                          double.parse(
                                                                  enterBlockFontSizeController
                                                                      .text) -
                                                              1;
                                                      enterBlockFontSizeController
                                                              .text =
                                                          (textSizePreview
                                                                  .toInt())
                                                              .toString();
                                                    });
                                                  }
                                                }),
                                                icon: Icon(Icons.remove)),
                                          ],
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _yPositionData += 1;
                                                    });
                                                    contentType = "text";
                                                    textContent["y_pos"] =
                                                        _yPositionData;
                                                  },
                                                  iconSize: 13,
                                                  icon: Icon(Icons.add)),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _yPositionData -= 1;
                                                    });
                                                    contentType = "text";
                                                    textContent["y_pos"] =
                                                        _yPositionData;
                                                  },
                                                  iconSize: 13,
                                                  icon: Icon(Icons.remove)),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: Text(_yPositionData
                                                      .toString())),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Y position",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _xPositionData += 1;
                                                    });
                                                    contentType = "text";
                                                    textContent["x_pos"] =
                                                        _xPositionData;
                                                  },
                                                  iconSize: 13,
                                                  icon: Icon(Icons.add)),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _xPositionData -= 1;
                                                    });
                                                    contentType = "text";
                                                    textContent["x_pos"] =
                                                        _xPositionData;
                                                  },
                                                  iconSize: 13,
                                                  icon: Icon(Icons.remove)),
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: Text(_xPositionData
                                                      .toString())),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "X position",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        //Block text color
                                        TextFormField(
                                          onChanged: (color) {
                                            setState(() {
                                              if (color == "") {
                                                textColorPreview = "#000000";
                                              } else {
                                                if (isHexColor(color)) {
                                                  textColorPreview = color;
                                                } else {
                                                  textColorPreview = "#000000";
                                                }
                                              }
                                            });
                                          },
                                          controller:
                                              enterBlockTextColorController,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Combined block text color'),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Text color required';
                                            }
                                            contentType = "text";
                                            textContent["color"] = value;
                                            return null;
                                          },
                                        ),

                                        //Combined block color
                                        TextFormField(
                                          onChanged: (color) {
                                            if (isHexColor(color)) {
                                              setState(() {
                                                blockColorPreview = color;
                                              });
                                            }
                                          },
                                          controller: enterBlockColorController,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Combined block color'),
                                          validator: (value) {
                                            contentType = "text";
                                            textContent["block_color"] =
                                                value.isEmpty ? "" : value;
                                            return null;
                                          },
                                        ),

                                        //Block image link
                                        TextFormField(
                                          controller: enterBlockURLController,
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Combined block image link'),
                                          validator: (value) {
                                            contentType = "text";
                                            textContent["block_image"] =
                                                value.isEmpty ? "" : value;
                                            return null;
                                          },
                                        ),

                                        //Text position
                                        Container(
                                            margin: EdgeInsets.only(top: 20),
                                            alignment: Alignment.centerLeft,
                                            child: Text("Text position",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Wrap(
                                          children: [
                                            TextButton(
                                              child: Text("Top left"),
                                              onPressed: () {
                                                textContent["position"] = 1;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.topLeft;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Top center"),
                                              onPressed: () {
                                                textContent["position"] = 2;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.topCenter;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Top right"),
                                              onPressed: () {
                                                textContent["position"] = 3;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.topRight;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Center left"),
                                              onPressed: () {
                                                textContent["position"] = 4;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.centerLeft;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Center"),
                                              onPressed: () {
                                                textContent["position"] = 5;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.center;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Center right"),
                                              onPressed: () {
                                                textContent["position"] = 6;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.centerRight;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Bottom left"),
                                              onPressed: () {
                                                textContent["position"] = 7;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.bottomLeft;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Bottom center"),
                                              onPressed: () {
                                                textContent["position"] = 8;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.bottomCenter;
                                                });
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Bottom right"),
                                              onPressed: () {
                                                textContent["position"] = 9;
                                                setState(() {
                                                  textPreviewAlignment =
                                                      Alignment.bottomRight;
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),

                        //Image/GIF
                        Visibility(
                          visible: selectedBlockContentType == 2,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Form(
                              key: _enterURLGlobalKey,
                              child: TextFormField(
                                controller: enterBlockURLController,
                                decoration: InputDecoration(
                                    labelText: 'Combined block image/gif url'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'URL required';
                                  }
                                  contentType = "image";
                                  content = value;
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),

                        //Color
                        Visibility(
                          visible: selectedBlockContentType == 3,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Form(
                              key: _enterColorGlobalKey,
                              child: TextFormField(
                                controller: enterBlockColorController,
                                decoration: InputDecoration(
                                    labelText: 'Combined block color'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Hex color required';
                                  }
                                  contentType = "color";
                                  content = value;
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),

                        //Task
                        Visibility(
                            visible: selectedBlockContentType == 4,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Form(
                                key: _enterTaskIDGlobalKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _enterTaskIDController,
                                      decoration:
                                          InputDecoration(labelText: "Task ID"),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Task ID required";
                                        }
                                        contentType = "task";
                                        taskContent["id"] = value;
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: _enterTaskImageController,
                                      decoration: InputDecoration(
                                          labelText: "Image link"),
                                      validator: (value) {
                                        contentType = "task";
                                        taskContent["image"] = value;
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ))
                      ],
                    )),
                  )
                ],
              )),
              actions: <Widget>[
                TextButton(
                  child: Text('Approve'),
                  onPressed: () {
                    bool complete = false;
                    // Validate returns true if the form is valid, otherwise false.
                    if (_createCombinedBlockKey.currentState.validate()) {
                      if (selectedBlockContentType == 1 &&
                          _enterTextGlobalKey.currentState.validate()) {
                        complete = true;
                      } else if (selectedBlockContentType == 2 &&
                          _enterURLGlobalKey.currentState.validate()) {
                        complete = true;
                      } else if (selectedBlockContentType == 3 &&
                          _enterColorGlobalKey.currentState.validate()) {
                        complete = true;
                      } else if (selectedBlockContentType == 4 &&
                          _enterTaskIDGlobalKey.currentState.validate()) {
                        complete = true;
                      } else {
                        complete = false;
                      }
                    }

                    if (complete) {
                      if (contentType == "text") {
                        addCombinedBlock(
                            gridJson,
                            blockHeightController.text,
                            blockWidthController.text,
                            blockStartColumnController.text,
                            blockStartRowController.text,
                            contentType,
                            textContent);
                      } else if (contentType == "task") {
                        addCombinedBlock(
                            gridJson,
                            blockHeightController.text,
                            blockWidthController.text,
                            blockStartColumnController.text,
                            blockStartRowController.text,
                            contentType,
                            taskContent);
                      } else {
                        addCombinedBlock(
                            gridJson,
                            blockHeightController.text,
                            blockWidthController.text,
                            blockStartColumnController.text,
                            blockStartRowController.text,
                            contentType,
                            content);
                      }

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  ///Combined block removal dialog
  Future<void> deleteCombinedBlockialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete a combined block'),
          content: SingleChildScrollView(
              child: Form(
                  key: _createCombinedBlockKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: blockHeightController,
                      decoration:
                          InputDecoration(labelText: 'Combined block height'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Height required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: blockWidthController,
                      decoration:
                          InputDecoration(labelText: 'Combined block width'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Width required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: blockStartColumnController,
                      decoration:
                          InputDecoration(labelText: 'Grid start column'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Column required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: blockStartRowController,
                      decoration: InputDecoration(labelText: 'Grid start row'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Row required';
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
                if (_createCombinedBlockKey.currentState.validate()) {
                  deleteCombinedBlock(
                      gridJson,
                      blockHeightController.text,
                      blockWidthController.text,
                      blockStartColumnController.text,
                      blockStartRowController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool getEditState() {
    return editMode;
  }

  void changeEditState(bool state) {
    setState(() {
      editMode = state;
    });
  }

  void changeGridBackround(CustomGridBackground background) {
    setState(() {
      this.gridCustomBackgroudData = background;
    });
  }

  void changeState() {
    setState(() {});
  }

  ///Returns the actual size of a block
  double getBlockSize(int rows) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / rows;
  }

  ///Post changes made to the UI grid to the server
  Future<String> postGridToServer(
      String addr, String path, Map<String, String> data) async {
    String grid;
    print("grid");
    try {
      http.Response response =
          await http.post(Uri.http(addr, path), body: data);

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

  ///Move a combined block to a specific position
  ///
  ///The combined block's details are passed in the [startColumn], [startRow], [height], [row] and the target locations are [targetColumn] and [targetRow]
  ///
  ///[blockQuadrant], [blockQuadrantCol] and [blockQuadrantRow] specify what part of the combined block is being dragged. Example: A 2x2 combined block,
  ///being dragged from the bottom left corner will have a [blockQuadrant] value of 2, [blockQuadrantCol] value of 1 and [blockQuadrantRow] value of 0.
  ///
  ///**blockQuadrant**
  ///
  /// Identifying the [blockQuadrant] for a 2x2 combined block. Each part is denoted with its [blockQuadrant] value. The values move from
  /// the top left to the bottom right.
  /// ```
  /// | 0 | 1 |
  /// | 2 | 3 |
  /// ```
  ///
  /// **blockQuadrantCol**
  ///
  /// Identifying the [blockQuadrantCol] for a 4x2 combined block. Each part is denoted with its [blockQuadrantCol] value. The values move from
  /// the left to right.
  /// ```
  /// | 0 | 1 | 2 | 3 |
  /// | 0 | 1 | 2 | 3 |
  /// ```
  ///
  /// **blockQuadrantRow**
  ///
  /// Identifying the [blockQuadrantRow] for a 2x4 combined block. Each part is denoted with its [blockQuadrantRow] value. The values move from
  /// the top to bottom.
  /// ```
  /// | 0 | 0 |
  /// | 1 | 1 |
  /// | 2 | 2 |
  /// | 3 | 3 |
  /// ```
  void moveCombinedBlock(
      String gridJSON,
      int startColumn,
      int startRow,
      int height,
      int width,
      int targetColumn,
      int targetRow,
      int blockQuadrant,
      int blockQuadrantCol,
      int blockQuadrantRow) {
    Map<String, String> data = {
      'grid_json': gridJSON,
      'start_column': startColumn.toString(),
      'start_row': startRow.toString(),
      'height': height.toString(),
      'width': width.toString(),
      'target_column': (targetColumn - blockQuadrantCol).toString(),
      'target_row': (targetRow - blockQuadrantRow).toString()
    };

    postGridToServer(
            NetworkConfig.serverAddr + NetworkConfig.serverPort, "/move", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        Grid.getInstance().buildGridView();
      });
    });
  }

  ///Create a combined block
  void addCombinedBlock(
      String gridJSON,
      String height,
      String width,
      String startColumn,
      String startRow,
      String contentType,
      dynamic content) {
    Map<String, String> data;
    if (contentType == "text") {
      data = {
        'grid_json': gridJSON,
        'height': height,
        'width': width,
        'start_row': width,
        'target_column': startColumn,
        'target_row': startRow.toString(),
        'content_type': contentType,
        'content': jsonEncode(content)
      };
    } else {
      data = {
        'grid_json': gridJSON,
        'height': height,
        'width': width,
        'start_row': width,
        'target_column': startColumn,
        'target_row': startRow.toString(),
        'content_type': contentType,
        'content': jsonEncode(content)
      };
    }

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/create", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        gridJson = value.gridJson;
        columns = value.gridColumns;
        rows = value.gridRows;
        changeData(value.combinedGroups);
      });
    });
  }

  ///Delete a combined block
  void deleteCombinedBlock(String gridJSON, String height, String width,
      String startColumn, String startRow) {
    Map<String, String> data = {
      'grid_json': gridJSON,
      'height': height,
      'width': width,
      'start_row': width,
      'target_column': startColumn,
      'target_row': startRow.toString()
    };

    postGridToServer(NetworkConfig.serverAddr + NetworkConfig.serverPort,
            "/delete", data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        gridJson = value.gridJson;
        columns = value.gridColumns;
        rows = value.gridRows;
        changeData(value.combinedGroups);
      });
    });
  }

  ///Change the amount of columns
  void changeCols(int colsChange) {
    setState(() {
      columns = colsChange;
    });
  }

  ///Change the amount of rows
  void changeRows(int rowsChange) {
    setState(() {
      rows = rowsChange;
    });
  }

  ///Change the grid's data
  void changeData(List data) {
    setState(() {
      this.data = data;
    });
  }

  ///Create a single block.
  ///
  ///Create a singular empty block in a grid. These blocks do not have any content but instead serve as visual guides for where content can be
  ///added and also as a drop target when moving combined blocks to another location.
  ///
  ///The [combinedGroupSection] is either 1 or 3, because empty blocks are only created for the sections above/below the main combined group section.
  Widget createSingleEmptyBlock(int targetColumn, int targetRow) {
    Color color;
    if (controller.value.isSelecting &&
        targetColumn >= startGridColumn &&
        targetColumn <= endColumnCurrentlyOn &&
        targetRow >= startGridRow &&
        targetRow <= endRowCurrentlyOn) {
      color = Colors.blueGrey;
    } else {
      color = Colors.black;
    }
    return DragTarget(
      builder: (context, List<CombBlockDragInformation> candidateData,
          rejectedData) {
        return DottedBorder(
          // This is what produces the dot effect when in edit mode
          dashPattern: [1, blockSize - 1],
          strokeCap: StrokeCap.square,
          color: Colors.grey[700],
          child: Container(
              width: blockSize,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: color)),
        );
      },
      onWillAccept: (CombBlockDragInformation data) {
        return true;
      },
      onAccept: (data) {
        CombBlockDragInformation dragInformation = data;
        moveCombinedBlock(
            gridJson,
            dragInformation.combinedBlockStartColumn,
            dragInformation.combinedBlockStartRow,
            dragInformation.combinedBlockHeight,
            dragInformation.combinedBlockWidth,
            targetColumn,
            targetRow,
            dragInformation.blockQuadrantDraggingFrom,
            dragInformation.blockQuadrantColumn,
            dragInformation.blockQuadrantRow);
      },
    );
  }

  ///Create a combined block
  ///
  ///Creates a combined block in a combined group on a grid. The [combinedGroupIndexInCombinedGroupList] is the index of the combined group in the CombinedGroup list, and the
  ///[combinedBlockIndexInCombinedGroup] is the section of the combined group the combined block resides is. The first combined block in a combined group will have
  ///a [combinedBlockIndexInCombinedGroup] value of 1, the second will have a value of 2 and so on.
  Widget createCombinedBlock(Block block, int startCol, int startRow,
      {double height = 0.0, double width}) {
    double numberOfColumns = height / blockSize;
    double numberOfRows = width / blockSize;
    int blockQuadrant =
        0; //stores the block quadrant value when the user begins dragging the combined block
    CombBlockDragInformation dragInformation = CombBlockDragInformation();
    Widget combinedBlock = Stack(
      children: [
        createCombinedBlockContent(
            block.content, numberOfColumns.toInt(), numberOfRows.toInt()),

        ///Block quadrants
        ListView.builder(
            itemCount: numberOfColumns.toInt(),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, colIndex) {
              return Container(
                  height: blockSize,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: numberOfRows.toInt(),
                      itemBuilder: (context, rowIndex) {
                        return GestureDetector(
                          onTapDown: (details) {
                            int combinedBlockWidth = numberOfRows.toInt();
                            int combinedBlockHeight = numberOfColumns.toInt();

                            if (numberOfRows > 1) {
                              blockQuadrant = colIndex + rowIndex + 1;
                            } else {
                              blockQuadrant = colIndex + 1;
                            }

                            dragInformation.block = block;
                            dragInformation.blockQuadrantDraggingFrom =
                                blockQuadrant;
                            dragInformation.blockQuadrantColumn = colIndex;
                            dragInformation.blockQuadrantRow = rowIndex;
                            dragInformation.combinedBlockHeight =
                                combinedBlockHeight;
                            dragInformation.combinedBlockWidth =
                                combinedBlockWidth;
                            dragInformation.combinedBlockStartColumn = startCol;
                            dragInformation.combinedBlockStartRow = startRow;
                          },
                          child: Container(
                            width: blockSize,
                            height: blockSize,
                            decoration: BoxDecoration(color: null),
                          ),
                        );
                      }));
            }),

        GestureDetector(
          onTap: () {
            processCombinedBlockTap(block.content);
          },
        )
      ],
    );

    return LongPressDraggable(
      data: dragInformation,
      child: GestureDetector(
        onDoubleTap: () {
          int height = numberOfColumns.toInt();
          int width = numberOfRows.toInt();

          if (editMode) {
            deleteCombinedBlock(gridJson, height.toString(), width.toString(),
                startCol.toString(), startRow.toString());
          }
        },
        child: Container(
            width: width,
            decoration: BoxDecoration(
                border: editMode
                    ? Border.all(color: Colors.white, width: 2)
                    : null),
            child: combinedBlock),
      ),
      feedback: Material(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2)),
          child: Center(
              child: Text(
            "Editing",
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
        ),
      ),
      childWhenDragging: Container(
        width: width,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.white, width: 2)),
        child: Center(
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  ///Create the content in the combined block.
  Widget createCombinedBlockContent(
      BlockContent blockContent, int cols, int rows) {
    if (blockContent.content_type == "text") {
      TextContent content = blockContent.content;
      String text = content.value;
      String blockColor = content.blockColor == "transperent"
          ? "transperent"
          : content.blockColor.replaceAll("#", "0xff");
      String color = content.color.replaceAll('#', '0xff');
      int position = content.position;
      double xPos = (content.x_pos.toDouble());
      double yPos = (content.y_pos.toDouble());
      String font = content.font;
      double fontSize = content.fontSize;
      Alignment textPosition = getTextAlignemtPosition(position);

      return Container(
        child: Stack(
          children: [
            Container(
              color: blockColor == "transperent" || blockColor == ""
                  ? Colors.transparent
                  : Color(int.parse(blockColor)),
            ),
            content.blockImage == null || content.blockImage == ""
                ? Container()
                : Container(
                    width: double.maxFinite,
                    child: Image(
                      fit: BoxFit.fitWidth,
                      image: NetworkImage(content.blockImage),
                    ),
                  ),
            Align(
              alignment: textPosition,
              child: Container(
                margin: EdgeInsets.only(
                    bottom: yPos >= 0 ? yPos : 0,
                    top: yPos < 0 ? yPos.abs() : 0,
                    left: xPos >= 0 ? xPos : 0,
                    right: xPos < 0 ? xPos.abs() : 0),
                child: Text(text,
                    style: GoogleFonts.getFont(font,
                        color: Color(int.parse(color)), fontSize: fontSize)),
              ),
            )
          ],
        ),
      );
    } else if (blockContent.content_type == "color") {
      ColorContent content = blockContent.content;
      String color = content.colorVal.replaceAll("#", "").replaceAll('"', "");
      if (isHexColor(color)) {
        return Container(
          color: color == "transperent" ? Colors.transparent : HexColor(color),
        );
      } else {
        return Container(
          color: Colors.transparent,
          child: Center(
            child: Text("Color error", style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } else if (blockContent.content_type == "image") {
      ImageContent content = blockContent.content;
      String link = content.link.replaceAll('"', "");

      return Image(
        image: NetworkImage(link),
      );
    } else if (blockContent.content_type == "task") {
      double blockWidth = rows * blockSize;
      double blockHeight = blockWidth / 1.778;
      TaskContent content = blockContent.content;
      String id = content.id;
      String image = content.image;
      print(image);

      return FutureBuilder(
        future: getCombinedBlockTaskDetails(id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map data = snapshot.data;
            if (data != null) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Image(
                        image: NetworkImage(image),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 5, bottom: 5, left: 10, right: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(data["name"],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(data["desc"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          data["currency"] == "USD"
                              ? "\$" + data["price"]
                              : data["currency"] == "GBP"
                                  ? "£" + data["price"]
                                  : data["currency"] == "EUR"
                                      ? "€" + data["price"]
                                      : "not implemented" + data["price"],
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              );
            } else {
              return Center(
                child: Text("Data not found"),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text("An error occured"),
            );
          } else {
            return Center(
              child:
                  Text("No task data", style: TextStyle(color: Colors.white)),
            );
          }
        },
      );
    } else {
      return Text("nothing");
    }
  }

  void processCombinedBlockTap(BlockContent blockContent) {
    if (blockContent.content_type == "task") {
      TaskContent content = blockContent.content;
      String id = content.id;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskView(id, "test")),
      );
    }
  }

  Future getCombinedBlockTaskDetails(String taskID) async {
    try {
      print("sdfs");
      http.Response response = await http.Client()
          .get(Uri.http(NetworkConfig.serverAddr + "8000", "/task/$taskID"));

      if (response.statusCode == 200) {
        Map taskData = jsonDecode(response.body);
        if (taskData["msg"] == "not_found") {
          return null;
        } else {
          return taskData;
        }
      } else {
        return null;
      }
    } catch (e, stacktrace) {}
  }

  ///Return the alignment for the block content text type position property
  Alignment getTextAlignemtPosition(int position) {
    Alignment textPosition;

    if (position == 1) {
      textPosition = Alignment.topLeft;
    } else if (position == 2) {
      textPosition = Alignment.topCenter;
    } else if (position == 3) {
      textPosition = Alignment.topRight;
    } else if (position == 4) {
      textPosition = Alignment.centerLeft;
    } else if (position == 5) {
      textPosition = Alignment.center;
    } else if (position == 6) {
      textPosition = Alignment.centerRight;
    } else if (position == 7) {
      textPosition = Alignment.bottomLeft;
    } else if (position == 8) {
      textPosition = Alignment.bottomCenter;
    } else if (position == 9) {
      textPosition = Alignment.bottomRight;
    }

    return textPosition;
  }

  int endColumnCurrentlyOn = 0;
  int endRowCurrentlyOn = 0;
  int startGridRow = 0;
  int startGridColumn = 0;
  bool startDrag = false;
  final controller = DragSelectGridViewController();

  ///Creates empty blocks above/below combined group
  ///
  ///Creates a group of empty blocks in the grid. The [combinedGroupIndexInCombinedGroupList] argument defines the index of the empty block's combined group in the combined
  ///group list.
  Widget createEmptyBlocks() {
    return Listener(
      onPointerUp: (d) {
        if (controller.value.isSelecting && editMode) {
          int newCombinedBlockHeight =
              (endColumnCurrentlyOn - startGridColumn) + 1;
          int newCombinedBlockWidth = (endRowCurrentlyOn - startGridRow) + 1;

          blockHeightController.text = newCombinedBlockHeight.toString();
          blockWidthController.text = newCombinedBlockWidth.toString();
          blockStartColumnController.text = startGridColumn.toString();
          blockStartRowController.text = startGridRow.toString();
          createCombinedBlockialog(context, true);

          controller.clear();
        }
      },
      onPointerDown: (d) {
        controller.addListener(() {
          if (editMode) {
            Set<int> selectedIndices = controller.value.selectedIndexes;
            if (!startDrag) {
              startDrag = true;
              startGridColumn =
                  (selectedIndices.elementAt(0) / this.rows).floor();
              startGridRow = selectedIndices.elementAt(0) % this.rows;
            }
          }
        });
      },
      child: Visibility(
        visible: editMode,
        child: Container(
          color: Colors.black,
          child: this.rows == 0 || this.rows == 0
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.amber,
                )
              : DragSelectGridView(
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: false,
                  gridController: controller,
                  itemCount: this.rows * this.columns,
                  itemBuilder: (context, index, selected) {
                    int colIndex = (index / this.rows).floor();
                    int rowIndex = index % this.rows;

                    return createSingleEmptyBlock(colIndex, rowIndex);
                  },
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: (this.rows * blockSize) / this.rows,
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> initGrids(List data, double blockSize) {
    List<Widget> widgets = [];

    if (data != null) {
      if (data.length > 0) {
        int numberOfCombinedGroups = data.length;

        for (int combGroupIndex = 0;
            combGroupIndex < numberOfCombinedGroups;
            combGroupIndex++) {
          CombinedGroup combinedGroup = data[combGroupIndex];
          int totalColumnsAbove = combinedGroup.columnsAbove;

          for (int i = 0; i < combinedGroup.combinedBlocks.length; i++) {
            CombinedBlockInGroup combinedBlockInGroup =
                combinedGroup.combinedBlocks[i];
            Block block = combinedBlockInGroup.block;
            int emptyColsAbove = combinedBlockInGroup.numberOfColumnsAbove;
            int emptyRowsBefore = combinedBlockInGroup.numberOfRowsLeft;
            double blockHeight = block.numberOfColumns * blockSize;
            double blockWidth = block.numberOfRows * blockSize;

            widgets.add(Positioned(
                top: (emptyColsAbove + totalColumnsAbove) * blockSize,
                left: emptyRowsBefore * blockSize,
                child: Container(
                  height: blockHeight,
                  width: blockWidth,
                  child: createCombinedBlock(block,
                      (emptyColsAbove + totalColumnsAbove), emptyRowsBefore,
                      height: blockHeight, width: blockWidth),
                )));
          }
        }
      }
    } else {
      widgets.add(Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "No grid data",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }

    return widgets;
  }

  Widget _buildGridBackground(CustomGridBackground gridBackgroundData) {
    if (gridBackgroundData != null) {
      if (gridBackgroundData.is_color) {
        String color = gridBackgroundData.link_or_color.replaceAll("#", "0xff");
        return Container(
          height: columns * getBlockSize(rows),
          color: Color(int.parse(color)),
        );
      } else if (gridBackgroundData.is_link) {
        String link = gridBackgroundData.link_or_color;
        return Container(
          height: columns * getBlockSize(rows),
          child: Image.network(link, fit: BoxFit.cover),
        );
      }
    } else {
      return Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "No grid backgroud data",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (editMode) {
        Set<int> selectedIndices = controller.value.selectedIndexes;
        startDrag = false;
        endColumnCurrentlyOn =
            (selectedIndices.elementAt(controller.value.amount - 1) / this.rows)
                .floor();
        endRowCurrentlyOn =
            selectedIndices.elementAt(controller.value.amount - 1) % this.rows;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    blockSize = getBlockSize(this.rows);

    return Container(
      height: this.columns == 0
          ? MediaQuery.of(context).size.height
          : this.columns * blockSize,
      child: Stack(
        children: [
          _buildGridBackground(gridCustomBackgroudData),
          createEmptyBlocks(),
          Stack(children: initGrids(data, blockSize)),
        ],
      ),
    );
  }
}

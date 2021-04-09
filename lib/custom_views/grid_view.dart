import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/block_content/color_combined_block_content.dart';
import 'package:grid_ui_implementation/models/block_content/image_combined_block_content.dart';
import 'package:grid_ui_implementation/models/comb_block_drag_info.dart';
import 'package:grid_ui_implementation/models/combined_block_content.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:grid_ui_implementation/models/block_content/text_combined_block_content.dart';
import 'package:grid_ui_implementation/models/grid_custom_background.dart';
import 'package:http/http.dart' as http;
import 'package:grid_ui_implementation/network_config.dart';

class GridUIView extends StatefulWidget {
  int rows;
  int columns;
  List<CombinedGroup> data;
  String grid_json;
  CustomGridBackground gridBackgroundData;
  _GridUIViewState state;

  GridUIView(this.grid_json, this.columns, this.rows, this.gridBackgroundData,
      this.data);

  @override
  _GridUIViewState createState() {
    state = _GridUIViewState(columns, rows, data,
        grid_json: grid_json, gridCustomBackgroudData: gridBackgroundData);

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
    // print(value);
    state.grid_json = value;
  }

  void changeCustomBackground(CustomGridBackground customGridBackground) {
    state.gridCustomBackgroudData = customGridBackground;
  }

  final _createCombinedBlockKey = GlobalKey<FormState>();
  final blockHeightController = TextEditingController();
  final blockWidthController = TextEditingController();
  final blockStartColumnController = TextEditingController();
  final blockStartRowController = TextEditingController();

  final _editCombinedBlockKey = GlobalKey<FormState>();
  final combinedBlockContentController = TextEditingController();

  ///Edit a combined block
  Future<void> editCombinedBlockDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Edit a combined block"),
              content: DropdownButton<String>(
                value: "dropdownValue",
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String newValue) {
                  // setState(() {
                  //   dropdownValue = newValue!;
                  // });
                },
                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ));
        });
  }

  ///Combined block creation dialog
  Future<void> createCombinedBlockialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create a combined block'),
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
                  state.addCombinedBlock(
                      state.grid_json,
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

  ///Combined block creation dialog
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
                  state.deleteCombinedBlock(
                      state.grid_json,
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
}

class _GridUIViewState extends State<GridUIView> {
  int columns;
  int rows;
  List<CombinedGroup> data;
  CustomGridBackground gridCustomBackgroudData;
  String grid_json;
  double blockSize;
  bool editMode = false;

  _GridUIViewState(this.columns, this.rows, this.data,
      {String grid_json, CustomGridBackground gridCustomBackgroudData}) {
    this.grid_json = grid_json;
    this.gridCustomBackgroudData = gridCustomBackgroudData;
  }

  bool getEditState() {
    return editMode;
  }

  void changeEditState(bool state) {
    setState(() {
      editMode = state;
    });
  }

  ///Returns the actual size of a block
  double getBlockSize(int rows) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / rows;
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
            "http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/move",
            data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
          grid_json = value.grid_json;
          columns = value.gridColumns;
          rows = value.gridRows;
          changeData(value.combinedGroups);
        });
      });
    });
  }

  ///Create a combined block
  void addCombinedBlock(String gridJSON, String height, String width,
      String startColumn, String startRow) {
    Map<String, String> data = {
      'grid_json': gridJSON,
      'height': height,
      'width': width,
      'start_row': width,
      'target_column': startColumn,
      'target_row': startRow.toString()
    };

    postGridToServer(
            "http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/create",
            data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
          grid_json = value.grid_json;
          columns = value.gridColumns;
          rows = value.gridRows;
          changeData(value.combinedGroups);
        });
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

    postGridToServer(
            "http://${NetworkConfig.serverAddr}:${NetworkConfig.serverPort}/delete",
            data)
        .then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
          grid_json = value.grid_json;
          columns = value.gridColumns;
          rows = value.gridRows;
          changeData(value.combinedGroups);
        });
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
    return Visibility(
      visible: editMode,
      child: DragTarget(
        builder: (context, List<CombBlockDragInformation> candidateData,
            rejectedData) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: blockSize,
              child: Center(
                child: Text(
                  '.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.grey[900], width: 1)),
            ),
          );
        },
        onWillAccept: (CombBlockDragInformation data) {
          return true;
        },
        onAccept: (data) {
          CombBlockDragInformation dragInformation = data;
          moveCombinedBlock(
              grid_json,
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
      ),
    );
  }

  ///Create a combined block
  ///
  ///Creates a combined block in a combined group on a grid. The [combinedGroupIndexInCombinedGroupList] is the index of the combined group in the CombinedGroup list, and the
  ///[combinedBlockIndexInCombinedGroup] is the section of the combined group the combined block resides is. The first combined block in a combined group will have
  ///a [combinedBlockIndexInCombinedGroup] value of 1, the second will have a value of 2 and so on.
  Widget createCombinedBlock(
      int combinedGroupIndexInCombinedGroupList,
      int combinedBlockIndexInCombinedGroup,
      Block block,
      int startCol,
      int startRow,
      {double height = 0.0,
      double width}) {
    double numberOfColumns = height / blockSize;
    double numberOfRows = width / blockSize;
    int blockQuadrant =
        0; //stores the block quadrant value when the user begins dragging the combined block
    CombBlockDragInformation dragInformation = CombBlockDragInformation();

    return LongPressDraggable(
      data: dragInformation,
      child: GestureDetector(
        onDoubleTap: () {

          int height = numberOfColumns.toInt();
          int width = numberOfRows.toInt();

          deleteCombinedBlock(grid_json, height.toString(), width.toString(),
              startCol.toString(), startRow.toString());
        },
        child: Container(
            width: width,
            decoration: BoxDecoration(
                border: editMode
                    ? Border.all(color: Colors.white, width: 2)
                    : null),
            child: Stack(
              children: [
                createCombinedBlockContent(block.content),

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
                                    int combinedBlockWidth =
                                        numberOfRows.toInt();
                                    int combinedBlockHeight =
                                        numberOfColumns.toInt();

                                    if (numberOfRows > 1) {
                                      blockQuadrant = colIndex + rowIndex + 1;
                                    } else {
                                      blockQuadrant = colIndex + 1;
                                    }

                                    dragInformation.block = block;
                                    dragInformation.blockQuadrantDraggingFrom =
                                        blockQuadrant;
                                    dragInformation.blockQuadrantColumn =
                                        colIndex;
                                    dragInformation.blockQuadrantRow = rowIndex;
                                    dragInformation.combinedBlockHeight =
                                        combinedBlockHeight;
                                    dragInformation.combinedBlockWidth =
                                        combinedBlockWidth;
                                    dragInformation.combinedBlockStartColumn =
                                        startCol;
                                    dragInformation.combinedBlockStartRow =
                                        startRow;
                                  },
                                  child: Container(
                                    width: blockSize,
                                    height: blockSize,
                                    decoration: BoxDecoration(color: null),
                                  ),
                                );
                              }));
                    }),
              ],
            )),
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
  Widget createCombinedBlockContent(BlockContent blockContent) {
    if (blockContent.content_type == "text") {
      TextContent content = blockContent.content;
      String text = content.value;
      print(content.blockColor);
      String blockColor = content.blockColor == "transperent"
          ? "transperent"
          : content.blockColor.replaceAll("#", "0xff");
      String color = content.color.replaceAll('#', '0xff');
      int position = content.position;
      double fontSize = content.fontSize;
      Alignment textPosition = getTextAlignemtPosition(position);

      return Container(
        color: blockColor == "transperent"
            ? Colors.transparent
            : Color(int.parse(blockColor)),
        child: Align(
          alignment: textPosition,
          child: Text(
            text,
            style:
                TextStyle(color: Color(int.parse(color)), fontSize: fontSize),
          ),
        ),
      );
    } else if (blockContent.content_type == "color") {
      ColorContent content = blockContent.content;
      String color = content.colorVal == "transparent"
          ? "transparent"
          : content.colorVal.replaceAll("#", "0xff");

      return Container(
        color: color == "transperent"
            ? Colors.transparent
            : Color(int.parse(color)),
      );
    } else if (blockContent.content_type == "image") {
      ImageContent content = blockContent.content;
      String link = content.link;

      return Image(
        image: NetworkImage(link),
      );
    } else {
      return Text("nothing");
    }
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

  ///Creates empty blocks above/below combined group
  ///
  ///Creates a group of empty blocks in the grid. The [combinedGroupIndexInCombinedGroupList] argument defines the index of the empty block's combined group in the combined
  ///group list.
  Widget createEmptyBlocks(
      int combinedGroupSection,
      int combinedBlockParentIndexInCombinedGroup,
      int combinedBlockColumnSection,
      int combinedBlockRowSection,
      int combinedGroupHeight,
      int combinedGroupWidth,
      Block parentBlock,
      int columnsAbove,
      int rowsToTheLeft,
      int columnOffset,
      int rowOffset,
      int columns,
      int rows,
      {int difference = 0}) {
    return Container(
      width: blockSize * rows,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: columns,
        itemBuilder: (context, columnIndex) {
          return Container(
            height: blockSize,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: rows,
              itemBuilder: (context, rowIndex) {
                return createSingleEmptyBlock(columnIndex, rowIndex);
              },
            ),
          );
        },
      ),
    );
  }

  List<Widget> initGrids(List data, double blockSize) {
    List<Widget> widgets = [];

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
              top: (emptyColsAbove+totalColumnsAbove) * blockSize,
              left: emptyRowsBefore * blockSize,
              child: Container(
                height: blockHeight,
                width: blockWidth,
                child: createCombinedBlock(combGroupIndex, i, block,
                    (emptyColsAbove+totalColumnsAbove), emptyRowsBefore,
                    height: blockHeight, width: blockWidth),
              )));
        }

      }
    }

    return widgets;
  }

  Widget _buildGridBackground(CustomGridBackground gridBackgroundData) {
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
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    blockSize = getBlockSize(this.rows);

    return Container(
      height: this.columns * blockSize,
      child: Stack(
        children: [
          _buildGridBackground(gridCustomBackgroudData),
          createEmptyBlocks(0, 0, 0, 0, 0, 0, null, 0, 0, 0, 0, columns, rows),
          // initGrids(data, blockSize)
          Stack(children: initGrids(data, blockSize))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/comb_block_drag_info.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:http/http.dart' as http;

class GridUIView extends StatefulWidget {
  int rows;
  int columns;
  List<CombinedGroup> data;
  _GridUIViewState state;

  GridUIView(this.columns, this.rows, this.data);

  @override
  _GridUIViewState createState() {
    state = _GridUIViewState(columns, rows, data);

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
}

class _GridUIViewState extends State<GridUIView> {
  int columns;
  int rows;
  List<CombinedGroup> data;
  double blockSize;
  bool editMode = false;

  _GridUIViewState(this.columns, this.rows, this.data);

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
      'start_column': startColumn.toString(),
      'start_row': startRow.toString(),
      'height': height.toString(),
      'width': width.toString(),
      'target_column': (targetColumn - blockQuadrantCol).toString(),
      'target_row': (targetRow - blockQuadrantRow).toString()
    };

    postGridToServer("http://192.168.1.129:5000/move", data).then((val) {
      Grid.getInstance()
          .loadJSON("", fromNetwork: true, grid: val)
          .then((value) {
        setState(() {
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
  Widget createSingleEmptyBlock(
      int combinedGroupSection,
      int columnsAboveCombinedGroup,
      int combinedBlockColumnSection,
      int blockColumn,
      Block parentBlock,
      int offset,
      {int gridPosition,
      int blockRow}) {
    return Visibility(
      visible: editMode,
      child: DragTarget(
        builder: (context, List<CombBlockDragInformation> candidateData,
            rejectedData) {
          return GestureDetector(
            onTap: () {
              int targetColumn = Grid.getInstance().getTargetColumn(
                  columnsAboveCombinedGroup,
                  combinedBlockColumnSection,
                  blockColumn,
                  parentBlock,
                  offset);
              int columnOnGrid = Grid.getInstance().getBlockColumn(
                  gridPosition, combinedGroupSection, blockColumn);
              // int rowOnGrid = Grid.getInstance().getBlockRow(gridPosition,
              //     combinedGroupSection, combinedBlockInGroupPosition, blockRow);
              // print(
              //     "empty block tapped is at grid section: $gridPosition, combined group section: $combinedGroupSection, combined block in group section: $combinedBlockInGroupPosition, column: $blockColumn, row: $blockRow");
              // print("col: $columnOnGrid, row: $blockRow");
            },
            child: Container(
              width: blockSize,
              child: Center(
                child: Icon(Icons.add, color: Colors.white),
              ),
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2)),
            ),
          );
        },
        onWillAccept: (CombBlockDragInformation data) {
          return true;
        },
        onAccept: (data) {
          CombBlockDragInformation dragInformation = data;
          int columnOnGrid = Grid.getInstance()
              .getBlockColumn(gridPosition, combinedGroupSection, blockColumn);
          // int rowOnGrid = Grid.getInstance().getBlockRow(gridPosition,
          //     combinedGroupSection, combinedBlockInGroupPosition, blockRow);

          // print("target column: ${columnOnGrid - 1}");
          // print("target row: ${rowOnGrid - 1}");

          // moveCombinedBlock(
          //     dragInformation.combinedBlockStartColumn,
          //     dragInformation.combinedBlockStartRow,
          //     dragInformation.combinedBlockHeight,
          //     dragInformation.combinedBlockWidth,
          //     columnOnGrid - 1,
          //     rowOnGrid - 1,
          //     dragInformation.blockQuadrantDraggingFrom,
          //     dragInformation.blockQuadrantColumn,
          // dragInformation.blockQuadrantRow);
        },
      ),
    );
  }

  ///Create a combined block
  ///
  ///Creates a combined block in a combined group on a grid. The [combinedGroupIndexInCombinedGroupList] is the index of the combined group in the CombinedGroup list, and the
  ///[combinedBlockIndexInCombinedGroup] is the section of the combined group the combined block resides is. The first combined block in a combined group will have
  ///a [combinedBlockIndexInCombinedGroup] value of 1, the second will have a value of 2 and so on.
  Widget createCombinedBlock(int combinedGroupIndexInCombinedGroupList,
      int combinedBlockIndexInCombinedGroup, Block block,
      {double height = 0.0, double width}) {
    double numberOfColumns = height / blockSize;
    double numberOfRows = width / blockSize;
    int blockQuadrant =
        0; //stores the block quadrant value when the user begins dragging the combined block
    CombBlockDragInformation dragInformation = CombBlockDragInformation();

    return LongPressDraggable(
      data: dragInformation,
      child: Container(
          width: width,
          decoration: BoxDecoration(
              color: Colors.white,
              border:
                  editMode ? Border.all(color: Colors.white, width: 2) : null),
          child: Stack(
            children: [
              Center(
                  child: Text(
                      "Combined block\n\ngrid section: ${combinedGroupIndexInCombinedGroupList}, combined block section ${combinedBlockIndexInCombinedGroup}")),

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
                                  int combinedBlockStartColumn =
                                      Grid.getInstance().getBlockStartColumn(
                                          combinedBlockIndexInCombinedGroup,
                                          combinedGroupIndexInCombinedGroupList);
                                  int combinedBlockStartRow = Grid.getInstance()
                                      .getBlockStartRow(
                                          combinedBlockIndexInCombinedGroup,
                                          combinedGroupIndexInCombinedGroupList);
                                  int combinedBlockWidth = numberOfRows.toInt();
                                  int combinedBlockHeight =
                                      numberOfColumns.toInt();

                                  if (numberOfRows > 1) {
                                    blockQuadrant =
                                        colIndex + colIndex + rowIndex + 1;
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
                                      combinedBlockStartColumn;
                                  dragInformation.combinedBlockStartRow =
                                      combinedBlockStartRow;
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

  ///Creates empty blocks above/below combined group
  ///
  ///Creates a group of empty blocks in the grid. The [combinedGroupIndexInCombinedGroupList] argument defines the index of the empty block's combined group in the combined
  ///group list.
  Widget createEmptyBlocks(
      int combinedGroupIndexInCombinedGroupList,
      int combinedBlockParentIndexInCombinedGroup,
      int combinedBlockColumnSection,
      int combinedBlockRowSection,
      Block parentBlock,
      int columnsAbove,
      int columnOffset,
      int columns,
      int rows) {
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
                return createSingleEmptyBlock(
                    combinedBlockParentIndexInCombinedGroup,
                    columnsAbove,
                    combinedBlockColumnSection,
                    columnIndex + 1,
                    parentBlock,
                    columnOffset);
              },
            ),
          );
        },
      ),
    );
  }

  ///Creates a combined group with 1 combined block
  ///
  ///The [combinedGridListIndex] argument defines the index of the empty block's combined group in the combined
  ///group list. The number of empty blocks before(to the left) a combined block is set with
  ///the [emptyRowsBefore] param, the number of blocks after(to the right) a combined
  ///block is set with the [emptyRowsAfter] param, the width of the combined block is
  ///set with the [combinedBlockWidth] and the combined group height is set with the
  ///[combinedGroupHeight] param.
  ///
  ///[combined]
  ///
  Widget createCombinedGroupWith1CombinedBlock(
      int combinedGridListIndex,
      int totalColumnsAbove,
      Block block,
      int emptyRowsBefore,
      int emptyRowsAfter,
      int combinedBlockWidth,
      int combinedGroupHeight) {
    bool hasEmptyBlocksBeforeBeenBuilt = false;
    bool hasCombinedBlockBeenBuilt = false;
    bool hasEmptyBlocksAfterBeenBuilt = false;

    ///The default value of [combinedGroupSection] for the main section is 2
    int combinedGroupSection = 2;

    ///This is the index of a combined block in a combined group. This value is 1 by default, for combined groups with 1 combined block
    int combinedBlockIndexInCombinedGroup = 1;
    print("combinedGroupHeight $combinedGroupHeight");

    return Container(
        height: blockSize * combinedGroupHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              3, //each combined group section(blocks before|combined block|blocks after)
          itemBuilder: (context, rowIndex) {
            /* ======================================
             * EMPTY BLOCKS BEFORE THE COMBINED BLOCK
             ========================================*/
            if (!hasEmptyBlocksBeforeBeenBuilt) {
              hasEmptyBlocksBeforeBeenBuilt = true;
              int combinedBlockParentIndexInCombinedGroup = 1;
              int combinedBlockColumnSection = combinedGroupSection;
              int combinedBlockRowSection = 1;
              int columnOffset = 0;
              int numberOfEmptyBlockColumns = combinedGroupHeight;
              int numberOfEmptyBlockRows = emptyRowsBefore;

              return createEmptyBlocks(
                  combinedGridListIndex,
                  combinedBlockParentIndexInCombinedGroup,
                  combinedBlockColumnSection,
                  combinedBlockRowSection,
                  block,
                  totalColumnsAbove,
                  columnOffset,
                  numberOfEmptyBlockColumns,
                  numberOfEmptyBlockRows);
            } else {
              if (!hasCombinedBlockBeenBuilt) {
                hasCombinedBlockBeenBuilt = true;
                return createCombinedBlock(combinedGridListIndex,
                    combinedBlockIndexInCombinedGroup, block,
                    height: blockSize * combinedGroupHeight,
                    width: blockSize * combinedBlockWidth);
              } else {
                if (!hasEmptyBlocksAfterBeenBuilt) {
                  /* ======================================
                 * EMPTY BLOCKS AFTER THE COMBINED BLOCK
                 ========================================*/
                  hasEmptyBlocksAfterBeenBuilt = true;
                  int combinedBlockParentIndexInCombinedGroup = 1;
                  int combinedBlockColumnSection = combinedGroupSection;
                  int combinedBlockRowSection = 1;
                  int columnOffset = 0;
                  int numberOfEmptyBlockColumns = combinedGroupHeight;
                  int numberOfEmptyBlockRows = emptyRowsAfter;

                  return createEmptyBlocks(
                      combinedGridListIndex,
                      combinedBlockParentIndexInCombinedGroup,
                      combinedBlockColumnSection,
                      combinedBlockRowSection,
                      block,
                      totalColumnsAbove,
                      columnOffset,
                      numberOfEmptyBlockColumns,
                      numberOfEmptyBlockRows);
                } else {
                  return Container();
                }
              }
            }
          },
        ));
  }

  ///Create a combined group with 2 or more combined blocks
  ///
  ///Height of the combined group is set with the [combinedGroupHeight] param, and
  ///the combined blocks are set with the [combinedBlocksConfig] param
  ///
  ///
  Widget createCombinedGroupWithMultipleCombinedBlocks(
      int combinedGroupIndexInCombinedGroupList,
      int totalNumberOfIndividualRows,
      int combinedGroupHeight,
      List<List> combinedBlocksConfig) {
    return Container(
      height: blockSize * combinedGroupHeight,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: combinedBlocksConfig.length,
          itemBuilder: (context, combinedBlockBlockIndex) {
            Block block = combinedBlocksConfig[combinedBlockBlockIndex][3];

            int numberOfRowsBefore =
                combinedBlocksConfig[combinedBlockBlockIndex][1];
            int numberOfRowsAfter =
                (combinedBlockBlockIndex + 1 != combinedBlocksConfig.length)
                    ? 0
                    : combinedBlocksConfig[combinedBlockBlockIndex][2];
            int combinedBlockWidth =
                combinedBlocksConfig[combinedBlockBlockIndex][0];

            int totalNumberOfRowsForCombinedBlock =
                numberOfRowsBefore + combinedBlockWidth + numberOfRowsAfter;
            return Container(
              width: blockSize * totalNumberOfRowsForCombinedBlock,
              child: createCombinedGroupWith1CombinedBlock(
                  combinedGroupIndexInCombinedGroupList,
                  totalNumberOfIndividualRows,
                  block,
                  numberOfRowsBefore,
                  numberOfRowsAfter,
                  combinedBlockWidth,
                  combinedGroupHeight),
            );
          }),
    );
  }

  ///Creates a combined group with 2 or more combined blocks with different heights
  ///
  ///
  ///**Combined block structure**
  ///
  ///Example: Combined block with height of 2, width of 2, 3 blocks before, 2 blocks after, 1 block above, 2 blocks below  = [2, 2, 3, 2, 1, 2]
  ///
  Widget createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
      int combinedGroupIndexInCombinedGroupList,
      int totalColumnsAbove,
      int numberOfRows,
      int combinedBlockInGroupSection,
      int combinedGroupHeight,
      List<List> combinedBlocks) {
    int combinedBlockIndexInCombinedGroup = 0;

    return Container(
        height: blockSize * combinedGroupHeight,
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            scrollDirection: Axis.horizontal,
            itemCount: combinedBlocks.length,
            itemBuilder: (context, rowIndex) {
              combinedBlockIndexInCombinedGroup++;
              bool hasBlocksBeforeBeenBuilt = false;
              bool hasCombinedBlockBeenBuilt = false;
              bool hasBlocksAfterBeenBuilt = false;

              Block block = combinedBlocks[rowIndex][6];

              int numberOfBlocksBefore = combinedBlocks[rowIndex][2];
              int numberOfBlocksAfter =
                  (combinedBlockIndexInCombinedGroup == combinedBlocks.length)
                      ? combinedBlocks[rowIndex][3]
                      : 0;
              int numberOfBlocksAboveCombinedBlock =
                  combinedBlocks[rowIndex][4];
              int numberOfBlocksBelowCombinedBlock =
                  combinedBlocks[rowIndex][5];
              int combinedBlockHeight = combinedGroupHeight -
                  (numberOfBlocksAboveCombinedBlock +
                      numberOfBlocksBelowCombinedBlock);
              int combinedBlockWidth = combinedBlocks[rowIndex][1];
              int totalNumberOfRowsForCombinedBlock = numberOfBlocksBefore +
                  combinedBlockWidth +
                  numberOfBlocksAfter;

              return Container(
                width: blockSize * totalNumberOfRowsForCombinedBlock,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, combinedBlockRowIndex) {
                    //Blocks before the combined blcok
                    if (!hasBlocksBeforeBeenBuilt) {
                      hasBlocksBeforeBeenBuilt = true;

                      int combinedBlockParentIndexInCombinedGroup = 1;
                      int combinedBlockColumnSection = 2;
                      int combinedBlockRowSection = 1;
                      int columnOffset = 0;
                      int numberOfEmptyBlockColumns = combinedGroupHeight;
                      int numberOfEmptyBlockRows = numberOfBlocksBefore;

                      return createEmptyBlocks(
                          combinedGroupIndexInCombinedGroupList,
                          combinedBlockParentIndexInCombinedGroup,
                          combinedBlockColumnSection,
                          combinedBlockRowSection,
                          block,
                          totalColumnsAbove,
                          columnOffset,
                          numberOfEmptyBlockColumns,
                          numberOfEmptyBlockRows);
                    } else {
                      if (!hasCombinedBlockBeenBuilt) {
                        hasCombinedBlockBeenBuilt = true;

                        bool hasBlockAboveBeenBuilt = false;
                        bool hasInnerCombinedBlockBeenBuilt = false;
                        bool hasBlocksBelowBeenBuilt = false;

                        return Container(
                          width: blockSize * combinedBlockWidth,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder:
                                (context, combinedBlockAboveColumnIndex) {
                              //Above the combined block
                              if (!hasBlockAboveBeenBuilt) {
                                hasBlockAboveBeenBuilt = true;

                                int combinedBlockParentIndexInCombinedGroup = 1;
                                int combinedBlockColumnSection = 2;
                                int combinedBlockRowSection = 2;
                                int columnOffset = 0;
                                int numberOfEmptyBlockColumns =
                                    numberOfBlocksAboveCombinedBlock;
                                int numberOfEmptyBlockRows = combinedBlockWidth;

                                return createEmptyBlocks(
                                    combinedGroupIndexInCombinedGroupList,
                                    combinedBlockParentIndexInCombinedGroup,
                                    combinedBlockColumnSection,
                                    combinedBlockRowSection,
                                    block,
                                    totalColumnsAbove,
                                    columnOffset,
                                    numberOfEmptyBlockColumns,
                                    numberOfEmptyBlockRows);
                              } else {
                                if (!hasInnerCombinedBlockBeenBuilt) {
                                  hasInnerCombinedBlockBeenBuilt = true;

                                  return Container(
                                    height: blockSize * combinedBlockHeight,
                                    child: createCombinedBlock(
                                        combinedGroupIndexInCombinedGroupList,
                                        combinedBlockIndexInCombinedGroup,
                                        block,
                                        height: blockSize * combinedBlockHeight,
                                        width: blockSize * combinedBlockWidth),
                                  );
                                } else {
                                  if (!hasBlocksBelowBeenBuilt) {
                                    hasBlocksBelowBeenBuilt = true;

                                    int combinedBlockParentIndexInCombinedGroup =
                                        1;
                                    int combinedBlockColumnSection = 2;
                                    int combinedBlockRowSection = 2;
                                    int columnOffset = 0;
                                    int numberOfEmptyBlockColumns =
                                        numberOfBlocksBelowCombinedBlock;
                                    int numberOfEmptyBlockRows =
                                        combinedBlockWidth;

                                    return createEmptyBlocks(
                                        combinedGroupIndexInCombinedGroupList,
                                        combinedBlockParentIndexInCombinedGroup,
                                        combinedBlockColumnSection,
                                        combinedBlockRowSection,
                                        block,
                                        totalColumnsAbove,
                                        columnOffset,
                                        numberOfEmptyBlockColumns,
                                        numberOfEmptyBlockRows);
                                  } else {
                                    return Container();
                                  }
                                }
                              }
                            },
                          ),
                        );
                      } else {
                        if (!hasBlocksAfterBeenBuilt) {
                          hasBlocksAfterBeenBuilt = true;

                          int combinedBlockParentIndexInCombinedGroup =
                              combinedBlockIndexInCombinedGroup;
                          int combinedBlockColumnSection = 0;
                          int combinedBlockRowSection = 3;
                          int columnOffset = 0;
                          int numberOfEmptyBlockColumns = combinedGroupHeight;
                          int numberOfEmptyBlockRows = numberOfBlocksAfter;

                          return createEmptyBlocks(
                              combinedGroupIndexInCombinedGroupList,
                              combinedBlockParentIndexInCombinedGroup,
                              combinedBlockColumnSection,
                              combinedBlockRowSection,
                              block,
                              totalColumnsAbove,
                              columnOffset,
                              numberOfEmptyBlockColumns,
                              numberOfEmptyBlockRows);
                        } else {
                          return Container();
                        }
                      }
                    }
                  },
                ),
              );
            }));
  }

  ///Create a grid layout from the grid data provided
  ///
  ///The method loads the data provided ([data]) and creates the grid.
  Widget initUI(List data, double blockSize) {
    if (this.data != null && this.data.length > 0) {
      int numberOfCombinedGroups = data.length;

      ///This listview creates each combined group. A combined group is a collection of 1 or more combined blocks.
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: numberOfCombinedGroups,
          itemBuilder: (context, combGroupIndex) {
            ///A combined group has 3 sections. Top section, Main Section(where the combined blocks are) and the Bottom section
            int numberOfCombinedGroupSections = 3;

            int totalColumnsAbove = 0;

            ///Top section [hasAboveBeenBuilt], Main combined blocks [hasCombinedGroupBeenBuilt] and Bottom section [hasBelowBeenBuilt]
            bool hasTopSectionBeenBuilt = false;
            bool hasMainSectionBeenBuilt = false;
            bool hasBottomSectionBeenBuilt = false;

            ///This listview creates each combined group section
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: numberOfCombinedGroupSections,
                itemBuilder: (context, index) {
                  CombinedGroup combinedGroup = data[combGroupIndex];
                  int columnsAboveMainSection = combinedGroup.columnsAbove;
                  int columnsBelowMainSection = combinedGroup.columnsBelow;
                  int combinedGroupRows = combinedGroup.numberOfRows;
                  //===========
                  //Top section
                  //===========
                  if (!hasTopSectionBeenBuilt) {
                    hasTopSectionBeenBuilt = true;

                    /*The combined group section [combinedGroupSection] for the top blocks is 1
                    
                     |-|-|-| - The combined group section for the top block(s) section is 1
                     -------
                     |x|x|x| - } The combined group section for the combined block(s) section is 2
                     |x|x|x| /
                     -------
                     |-|-|-| - The combined group section for the bottom blocks section is 3
                    */
                    int combinedGroupSection = 1;
                    int tempTotalColumnsAbove = totalColumnsAbove;
                    int columnOffset = 0;
                    int combinedBlockColumnSection = combinedGroupSection;
                    int combinedBlockRowSection = 0;
                    int combinedBlockParentIndexInCombinedGroup = 0;
                    Block parentBlock = null;

                    totalColumnsAbove += columnsAboveMainSection;
                    return createEmptyBlocks(
                        combinedGroupSection,
                        combinedBlockParentIndexInCombinedGroup,
                        combinedBlockColumnSection,
                        combinedBlockRowSection,
                        parentBlock,
                        tempTotalColumnsAbove,
                        columnOffset,
                        columnsAboveMainSection,
                        rows);
                  } else {
                    //====================
                    //Main combined blocks
                    //====================
                    if (!hasMainSectionBeenBuilt) {
                      hasMainSectionBeenBuilt = true;
                      int combinedGroupSection = 2;

                      ///Combined group has only 1 combined block
                      if (combinedGroup.combinedGroupType ==
                          CombinedGroupType.SINGLE_COMBINED_GROUP) {
                        CombinedBlockInGroup combinedBlockInGroup =
                            combinedGroup.combinedBlocks[0];
                        Block block = combinedBlockInGroup.block;

                        int emptyRowsBefore =
                            combinedBlockInGroup.numberOfRowsLeft;
                        int emptyRowsAfter =
                            combinedBlockInGroup.numberOfRowsRight;
                        int combinedGroupHeight = block.numberOfColumns;
                        int tempTotalColumnsAbove = totalColumnsAbove;
                        totalColumnsAbove += columnsAboveMainSection;

                        print("combinedGroupHeight $combinedGroupHeight");

                        return createCombinedGroupWith1CombinedBlock(
                            combGroupIndex + 1,
                            tempTotalColumnsAbove,
                            block,
                            emptyRowsBefore,
                            emptyRowsAfter,
                            block.numberOfRows,
                            combinedGroupHeight);

                        ///Combined group has multiple combined blocks all with the same height
                      } else if (combinedGroup.combinedGroupType ==
                          CombinedGroupType
                              .MULITPLE_COMBINED_GROUP_SAME_HEIGHT) {
                        int combinedGroupHeight = combinedGroup.numberOfColumns;
                        List<List> combinedBlocksConfigList = [];

                        for (CombinedBlockInGroup combinedBlockInGroup
                            in combinedGroup.combinedBlocks) {
                          Block block = combinedBlockInGroup.block;

                          int combinedBlockWidth = block.numberOfRows;
                          int rowsBeforeBlock =
                              combinedBlockInGroup.numberOfRowsLeft;
                          int rowsAfterBlock =
                              combinedBlockInGroup.numberOfRowsRight;

                          combinedBlocksConfigList.add([
                            combinedBlockWidth,
                            rowsBeforeBlock,
                            rowsAfterBlock,
                            block
                          ]);
                        }

                        return createCombinedGroupWithMultipleCombinedBlocks(
                            combGroupIndex + 1,
                            rows,
                            combinedGroupHeight,
                            combinedBlocksConfigList);

                        ///Combined group has multiple combined blocks with different heights
                      } else if (combinedGroup.combinedGroupType ==
                          CombinedGroupType
                              .MULTIPLE_COMBINED_GROUP_DIFF_HEIGHT) {
                        int combinedGroupHeight = combinedGroup.numberOfColumns;
                        List<List> combinedBlocksList = [];

                        for (CombinedBlockInGroup combinedBlockInGroup
                            in combinedGroup.combinedBlocks) {
                          Block block = combinedBlockInGroup.block;

                          int combinedBlockHeight = block.numberOfColumns;
                          int combinedBlockWidth = block.numberOfRows;
                          int rowsBeforeBlock =
                              combinedBlockInGroup.numberOfRowsLeft;
                          int rowsAfterBlock =
                              combinedBlockInGroup.numberOfRowsRight;
                          int columnsBelowBlock =
                              combinedBlockInGroup.numberOfColumnsBelow;
                          int columnsAboveBlock =
                              combinedBlockInGroup.numberOfColumnsAbove;
                          combinedBlocksList.add([
                            combinedBlockHeight,
                            combinedBlockWidth,
                            rowsBeforeBlock,
                            rowsAfterBlock,
                            columnsAboveBlock,
                            columnsBelowBlock,
                            block
                          ]);
                        }

                        return createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
                            combGroupIndex + 1,
                            totalColumnsAbove,
                            combinedGroupRows,
                            combinedGroupSection,
                            combinedGroupHeight,
                            combinedBlocksList);
                      } else {
                        return Container();
                      }
                    } else {
                      //==================
                      //Empty blocks below
                      //==================
                      ///This section only gets built for the last combined group in the combined group list ([data]).
                      if (!hasBottomSectionBeenBuilt) {
                        hasBottomSectionBeenBuilt = true;

                        ///The combined group section [combinedGroupSection] for the bottom blocks is 3
                        ///
                        /// |-|-|-| - The combined group section for the top block(s) section is 1
                        /// |x|x|x| - } The combined group section for the combined block(s) section is 2
                        /// |x|x|x| /
                        /// |-|-|-| - The combined group section for the bottom blocks section is 3
                        int combinedGroupSection = 3;

                        int tempTotalColumnsAbove = totalColumnsAbove;
                        int columnOffset = 0;
                        int combinedBlockColumnSection = combinedGroupSection;
                        int combinedBlockRowSection = 0;
                        int combinedBlockParentIndexInCombinedGroup = 0;
                        Block parentBlock = null;

                        totalColumnsAbove += columnsAboveMainSection;

                        return createEmptyBlocks(
                            combinedGroupSection,
                            combinedBlockParentIndexInCombinedGroup,
                            combinedBlockColumnSection,
                            combinedBlockRowSection,
                            parentBlock,
                            tempTotalColumnsAbove,
                            columnOffset,
                            columnsBelowMainSection,
                            rows);
                      } else {
                        return Container();
                      }
                    }
                  }
                });
          });
    } else {
      return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Center(
            child: Text("No data"),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    blockSize = getBlockSize(this.rows);

    return initUI(data, blockSize);
  }
}

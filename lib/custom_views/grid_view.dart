import 'dart:convert';

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
}

class _GridUIViewState extends State<GridUIView> {
  int columns;
  int rows;
  List<CombinedGroup> data;

  int currentIndex = 0;

  _GridUIViewState(this.columns, this.rows, this.data);

  ///Returns the actual size of a block
  double getBlockSize(int rows) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / rows;
  }

  Future<String> getGridFromServer(String url) async {
    http.Response response = await http.get(url);
    String grid;

    if (response.statusCode == 200) {
      grid = response.body;
    } else {
      grid = '';
    }

    return grid;
  }

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

  void moveCombinedBlock(int startColumn, int startRow, int height, int width,
      int targetColumn, int targetRow) {
    Map<String, String> data = {
      'start_column': startColumn.toString(),
      'start_row': startRow.toString(),
      'height': height.toString(),
      'width': width.toString(),
      'target_column': targetColumn.toString(),
      'target_row': targetRow.toString()
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

  void changeCols(int colsChange) {
    setState(() {
      columns = colsChange;
    });
  }

  void changeRows(int rowsChange) {
    setState(() {
      rows = rowsChange;
    });
  }

  void changeData(List data) {
    setState(() {
      this.data = data;
    });
  }

  ///Creates a single block
  Widget createSingleBlock(double blockSize,
      {int gridPosition,
      int combinedGroupSection = 2,
      int combinedBlockInGroupPosition = 1,
      int blockColumn,
      int blockRow}) {
    bool dropped = false;
    return DragTarget(
      builder: (context, List<CombBlockDragInformation> candidateData,
          rejectedData) {
        return GestureDetector(
          onTap: () {
            int columnOnGrid = Grid.getInstance().getBlockColumn(
                gridPosition, combinedGroupSection, blockColumn);
            int rowOnGrid = Grid.getInstance().getBlockRow(gridPosition,
                combinedGroupSection, combinedBlockInGroupPosition, blockRow);
            print(
                "empty block tapped is at grid section: $gridPosition, combined group section: $combinedGroupSection, combined block in group section: $combinedBlockInGroupPosition, column: $blockColumn, row: $blockRow");
            print("col: $columnOnGrid, row: $rowOnGrid");
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
        int rowOnGrid = Grid.getInstance().getBlockRow(gridPosition,
            combinedGroupSection, combinedBlockInGroupPosition, blockRow);

        moveCombinedBlock(
            dragInformation.combinedBlockStartColumn,
            dragInformation.combinedBlockStartRow,
            dragInformation.combinedBlockHeight,
            dragInformation.combinedBlockWidth,
            columnOnGrid - 1,
            rowOnGrid - 1);
      },
    );
  }

  ///Create a combined block
  Widget createCombinedBlock(
      int gridSection, int combinedBlockSection, Block block,
      {double height = 0.0, double width}) {
    double numberOfColumns = height / getBlockSize(rows);
    double numberOfRows = width / getBlockSize(rows);
    int blockQuadrant =
        0; //stores the value of the quadrant from which the user began dragging the combined block

    CombBlockDragInformation dragInformation = CombBlockDragInformation();
    return LongPressDraggable(
      data: dragInformation,
      child: Container(
          width: width,
          decoration: BoxDecoration(
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2)),
          child: ListView.builder(
              itemCount: numberOfColumns.toInt(),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, colIndex) {
                return Container(
                    height: getBlockSize(rows),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: numberOfRows.toInt(),
                        itemBuilder: (context, rowIndex) {
                          return GestureDetector(
                            onTapDown: (details) {
                              int combinedBlockStartColumn = Grid.getInstance()
                                  .getBlockStartColumn(
                                      combinedBlockSection, gridSection);
                              int combinedBlockStartRow = Grid.getInstance()
                                  .getBlockStartRow(
                                      combinedBlockSection, gridSection);
                              int combinedBlockWidth = numberOfRows.toInt();
                              int combinedBlockHeight = numberOfColumns.toInt();
                              if (numberOfRows > 1) {
                                //if the user is not holding a quadrant from the first column
                                blockQuadrant =
                                    colIndex + colIndex + rowIndex + 1;
                              } else {
                                blockQuadrant = colIndex + 1;
                              }

                              dragInformation.block = block;
                              dragInformation.blockQuadrantDraggingFrom =
                                  blockQuadrant;
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
                              width: getBlockSize(rows),
                              height: getBlockSize(rows),
                              decoration: BoxDecoration(color: null),
                            ),
                          );
                        }));
              })),
      feedback: Container(
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
  Widget createEmptyBlocks(int gridSection, int combinedGroupSection,
      int columns, int rows, double blockSize) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: columns,
      itemBuilder: (context, columnIndex) {
        // print(gridSection);

        // print("here");
        return Container(
          height: blockSize,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: rows,
            itemBuilder: (context, rowIndex) {
              return createSingleBlock(blockSize,
                  gridPosition: gridSection,
                  combinedGroupSection: combinedGroupSection,
                  blockColumn: columnIndex + 1,
                  blockRow: rowIndex + 1);
            },
          ),
        );
      },
    );
  }

  ///Creates a combined group with 1 combined block
  ///
  ///The number of empty blocks before(to the left) a combined block are set with
  ///the [emptyRowsBefore] param, the number of blocks after(to the right) a combined
  ///block are set with the [emptyRowsAfter] param, the width of the combined block is
  ///set with the [combinedBlockWidth] and the combined group height is set with the
  ///[combinedGroupHeight] param
  ///
  Widget createCombinedGroupWith1CombinedBlock(
      int gridSection,
      int combinedBlockSection,
      int totalRows,
      int emptyRowsBefore,
      int emptyRowsAfter,
      int combinedBlockWidth,
      int combinedGroupHeight) {
    bool hasEmptyBlocksBeforeBeingBuilt = false;
    bool hasCombinedBlockBeingBuilt = false;
    // int totalRows = emptyRowsBefore + combinedBlockWidth + emptyRowsAfter;
    int singleBlockSection = 0;

    return Container(
        height: getBlockSize(totalRows) * combinedGroupHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              3, //each combined group section(blocks before|comb. block|blocks after)
          itemBuilder: (context, rowIndex) {
            singleBlockSection++;
            /*====================
             * Build each combined group section (i.e the empty blocks before, the combined block and the empty blocks after)
             =====================*/

            /* ======================================
             * EMPTY BLOCKS BEFORE THE COMBINED BLOCK
             ========================================*/
            if (!hasEmptyBlocksBeforeBeingBuilt) {
              hasEmptyBlocksBeforeBeingBuilt = true;
              return Container(
                width: getBlockSize(totalRows) * emptyRowsBefore,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount:
                        combinedGroupHeight, //Each column before the combined block
                    itemBuilder: (context, columnIndex) {
                      /*============
                       * EACH COLUMN
                       =============*/
                      return Container(
                        height: getBlockSize(totalRows),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: emptyRowsBefore,
                          itemBuilder: (context, rowIndex) {
                            return createSingleBlock(getBlockSize(totalRows),
                                gridPosition: gridSection,
                                combinedBlockInGroupPosition:
                                    combinedBlockSection,
                                blockColumn: columnIndex + 1,
                                blockRow: rowIndex + 1);
                          },
                        ),
                      );
                    }),
              );
            } else {
              /*===============
               * COMBINED BLOCK
               ================*/
              if (!hasCombinedBlockBeingBuilt) {
                hasCombinedBlockBeingBuilt = true;
                Block block = Block(BlockType.combined, null,
                    combinedGroupHeight, combinedBlockWidth);
                return createCombinedBlock(
                    gridSection, combinedBlockSection, block,
                    height: getBlockSize(totalRows) * combinedGroupHeight,
                    width: getBlockSize(totalRows) * combinedBlockWidth);
              } else {
                /* ======================================
                 * EMPTY BLOCKS AFTER THE COMBINED BLOCK
                 ========================================*/
                return Container(
                  width: getBlockSize(totalRows) * emptyRowsAfter,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(0),
                      itemCount:
                          combinedGroupHeight, //Each column before the combined block
                      itemBuilder: (context, columnIndex) {
                        return Container(
                          height: getBlockSize(totalRows),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: emptyRowsAfter,
                            itemBuilder: (context, rowIndex) {
                              return createSingleBlock(getBlockSize(totalRows),
                                  gridPosition: gridSection,
                                  combinedBlockInGroupPosition:
                                      combinedBlockSection + 1,
                                  blockColumn: columnIndex + 1,
                                  blockRow: rowIndex + 1);
                            },
                          ),
                        );
                      }),
                );
              }
            }
          },
        ));
  }

  ///Create a combined group with 2 or more combined blocks
  ///
  ///Height of the combined group is set with the [combinedGroupHeight] param, and
  ///the combined blocks are set with the [combinedBlocks] param
  ///
  ///
  Widget createCombinedGroupWithMultipleCombinedBlocks(
      int gridSection,
      int totalNumberOfIndividualRows,
      int combinedGroupHeight,
      List<List> combinedBlocks) {
    int combinedBlockSection = 0;
    return Container(
      height: getBlockSize(totalNumberOfIndividualRows) * combinedGroupHeight,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: combinedBlocks.length,
          itemBuilder: (context, combinedBlockBlockIndex) {
            combinedBlockSection++;

            int numberOfRowsBefore = combinedBlocks[combinedBlockBlockIndex][1];
            int numberOfRowsAfter = combinedBlocks[combinedBlockBlockIndex][2];
            int combinedBlockWidth = combinedBlocks[combinedBlockBlockIndex][0];

            if (combinedBlockBlockIndex + 1 != combinedBlocks.length) {
              int totalNumberOfRowsForCombinedBlock =
                  numberOfRowsBefore + combinedBlockWidth + 0;
              return Container(
                width: getBlockSize(totalNumberOfIndividualRows) *
                    totalNumberOfRowsForCombinedBlock,
                child: createCombinedGroupWith1CombinedBlock(
                    gridSection,
                    combinedBlockSection,
                    totalNumberOfIndividualRows,
                    numberOfRowsBefore,
                    0,
                    combinedBlockWidth,
                    combinedGroupHeight),
              );
            } else {
              int totalNumberOfRowsForCombinedBlock =
                  numberOfRowsBefore + combinedBlockWidth + numberOfRowsAfter;
              return Container(
                width: getBlockSize(totalNumberOfIndividualRows) *
                    totalNumberOfRowsForCombinedBlock,
                child: createCombinedGroupWith1CombinedBlock(
                    gridSection,
                    combinedBlockSection,
                    totalNumberOfIndividualRows,
                    numberOfRowsBefore,
                    numberOfRowsAfter,
                    combinedBlockWidth,
                    combinedGroupHeight),
              );
            }
          }),
    );
  }

  ///Creates a combined group with 2 or more combined blocks with different heights
  ///
  ///Combined block structure
  ///------------------------
  ///Example: Combined block with height of 2, width of 2, 3 blocks before, 2 blocks after, 1 block above, 2 blocks below  = [2, 2, 3, 2, 1, 2]
  ///
  Widget createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
      int gridSection,
      int numberOfRows,
      int combinedGroupHeight,
      List<List> combinedBlocks) {
    int combinedBlockSection = 0;
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (context, columnIndex) {
          return Container(
              height: getBlockSize(numberOfRows) * combinedGroupHeight,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  scrollDirection: Axis.horizontal,
                  itemCount: combinedBlocks.length,
                  itemBuilder: (context, rowIndex) {
                    combinedBlockSection++;
                    int blocksBeforeChecked = 0;
                    int blocksAfterChecked = 0;
                    bool hasCombinedBlockBeingBuilt = false;

                    int numberOfBlocksBefore = combinedBlocks[rowIndex][2];
                    int numberOfBlocksAfter = combinedBlocks[rowIndex][3];
                    int numberOfBlocksAboveCombinedBlock =
                        combinedBlocks[rowIndex][4];
                    int numberOfBlocksBelowCombinedBlock =
                        combinedBlocks[rowIndex][5];
                    int combinedBlockHeight = combinedGroupHeight -
                        (numberOfBlocksAboveCombinedBlock +
                            numberOfBlocksBelowCombinedBlock);
                    int combinedBlockWidth = combinedBlocks[rowIndex][1];

                    int totalNumberOfRowsForCombinedBlock =
                        numberOfBlocksBefore +
                            combinedBlockWidth +
                            numberOfBlocksAfter;

                    //if currently on the last combined block
                    if (rowIndex == (combinedBlocks.length - 1)) {
                      return ListView.builder(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: totalNumberOfRowsForCombinedBlock,
                        itemBuilder: (context, combinedBlockRowIndex) {
                          //Blocks before the combined blcok
                          if (blocksBeforeChecked < numberOfBlocksBefore) {
                            blocksBeforeChecked++;

                            return Container(
                                width: getBlockSize(numberOfRows),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: combinedGroupHeight,
                                    itemBuilder: (context, columnIndex) {
                                      return Container(
                                          height: getBlockSize(numberOfRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context, rowIndex) {
                                                return createSingleBlock(
                                                    getBlockSize(numberOfRows),
                                                    gridPosition: gridSection,
                                                    blockColumn: columnIndex,
                                                    blockRow: rowIndex);
                                              }));
                                    }));
                          } else {
                            if (!hasCombinedBlockBeingBuilt) {
                              hasCombinedBlockBeingBuilt = true;
                              int blocksAboveChecked = 0;
                              int blocksBelowChecked = 0;
                              bool hasInnerCombinedBlockBeenBuilt = false;

                              return Container(
                                  width: getBlockSize(numberOfRows) *
                                      combinedBlockWidth,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(0),
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: 3,
                                    itemBuilder: (context,
                                        combinedBlockAboveColumnIndex) {
                                      //Above the combined block
                                      if (blocksAboveChecked <
                                          numberOfBlocksAboveCombinedBlock) {
                                        blocksAboveChecked++;

                                        return ListView.builder(
                                          padding: EdgeInsets.all(0),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              numberOfBlocksAboveCombinedBlock,
                                          itemBuilder: (context,
                                              combinedBlocksAboveIndex) {
                                            return Container(
                                                height:
                                                    getBlockSize(numberOfRows),
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    padding: EdgeInsets.all(0),
                                                    itemCount:
                                                        combinedBlockWidth,
                                                    itemBuilder: (context,
                                                        blocksAboveCombinedBlockRowIndex) {
                                                      return createSingleBlock(
                                                          getBlockSize(
                                                              numberOfRows),
                                                          gridPosition:
                                                              gridSection,
                                                          blockColumn:
                                                              columnIndex,
                                                          blockRow: rowIndex);
                                                    }));
                                          },
                                        );
                                      } else {
                                        //Combined block
                                        if (!hasInnerCombinedBlockBeenBuilt) {
                                          hasInnerCombinedBlockBeenBuilt = true;

                                          return ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: 1,
                                            itemBuilder: (context,
                                                innerCombinedBlockColumn) {
                                              return Container(
                                                height:
                                                    getBlockSize(numberOfRows) *
                                                        combinedBlockHeight,
                                                padding: EdgeInsets.all(0),
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: combinedBlockWidth,
                                                  itemBuilder: (context,
                                                      innerCombinedBlockRow) {
                                                    Block block = Block(
                                                        BlockType.combined,
                                                        null,
                                                        combinedGroupHeight,
                                                        combinedBlockWidth);
                                                    return createCombinedBlock(
                                                        gridSection,
                                                        combinedBlockSection,
                                                        block,
                                                        height: getBlockSize(
                                                                numberOfRows) *
                                                            combinedBlockHeight,
                                                        width: getBlockSize(
                                                                numberOfRows) *
                                                            combinedBlockWidth);
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          //Below the combined block
                                          if (blocksBelowChecked <
                                              numberOfBlocksBelowCombinedBlock) {
                                            blocksBelowChecked++;

                                            return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.all(0),
                                                itemCount:
                                                    numberOfBlocksBelowCombinedBlock,
                                                itemBuilder:
                                                    (context, columnIndex) {
                                                  return Container(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      height: getBlockSize(
                                                          numberOfRows),
                                                      child: ListView.builder(
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              combinedBlockWidth,
                                                          itemBuilder: (context,
                                                              rowIndex) {
                                                            return createSingleBlock(
                                                                getBlockSize(
                                                                    numberOfRows),
                                                                gridPosition:
                                                                    gridSection,
                                                                blockColumn:
                                                                    columnIndex,
                                                                blockRow:
                                                                    rowIndex);
                                                          }));
                                                });
                                          } else {
                                            return Container();
                                          }
                                        }
                                      }
                                    },
                                  ));
                            } else {
                              //Blocks after the combined block
                              if (blocksAfterChecked < numberOfBlocksAfter) {
                                blocksAfterChecked++;

                                return Container(
                                    width: getBlockSize(numberOfRows),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.all(0),
                                        itemCount: combinedGroupHeight,
                                        itemBuilder: (context, columnIndex) {
                                          return Container(
                                              height:
                                                  getBlockSize(numberOfRows),
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: 1,
                                                  itemBuilder:
                                                      (context, rowIndex) {
                                                    return createSingleBlock(
                                                        getBlockSize(
                                                            numberOfRows),
                                                        gridPosition:
                                                            gridSection,
                                                        blockColumn:
                                                            columnIndex,
                                                        blockRow: rowIndex);
                                                  }));
                                        }));
                              } else {
                                return Container();
                              }
                            }
                          }
                        },
                      );
                      //if not on the last combined block
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: totalNumberOfRowsForCombinedBlock,
                        itemBuilder: (context, combinedBlockRowIndex) {
                          //Blocks before the combined block
                          if (blocksBeforeChecked < numberOfBlocksBefore) {
                            blocksBeforeChecked++;

                            return Container(
                                width: getBlockSize(numberOfRows),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: combinedGroupHeight,
                                    itemBuilder: (context, columnIndex) {
                                      return Container(
                                          height: getBlockSize(numberOfRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context, rowIndex) {
                                                return createSingleBlock(
                                                    getBlockSize(numberOfRows),
                                                    gridPosition: gridSection,
                                                    blockColumn: columnIndex,
                                                    blockRow: rowIndex);
                                              }));
                                    }));
                            //Combined block
                          } else {
                            if (!hasCombinedBlockBeingBuilt) {
                              hasCombinedBlockBeingBuilt = true;
                              int blocksAboveChecked = 0;
                              int blocksBelowChecked = 0;
                              bool hasInnerCombinedBlockBeenBuilt = false;

                              return Container(
                                  width: getBlockSize(numberOfRows) *
                                      combinedBlockWidth,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(0),
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: 3,
                                    itemBuilder: (context,
                                        combinedBlockAboveColumnIndex) {
                                      //Empty blocks above
                                      if (blocksAboveChecked <
                                          numberOfBlocksAboveCombinedBlock) {
                                        blocksAboveChecked++;

                                        return ListView.builder(
                                          padding: EdgeInsets.all(0),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              numberOfBlocksAboveCombinedBlock,
                                          itemBuilder: (context, columnIndex) {
                                            return Container(
                                                height:
                                                    getBlockSize(numberOfRows),
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    padding: EdgeInsets.all(0),
                                                    itemCount:
                                                        combinedBlockWidth,
                                                    itemBuilder:
                                                        (context, rowIndex) {
                                                      return createSingleBlock(
                                                          getBlockSize(
                                                              numberOfRows),
                                                          gridPosition:
                                                              gridSection,
                                                          blockColumn:
                                                              columnIndex,
                                                          blockRow: rowIndex);
                                                    }));
                                          },
                                        );
                                      } else {
                                        //Main combined block
                                        if (!hasInnerCombinedBlockBeenBuilt) {
                                          hasInnerCombinedBlockBeenBuilt = true;

                                          return ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: 1,
                                            itemBuilder: (context,
                                                innerCombinedBlockColumn) {
                                              return Container(
                                                height:
                                                    getBlockSize(numberOfRows) *
                                                        combinedBlockHeight,
                                                padding: EdgeInsets.all(0),
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: combinedBlockWidth,
                                                  itemBuilder: (context,
                                                      innerCombinedBlockRow) {
                                                    Block block = Block(
                                                        BlockType.combined,
                                                        null,
                                                        combinedGroupHeight,
                                                        combinedBlockWidth);
                                                    return createCombinedBlock(
                                                        gridSection,
                                                        combinedBlockSection,
                                                        block,
                                                        height: getBlockSize(
                                                                numberOfRows) *
                                                            combinedBlockHeight,
                                                        width: getBlockSize(
                                                                numberOfRows) *
                                                            combinedBlockWidth);
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          //Blocks below the combined block
                                          if (blocksBelowChecked <
                                              numberOfBlocksBelowCombinedBlock) {
                                            blocksBelowChecked++;

                                            return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.all(0),
                                                itemCount:
                                                    numberOfBlocksBelowCombinedBlock,
                                                itemBuilder:
                                                    (context, columnIndex) {
                                                  return Container(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      height: getBlockSize(
                                                          numberOfRows),
                                                      child: ListView.builder(
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              combinedBlockWidth,
                                                          itemBuilder: (context,
                                                              rowIndex) {
                                                            return createSingleBlock(
                                                                getBlockSize(
                                                                    numberOfRows),
                                                                gridPosition:
                                                                    gridSection,
                                                                blockColumn:
                                                                    columnIndex,
                                                                blockRow:
                                                                    rowIndex);
                                                          }));
                                                });
                                          } else {
                                            return Container();
                                          }
                                        }
                                      }
                                    },
                                  ));
                            } else {
                              return Container();
                            }
                          }
                        },
                      );
                    }
                  }));
        });
  }

  @override
  Widget build(BuildContext context) {
    if (this.data != null) {
      if (this.data.length > 0) {
        int gridSectionPosition = 0;

        return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length, //all combined groups
            itemBuilder: (context, combGroupIndex) {
              //This section builds the 3 sections of a combined group.
              //Top part, Main combined blocks and Bottom part
              bool hasAboveBeenBuilt = false;
              bool hasCombinedGroupBeenBuilt = false;
              bool hasBelowBeenBuilt = false;
              gridSectionPosition++;

              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3, //each combined group section
                  // ignore: missing_return
                  itemBuilder: (context, index) {
                    CombinedGroup combinedGroup = data[combGroupIndex];
                    int columnsAbove = combinedGroup.columnsAbove;
                    int columnsBelow = combinedGroup.columnsBelow;
                    // int combinedGroupHeight = combinedGroup.numberOfColumns;
                    int combinedGroupRows = combinedGroup.numberOfRows;
                    //Blocks above
                    if (!hasAboveBeenBuilt) {
                      hasAboveBeenBuilt = true;
                      return createEmptyBlocks(gridSectionPosition, 1,
                          columnsAbove, rows, getBlockSize(rows));
                    } else {
                      //Main combined blocks
                      if (!hasCombinedGroupBeenBuilt) {
                        hasCombinedGroupBeenBuilt = true;
                        if (combinedGroup.combinedGroupType ==
                            CombinedGroupType.SINGLE_COMBINED_GROUP) {
                          CombinedBlockInGroup combinedBlockInGroup =
                              combinedGroup.combinedBlocks[0];
                          Block block = combinedBlockInGroup.block;

                          int emptyRowsBefore =
                              combinedBlockInGroup.numberOfRowsLeft;
                          int emptyRowsAfter =
                              combinedBlockInGroup.numberOfRowsRight;
                          int combinedBlockWidth = block.numberOfRows;
                          int combinedGroupHeight = block.numberOfColumns;
                          return createCombinedGroupWith1CombinedBlock(
                              gridSectionPosition,
                              1,
                              (emptyRowsBefore +
                                  combinedBlockWidth +
                                  emptyRowsAfter),
                              emptyRowsBefore,
                              emptyRowsAfter,
                              combinedBlockWidth,
                              combinedGroupHeight);
                        } else if (combinedGroup.combinedGroupType ==
                            CombinedGroupType
                                .MULITPLE_COMBINED_GROUP_SAME_HEIGHT) {
                          int combinedGroupHeight =
                              combinedGroup.numberOfColumns;
                          List<List> combinedBlocksList = [];

                          for (CombinedBlockInGroup combinedBlockInGroup
                              in combinedGroup.combinedBlocks) {
                            Block block = combinedBlockInGroup.block;

                            int combinedBlockWidth = block.numberOfRows;
                            int rowsBeforeBlock =
                                combinedBlockInGroup.numberOfRowsLeft;
                            int rowsAfterBlock =
                                combinedBlockInGroup.numberOfRowsRight;

                            combinedBlocksList.add([
                              combinedBlockWidth,
                              rowsBeforeBlock,
                              rowsAfterBlock,
                            ]);
                          }

                          return createCombinedGroupWithMultipleCombinedBlocks(
                              gridSectionPosition,
                              combinedGroupRows,
                              combinedGroupHeight,
                              combinedBlocksList);
                        } else if (combinedGroup.combinedGroupType ==
                            CombinedGroupType
                                .MULTIPLE_COMBINED_GROUP_DIFF_HEIGHT) {
                          int combinedGroupHeight =
                              combinedGroup.numberOfColumns;
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
                              columnsBelowBlock
                            ]);
                          }
                          return createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
                              gridSectionPosition,
                              combinedGroupRows,
                              combinedGroupHeight,
                              combinedBlocksList);
                        }
                      } else {
                        //Blocks below
                        if (!hasBelowBeenBuilt) {
                          hasBelowBeenBuilt = true;
                          return createEmptyBlocks(gridSectionPosition, 3,
                              columnsBelow, rows, getBlockSize(rows));
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
    } else {
      return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Center(
            child: Text("No data"),
          ));
    }
  }
}

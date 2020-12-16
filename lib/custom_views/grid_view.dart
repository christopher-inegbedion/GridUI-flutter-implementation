import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:grid_ui_implementation/models/grid_content.dart';

class GridUIView extends StatefulWidget {
  final int rows;
  final int columns;
  final List<GridContent> gridContent;

  GridUIView(this.columns, this.rows, this.gridContent);

  @override
  _GridUIViewState createState() =>
      _GridUIViewState(columns, rows, gridContent);
}

class _GridUIViewState extends State<GridUIView> {
  int columns;
  int rows;
  List<GridContent> gridContent;

  int currentIndex = 0;

  _GridUIViewState(this.columns, this.rows, this.gridContent);

  ///Returns the actual size of a block
  double getBlockSize(int rows) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / rows;
  }

  ///Return a grid block
  Widget createGridBlock(int rows) {
    double blockSize = getBlockSize(rows);

    return Container(
      height: blockSize,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: rows,
        itemBuilder: (context, rowIndex) {
          return Container(
            width: blockSize,
            child: Center(
              child: Icon(Icons.add, color: Colors.white),
            ),
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2)),
          );
        },
      ),
    );
  }

  ///Return a combined block
  Widget createGridCombinedBlock(
      int rows, int combinedBlockWidth, double combinedBlockHeight) {
    return Draggable(
      child: Container(
        width: getBlockSize(rows) * combinedBlockWidth,
        decoration: BoxDecoration(
            color: Colors.orange,
            border: Border.all(color: Colors.white, width: 2)),
      ),
      feedback: Container(
        height: getBlockSize(rows) * combinedBlockHeight,
        width: getBlockSize(rows) * combinedBlockWidth,
        decoration: BoxDecoration(
            color: Colors.orange,
            border: Border.all(color: Colors.white, width: 2)),
      ),
      childWhenDragging: Container(
        width: getBlockSize(rows) * combinedBlockWidth,
        decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.white, width: 2)),
      ),
    );
  }

  ///Creates empty blocks above/below combined group
  Widget createEmptyBlocks(int columns, int rows, double blockSize) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: columns,
      itemBuilder: (context, columnIndex) {
        return createGridBlock(rows);
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
  Widget createCombinedGroupWith1CombinedBlock(int emptyRowsBefore,
      int emptyRowsAfter, int combinedBlockWidth, int combinedGroupHeight) {
    int blocksBeforeChecked = 0;
    int blocksAfterChecked = 0;
    bool hasCombinedBlockBeingBuilt = false;
    int rows = emptyRowsBefore + combinedBlockWidth + emptyRowsAfter;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      itemCount: 1,
      itemBuilder: (context, columnIndex) {
        /*======================
         * COMBINED BLOCK COLUMN
         * ---------------------
         =======================*/
        return Container(
            height: getBlockSize(rows) * double.parse("$combinedGroupHeight"),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rows - (combinedBlockWidth - 1),
              itemBuilder: (context, rowIndex) {
                /*====================
                 * EMPTY BLOCKS BEFORE
                 * -------------------
                 =====================*/
                if (blocksBeforeChecked < emptyRowsBefore) {
                  blocksBeforeChecked++;

                  /*==================================================
                   * EACH ROW
                   * --------
                   * 
                   * Each entry results in a block created (Height is
                   * inherited from parent Container)
                   ==================================================*/
                  return Container(
                      width: getBlockSize(rows),
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          itemCount: combinedGroupHeight,
                          itemBuilder:
                              (context, blocksBeforeCombinedBlockColumnIndex) {
                            /*===========
                            * EACH COLUMN
                            * -----------
                            =============*/
                            return createGridBlock(rows);
                          }));
                } else {
                  /*===============
                   * COMBINED BLOCK
                   * --------------
                   ================*/
                  if (!hasCombinedBlockBeingBuilt) {
                    hasCombinedBlockBeingBuilt = true;

                    /*==================================================
                    * COMBINED BLOCK WIDTH
                    * ---------------------
                    * 
                    * (Height is inherited from parent Container)
                    ==================================================*/
                    return createGridCombinedBlock(rows, combinedBlockWidth,
                        double.parse("$combinedGroupHeight"));
                  } else {
                    /*===================
                     * EMPTY BLOCKS AFTER
                     * ------------------
                     ====================*/
                    if (blocksAfterChecked < emptyRowsAfter) {
                      blocksAfterChecked++;

                      /*==================================================
                      * EACH ROW
                      * --------
                      * 
                      * Each entry results in a block created (Height is
                      * inherited from parent Container)
                      ==================================================*/
                      return Container(
                          width: getBlockSize(rows),
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(0),
                              itemCount: combinedGroupHeight,
                              itemBuilder: (context,
                                  blocksAfterCombinedBlockColumnIndex) {
                                /*============
                                * EACH COLUMN
                                * ------------
                                =============*/
                                return createGridBlock(rows);
                              }));
                    } else {
                      return Container();
                    }
                  }
                }
              },
            ));
      },
    );
  }

  ///Create a combined group with 2 or more combined blocks
  ///
  ///Height of the combined group is set with the [combinedGroupHeight] param, and
  ///the combined blocks are set with the [combinedBlocks] param
  ///
  ///Example of a combined block: Combined block with width of 2, 3 blocks before, 2 blocks after = [2, 3, 2]
  ///
  Widget createCombinedGrouWithMultipleCombinedBlocks(
      int totalNumberOfIndividualRows,
      int combinedGroupHeight,
      List<List> combinedBlocks) {
    //A single block is the intersection of a column container and row container
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (context, columnIndex) {
          return Container(
              height: getBlockSize(totalNumberOfIndividualRows) *
                  combinedGroupHeight,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  itemCount: combinedBlocks.length,
                  itemBuilder: (context, rowIndex) {
                    int rowsBeforeChecked = 0;
                    int rowsAfterChecked = 0;
                    bool hasCombinedBlockBeenBuilt = false;

                    int numberOfRowsBefore = combinedBlocks[rowIndex][1];
                    int numberOfRowsAfter = combinedBlocks[rowIndex][2];
                    int combinedBlockWidth = combinedBlocks[rowIndex][0];
                    int totalNumberOfRowsForCombinedBlock = numberOfRowsBefore +
                        combinedBlockWidth +
                        numberOfRowsAfter;

                    if (rowIndex == (combinedBlocks.length - 1)) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: totalNumberOfRowsForCombinedBlock,
                        itemBuilder: (context, combinedBlockRowIndex) {
                          if (rowsBeforeChecked < numberOfRowsBefore) {
                            rowsBeforeChecked++;

                            return Container(
                                width:
                                    getBlockSize(totalNumberOfIndividualRows),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: combinedGroupHeight,
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockColumnIndex) {
                                      return createGridBlock(rows);
                                    }));
                          } else {
                            if (!hasCombinedBlockBeenBuilt) {
                              hasCombinedBlockBeenBuilt = true;

                              return createGridCombinedBlock(
                                  rows,
                                  combinedBlockWidth,
                                  double.parse("$combinedGroupHeight"));
                            } else {
                              if (rowsAfterChecked < numberOfRowsAfter) {
                                rowsAfterChecked++;

                                return Container(
                                    width: getBlockSize(
                                        totalNumberOfIndividualRows),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.all(0),
                                        itemCount: combinedGroupHeight,
                                        itemBuilder: (context,
                                            blocksAfterCombinedBlockColumnIndex) {
                                          return createGridBlock(rows);
                                        }));
                              } else {
                                return Container();
                              }
                            }
                          }
                        },
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: totalNumberOfRowsForCombinedBlock,
                        itemBuilder: (context, combinedBlockRowIndex) {
                          if (rowsBeforeChecked < numberOfRowsBefore) {
                            rowsBeforeChecked++;

                            return Container(
                                width:
                                    getBlockSize(totalNumberOfIndividualRows),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: combinedGroupHeight,
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockColumnIndex) {
                                      return createGridBlock(rows);
                                    }));
                          } else {
                            if (!hasCombinedBlockBeenBuilt) {
                              hasCombinedBlockBeenBuilt = true;

                              return createGridCombinedBlock(
                                  rows,
                                  combinedBlockWidth,
                                  double.parse("$combinedGroupHeight"));
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

  ///Creates a combined group with 2 or more combined blocks with different heights
  ///
  ///Combined block structure
  ///------------------------
  ///Example: Combined block with height of 2, width of 2, 3 blocks before, 2 blocks after, 1 block above, 2 blocks below  = [2, 2, 3, 2, 1, 2]
  ///
  Widget createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
      int numberOfRows, int combinedGroupHeight, List<List> combinedBlocks) {
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

                    if (rowIndex == (combinedBlocks.length - 1)) {
                      return ListView.builder(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: totalNumberOfRowsForCombinedBlock,
                        itemBuilder: (context, combinedBlockRowIndex) {
                          if (blocksBeforeChecked < numberOfBlocksBefore) {
                            blocksBeforeChecked++;

                            return Container(
                                width: getBlockSize(numberOfRows),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: combinedGroupHeight,
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockColumnIndex) {
                                      return createGridBlock(rows);
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
                                            return createGridBlock(rows);
                                          },
                                        );
                                      } else {
                                        if (!hasInnerCombinedBlockBeenBuilt) {
                                          hasInnerCombinedBlockBeenBuilt = true;

                                          return createGridCombinedBlock(
                                              rows,
                                              combinedBlockWidth,
                                              double.parse(
                                                  "$combinedGroupHeight"));
                                        } else {
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
                                                itemBuilder: (context,
                                                    blocksBelowCombinedBlockColumnIndex) {
                                                  return createGridBlock(rows);
                                                });
                                          } else {
                                            return Container();
                                          }
                                        }
                                      }
                                    },
                                  ));
                            } else {
                              if (blocksAfterChecked < numberOfBlocksAfter) {
                                blocksAfterChecked++;

                                return Container(
                                    width: getBlockSize(numberOfRows),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.all(0),
                                        itemCount: combinedGroupHeight,
                                        itemBuilder: (context,
                                            blocksAfterCombinedBlockColumnIndex) {
                                          return createGridBlock(rows);
                                        }));
                              } else {
                                return Container();
                              }
                            }
                          }
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: totalNumberOfRowsForCombinedBlock,
                        itemBuilder: (context, combinedBlockRowIndex) {
                          if (blocksBeforeChecked < numberOfBlocksBefore) {
                            blocksBeforeChecked++;

                            return Container(
                                width: getBlockSize(numberOfRows),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: combinedGroupHeight,
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockColumnIndex) {
                                      return createGridBlock(rows);
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
                                            return createGridBlock(rows);
                                          },
                                        );
                                      } else {
                                        if (!hasInnerCombinedBlockBeenBuilt) {
                                          hasInnerCombinedBlockBeenBuilt = true;

                                          return createGridCombinedBlock(
                                              rows,
                                              combinedBlockWidth,
                                              double.parse(
                                                  "$combinedGroupHeight"));
                                        } else {
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
                                                itemBuilder: (context,
                                                    blocksBelowCombinedBlockColumnIndex) {
                                                  return createGridBlock(rows);
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
    if (this.gridContent != null) {
      if (this.gridContent.length > 0) {
        bool hasAboveBeenBuilt = false;
        bool hasCombinedGroupBeenBuilt = false;
        bool hasBelowBeenBuilt = false;

        print(currentIndex);

        return SingleChildScrollView(
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: gridContent.length * 4,
              itemBuilder: (context, index) {
                int columnsAbove = gridContent[currentIndex].columnsAbove;
                int columnsBelow = gridContent[currentIndex].columnsBelow;
                int combinedGroupHeight =
                    gridContent[currentIndex].combinedGroup.numberOfColumns;
                CombinedGroup combinedGroup =
                    gridContent[currentIndex].combinedGroup;
                int combinedGroupRows = combinedGroup.numberOfRows;

                if (!hasAboveBeenBuilt) {
                  hasAboveBeenBuilt = true;
                  return createEmptyBlocks(
                      columnsAbove, rows, getBlockSize(this.rows));
                }

                if (!hasCombinedGroupBeenBuilt) {
                  hasCombinedGroupBeenBuilt = true;
                  if (combinedGroup.combinedGroupType ==
                      CombinedGroupType.SINGLE_COMBINED_GROUP) {
                    CombinedBlockInGroup combinedBlockInGroup =
                        combinedGroup.combinedBlocks[0];
                    Block block = combinedBlockInGroup.block;

                    int emptyRowsBefore = combinedBlockInGroup.numberOfRowsLeft;
                    int emptyRowsAfter = combinedBlockInGroup.numberOfRowsRight;
                    int combinedBlockWidth = block.numberOfRows;
                    int combinedGroupHeight = block.numberOfColumns;
                    return createCombinedGroupWith1CombinedBlock(
                        emptyRowsBefore,
                        emptyRowsAfter,
                        combinedBlockWidth,
                        combinedGroupHeight);
                  } else if (combinedGroup.combinedGroupType ==
                      CombinedGroupType.MULITPLE_COMBINED_GROUP_SAME_HEIGHT) {
                    int combinedGroupHeight = combinedGroup.numberOfColumns;
                    List<List> combinedBlocksList = [];

                    for (CombinedBlockInGroup combinedBlockInGroup
                        in combinedGroup.combinedBlocks) {
                      Block block = combinedBlockInGroup.block;

                      int combinedBlockWidth = block.numberOfRows;
                      int rowsBeforeBlock =
                          combinedBlockInGroup.numberOfRowsLeft;
                      int rowsAfterBlock =
                          combinedBlockInGroup.numberOfRowsRight;

                      print(rowsAfterBlock);
                      combinedBlocksList.add([
                        combinedBlockWidth,
                        rowsBeforeBlock,
                        rowsAfterBlock,
                      ]);
                    }

                    return createCombinedGrouWithMultipleCombinedBlocks(
                        combinedGroupRows,
                        combinedGroupHeight,
                        combinedBlocksList);
                  } else if (combinedGroup.combinedGroupType ==
                      CombinedGroupType.MULTIPLE_COMBINED_GROUP_DIFF_HEIGHT) {
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
                        columnsBelowBlock
                      ]);
                    }
                    return createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
                        combinedGroupRows,
                        combinedGroupHeight,
                        combinedBlocksList);
                  }
                }

                if (!hasBelowBeenBuilt) {
                  hasBelowBeenBuilt = true;
                  //====Build blocks below====
                  return createEmptyBlocks(
                      columnsBelow, rows, getBlockSize(this.rows));

                  //====END====
                } else {
                  //reset
                  if (currentIndex != gridContent.length - 1) {
                    currentIndex++;
                  }

                  hasAboveBeenBuilt = false;
                  hasCombinedGroupBeenBuilt = false;
                  hasBelowBeenBuilt = false;

                  return Container();
                }
              }),
        );
      } else {
        return ListView.builder(
          itemCount: this.columns,
          itemBuilder: (context, index) {
            return createEmptyBlocks(1, this.rows, getBlockSize(this.rows));
          },
        );
      }
    } else {
      return ListView.builder(
        itemCount: this.columns,
        itemBuilder: (context, index) {
          return createEmptyBlocks(1, this.rows, getBlockSize(this.rows));
        },
      );
    }
  }
}

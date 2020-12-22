import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';

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

  void change(int cols) {
    state.change(cols);
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

  void change(int colsChange) {
    setState(() {
      columns = colsChange;
    });
  }

  ///Creates a single block
  Widget createSingleBlock(double blockSize,
      [int gridPosition, int blockColumns, int blockRow]) {
    bool dropped = false;
    return DragTarget(
      builder: (context, List<String> candidateData, rejectedData) {
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
      onWillAccept: (data) {
        print(
            "hovering at grid position: $gridPosition, block column $blockColumns, block row $blockRow");
        return false;
      },
    );
  }

  ///Create a combined block
  Widget createCombinedBlock({double height = 0.0, double width}) {
    double numberOfColumns = height / getBlockSize(rows);
    double numberOfRows = width / getBlockSize(rows);
    print(numberOfRows);
    int blockQuadrant =
        0; //stores the value of the quadrant from which the user began dragging the combined block

    return Draggable(
      data: "data",
      child: Container(
          width: width,
          decoration: BoxDecoration(
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2)),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.add, color: Colors.white),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: numberOfColumns.toInt(),
                  itemBuilder: (context, colIndex) {
                    return Container(
                        height: getBlockSize(rows),
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: numberOfRows.toInt(),
                            itemBuilder: (context, rowIndex) {
                              return GestureDetector(
                                onTapDown: (details) {
                                  if (numberOfRows > 1) {
                                    if (colIndex != 0) {
                                      //if the user is not holding a quadrant from the first column
                                      blockQuadrant =
                                          colIndex + colIndex + rowIndex + 1;
                                      print(
                                          "quadrant ${colIndex + colIndex + rowIndex + 1}");
                                    } else {
                                      blockQuadrant = rowIndex + 1;
                                      print("quadrant ${rowIndex + 1}");
                                    }
                                  } else {
                                    blockQuadrant = colIndex + 1;
                                    print("quadrant ${colIndex + 1}");
                                  }
                                },
                                child: Container(
                                  width: getBlockSize(rows),
                                  height: getBlockSize(rows),
                                  decoration: BoxDecoration(color: null),
                                ),
                              );
                            }));
                  })
            ],
          )),
      feedback: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Colors.orange,
            border: Border.all(color: Colors.white, width: 2)),
        child: Center(
          child: Icon(Icons.add, color: Colors.white),
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
  Widget createEmptyBlocks(
      int gridSection, int columns, int rows, double blockSize) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: columns,
      itemBuilder: (context, columnIndex) {
        print(gridSection);

        // print("here");
        return Container(
          height: blockSize,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: rows,
            itemBuilder: (context, rowIndex) {
              return createSingleBlock(
                  blockSize, gridSection, columnIndex + 1, rowIndex + 1);
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
      int totalRows,
      int emptyRowsBefore,
      int emptyRowsAfter,
      int combinedBlockWidth,
      int combinedGroupHeight) {
    bool hasEmptyBlocksBeforeBeingBuilt = false;
    bool hasCombinedBlockBeingBuilt = false;
    // int totalRows = emptyRowsBefore + combinedBlockWidth + emptyRowsAfter;

    return Container(
        height: getBlockSize(totalRows) * combinedGroupHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              3, //each combined group section(blocks before|comb. block|blocks after)
          itemBuilder: (context, rowIndex) {
            /*====================
             * Build each combined group section (i.e the empty blocks before, the combined block and the empty blocks after)
             =====================*/

            /* ======================================
             * EMPTY BLOCKS BEFORE THE COMBINED BLOCK
             ========================================*/
            if (!hasEmptyBlocksBeforeBeingBuilt) {
              hasEmptyBlocksBeforeBeingBuilt = true;

              /*==================================================
              * EACH ROW
              * --------
              * 
              * Each entry results in a block created (Height is
              * inherited from parent Container)
              ==================================================*/
              return Container(
                width: getBlockSize(totalRows) * emptyRowsBefore,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount:
                        combinedGroupHeight, //Each column before the combined block
                    itemBuilder:
                        (context, blocksBeforeCombinedBlockColumnIndex) {
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
                          itemBuilder: (context, blocksBeforeBlocks) {
                            return Container(
                              width: getBlockSize(totalRows),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                              child: Center(
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            );
                          },
                        ),
                      );
                    }),
              );
            } else {
              /*===============
               * COMBINED BLOCK
               * --------------
               ================*/
              if (!hasCombinedBlockBeingBuilt) {
                hasCombinedBlockBeingBuilt = true;
                return createCombinedBlock(
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
                      itemBuilder:
                          (context, blocksAfterCombinedBlockColumnIndex) {
                        return Container(
                          height: getBlockSize(totalRows),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: emptyRowsAfter,
                            itemBuilder: (context, blocksAfterBlocks) {
                              return createSingleBlock(getBlockSize(totalRows));
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
      int totalNumberOfIndividualRows,
      int combinedGroupHeight,
      List<List> combinedBlocks) {
    return Container(
      height: getBlockSize(totalNumberOfIndividualRows) * combinedGroupHeight,
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: combinedBlocks.length,
          itemBuilder: (context, combinedBlockBlockIndex) {
            int numberOfRowsBefore = combinedBlocks[combinedBlockBlockIndex][1];
            int numberOfRowsAfter = combinedBlocks[combinedBlockBlockIndex][2];
            int combinedBlockWidth = combinedBlocks[combinedBlockBlockIndex][0];
            int totalNumberOfRowsForCombinedBlock =
                numberOfRowsBefore + combinedBlockWidth + numberOfRowsAfter;

            return Container(
              width: getBlockSize(totalNumberOfIndividualRows) *
                  totalNumberOfRowsForCombinedBlock,
              child: createCombinedGroupWith1CombinedBlock(
                  totalNumberOfIndividualRows,
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
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockColumnIndex) {
                                      return Container(
                                          height: getBlockSize(numberOfRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context,
                                                  blocksBeforeCombinedBlockRowIndex) {
                                                return createSingleBlock(
                                                    getBlockSize(numberOfRows));
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
                                                              numberOfRows));
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
                                                    return createCombinedBlock(
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
                                                itemBuilder: (context,
                                                    blocksBelowCombinedBlockColumnIndex) {
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
                                                              blocksBelowCombinedBlockRowIndex) {
                                                            return createSingleBlock(
                                                                getBlockSize(
                                                                    numberOfRows));
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
                                        itemBuilder: (context,
                                            blocksAfterCombinedBlockColumnIndex) {
                                          return Container(
                                              height:
                                                  getBlockSize(numberOfRows),
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: 1,
                                                  itemBuilder: (context,
                                                      blocksAfterCombinedBlockRowIndex) {
                                                    return createSingleBlock(
                                                        getBlockSize(
                                                            numberOfRows));
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
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockColumnIndex) {
                                      return Container(
                                          height: getBlockSize(numberOfRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context,
                                                  blocksBeforeCombinedBlockRowIndex) {
                                                return createSingleBlock(
                                                    getBlockSize(numberOfRows));
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
                                                              numberOfRows));
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
                                                    return createCombinedBlock(
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
                                                itemBuilder: (context,
                                                    blocksBelowCombinedBlockColumnIndex) {
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
                                                              blocksBelowCombinedBlockRowIndex) {
                                                            return createSingleBlock(
                                                                getBlockSize(
                                                                    numberOfRows));
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

        return SingleChildScrollView(
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length, //all combined groups
              itemBuilder: (context, combGroupIndex) {
                //This section builds the 3 sections of a combined group.
                //Top part, Main combined blocks and Bottom part
                bool hasAboveBeenBuilt = false;
                bool hasCombinedGroupBeenBuilt = false;
                bool hasBelowBeenBuilt = false;

                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3, //each combined group section
                    itemBuilder: (context, index) {
                      gridSectionPosition++;

                      CombinedGroup combinedGroup = data[combGroupIndex];
                      int columnsAbove = combinedGroup.columnsAbove;
                      int columnsBelow = combinedGroup.columnsBelow;
                      // int combinedGroupHeight = combinedGroup.numberOfColumns;
                      int combinedGroupRows = combinedGroup.numberOfRows;

                      //Blocks bove
                      if (!hasAboveBeenBuilt) {
                        hasAboveBeenBuilt = true;
                        return createEmptyBlocks(gridSectionPosition,
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
                                combinedGroupRows,
                                combinedGroupHeight,
                                combinedBlocksList);
                          }
                        } else {
                          //Blocks below
                          if (!hasBelowBeenBuilt) {
                            hasBelowBeenBuilt = true;
                            return createEmptyBlocks(gridSectionPosition,
                                columnsBelow, rows, getBlockSize(rows));
                          }
                        }
                      }
                    });
              }),
        );
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

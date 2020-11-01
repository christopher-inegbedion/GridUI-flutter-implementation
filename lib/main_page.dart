import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  ///Returns the actual size of a block
  double getBlockSize(int rows) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth / rows;
  }

  ///Creates empty blocks above/below combined group
  Widget createEmptyBlocks(int columns, int rows, double blockSize) {
    return ListView.builder(
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
                            return Container(
                                height: getBlockSize(rows),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 1,
                                    itemBuilder: (context,
                                        blocksBeforeCombinedBlockRowIndex) {
                                      /*==================================================
                                      * EACH ROW
                                      * --------
                                      * 
                                      * Each entry results in a block created (Height is
                                      * inherited from parent Container)
                                      ==================================================*/
                                      return Container(
                                        width: getBlockSize(rows),
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            border: Border.all(
                                                color: Colors.white, width: 2)),
                                        child: Center(
                                          child: Icon(Icons.add,
                                              color: Colors.white),
                                        ),
                                      );
                                    }));
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
                    return Container(
                      width: getBlockSize(rows) * combinedBlockWidth,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: Center(
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    );
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
                                return Container(
                                    height: getBlockSize(rows),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 1,
                                        itemBuilder: (context,
                                            blocksAfterCombinedBlockRowIndex) {
                                          return Container(
                                            width: getBlockSize(rows),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2)),
                                            child: Center(
                                              child: Icon(Icons.add,
                                                  color: Colors.white),
                                            ),
                                          );
                                        }));
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
      int combinedGroupHeight, List<List> combinedBlocks) {
    //Represents the total number of individual rows in a combined group. Each combined
    //block counts as 1 individual row
    int totalNumberOfIndividualRows = 0;

    for (int i = 0; i < combinedBlocks.length; i++) {
      //Rows to the right are not counted towards the overall sum, except it is the last
      //combined block
      if (i == (combinedBlocks.length - 1)) {
        int combinedBlockCombinedNumberOfRows =
            combinedBlocks[i][0] + combinedBlocks[i][1];
        totalNumberOfIndividualRows += combinedBlockCombinedNumberOfRows;
      } else {
        int combinedBlockCombinedNumberOfRows =
            combinedBlocks[i][0] + combinedBlocks[i][1] + combinedBlocks[i][2];
        totalNumberOfIndividualRows += combinedBlockCombinedNumberOfRows;
      }
    }

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
                                      return Container(
                                          height: getBlockSize(
                                              totalNumberOfIndividualRows),
                                          child: ListView.builder(
                                              padding: EdgeInsets.all(0),
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context,
                                                  blocksBeforeCombinedBlockRowIndex) {
                                                return Container(
                                                  width: getBlockSize(
                                                      totalNumberOfIndividualRows),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: Center(
                                                    child: Icon(Icons.add,
                                                        color: Colors.white),
                                                  ),
                                                );
                                              }));
                                    }));
                          } else {
                            if (!hasCombinedBlockBeenBuilt) {
                              hasCombinedBlockBeenBuilt = true;

                              return Container(
                                width:
                                    getBlockSize(totalNumberOfIndividualRows) *
                                        combinedBlockWidth,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: Center(
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              );
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
                                          return Container(
                                              height: getBlockSize(
                                                  totalNumberOfIndividualRows),
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: 1,
                                                  itemBuilder: (context,
                                                      blocksAfterCombinedBlockRowIndex) {
                                                    return Container(
                                                      width: getBlockSize(
                                                          totalNumberOfIndividualRows),
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2)),
                                                      child: Center(
                                                        child: Icon(Icons.add,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    );
                                                  }));
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
                                      return Container(
                                          height: getBlockSize(
                                              totalNumberOfIndividualRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context,
                                                  blocksBeforeCombinedBlockRowIndex) {
                                                return Container(
                                                  width: getBlockSize(
                                                      totalNumberOfIndividualRows),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: Center(
                                                    child: Icon(Icons.add,
                                                        color: Colors.white),
                                                  ),
                                                );
                                              }));
                                    }));
                          } else {
                            if (!hasCombinedBlockBeenBuilt) {
                              hasCombinedBlockBeenBuilt = true;

                              return Container(
                                width:
                                    getBlockSize(totalNumberOfIndividualRows) *
                                        combinedBlockWidth,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: Center(
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              );
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

  //Creates a combined group with 2 or more combined blocks with different heights
  /*
   * Combined block structure
   * ------------------------
   * Example: Combined block with height of 2, width of 2, 3 blocks before, 2 blocks after, 1 block above, 2 blocks below  = [2, 2, 3, 2, 1, 2]
   * */
  Widget createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(
      int combinedGroupHeight, List<List> combinedBlocks) {
    int numberOfRows = 0;

    for (int i = 0; i < combinedBlocks.length; i++) {
      if (i == (combinedBlocks.length - 1)) {
        int combinedBlockWidth = combinedBlocks[i][1];
        int numberOfBlocksBefore = combinedBlocks[i][2];
        int numberOfBlocksAfter = combinedBlocks[i][3];

        numberOfRows +=
            combinedBlockWidth + numberOfBlocksBefore + numberOfBlocksAfter;
      } else {
        int combinedBlockWidth = combinedBlocks[i][1];
        int numberOfBlocksBefore = combinedBlocks[i][2];
        int numberOfBlocksAfter = combinedBlocks[i][3];

        numberOfRows +=
            combinedBlockWidth + numberOfBlocksBefore + numberOfBlocksAfter;
      }
    }

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (context, columnIndex) {
          return Container(
              height: getBlockSize(numberOfRows) *
                  double.parse("$combinedGroupHeight"),
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
                                      return Container(
                                          height: getBlockSize(numberOfRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context,
                                                  blocksBeforeCombinedBlockRowIndex) {
                                                return Container(
                                                  width: getBlockSize(
                                                      numberOfRows),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: Center(
                                                    child: Icon(Icons.add,
                                                        color: Colors.white),
                                                  ),
                                                );
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
                                                      return Container(
                                                        width: getBlockSize(
                                                            numberOfRows),
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2)),
                                                        child: Center(
                                                          child: Icon(Icons.add,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      );
                                                    }));
                                          },
                                        );
                                      } else {
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
                                                    return Container(
                                                      width: getBlockSize(
                                                              numberOfRows) *
                                                          combinedBlockWidth,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2)),
                                                      child: Center(
                                                        child: Icon(Icons.add,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
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
                                                            return Container(
                                                              width: getBlockSize(
                                                                  numberOfRows),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .white,
                                                                      width:
                                                                          2)),
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            );
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
                                                    return Container(
                                                      width: getBlockSize(
                                                          numberOfRows),
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2)),
                                                      child: Center(
                                                        child: Icon(Icons.add,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    );
                                                  }));
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
                                      return Container(
                                          height: getBlockSize(numberOfRows),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 1,
                                              itemBuilder: (context,
                                                  blocksBeforeCombinedBlockRowIndex) {
                                                return Container(
                                                  width: getBlockSize(
                                                      numberOfRows),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: Center(
                                                    child: Icon(Icons.add,
                                                        color: Colors.white),
                                                  ),
                                                );
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
                                                      return Container(
                                                        width: getBlockSize(
                                                            numberOfRows),
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2)),
                                                        child: Center(
                                                          child: Icon(Icons.add,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      );
                                                    }));
                                          },
                                        );
                                      } else {
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
                                                    return Container(
                                                      width: getBlockSize(
                                                              numberOfRows) *
                                                          combinedBlockWidth,
                                                      decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2)),
                                                      child: Center(
                                                        child: Icon(Icons.add,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
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
                                                            return Container(
                                                              width: getBlockSize(
                                                                  numberOfRows),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .white,
                                                                      width:
                                                                          2)),
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            );
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              createCombinedGroupWithMultipleCombinedBlocksOfDiffHeight(4, [
                [2, 1, 1, 0, 1, 1],
                [4, 1, 1, 2, 0, 0],
              ]),
              createEmptyBlocks(1, 6, getBlockSize(6)),
              createCombinedGrouWithMultipleCombinedBlocks(3, [
                [1, 1, 0],
                [1, 1, 0],
                [2, 0, 0]
              ]),
              createEmptyBlocks(1, 6, getBlockSize(6)),
              createCombinedGroupWith1CombinedBlock(2, 2, 2, 1),
              createEmptyBlocks(2, 6, getBlockSize(6)),
              createCombinedGroupWith1CombinedBlock(1, 1, 4, 2),
              createEmptyBlocks(2, 6, getBlockSize(6)),
            ],
          ),
        ),
      ),
    );
  }
}

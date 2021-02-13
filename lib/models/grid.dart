import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';

class Grid {
  static Grid instance;

  int gridColumns;
  int gridRows;
  List<CombinedGroup> combinedGroups;
  bool editMode = false;

  Grid._();

  static Grid getInstance() {
    if (instance == null) instance = Grid._();

    return instance;
  }

  ///Load the grid's data from JSON file
  Future<Grid> loadJSON(String path,
      {bool fromNetwork = false, String grid}) async {
    Map<String, dynamic> gridJSON;
    if (fromNetwork) {
      gridJSON = jsonDecode(grid);
    } else {
      gridJSON = await parseJsonFromAssets(path);
    }

    ///Number of columns in the grid
    this.gridColumns = gridJSON["grid_columns"];

    ///Number or rows in the grid
    this.gridRows = gridJSON["grid_rows"];

    ///All combined groups in the grid
    this.combinedGroups = [];
    // print("${gridJSON["combined_groups"]}");

    ///Create each combined group object and asign each to [combinedGroups]
    for (Map<String, dynamic> combinedGroupFromJSON
        in gridJSON["combined_groups"]) {
      List<CombinedBlockInGroup> allCombinedGroups = [];

      ///Create each combined group's combined block
      for (Map<String, dynamic> combinedBlocks
          in combinedGroupFromJSON["combined_blocks"]) {
        Block block = new Block(
          BlockType.combined,
          combinedBlocks["block"]["content"],
          combinedBlocks["block"]["number_of_rows"],
          combinedBlocks["block"]["number_of_columns"],
        );

        CombinedBlockInGroup combinedBlockInGroup = new CombinedBlockInGroup(
            combinedBlocks["number_of_rows_left"],
            combinedBlocks["number_of_rows_right"],
            combinedBlocks["number_of_columns_above"],
            combinedBlocks["number_of_columns_below"],
            combinedBlocks["position_in_combined_group"],
            block);

        allCombinedGroups.add(combinedBlockInGroup);
      }

      CombinedGroup combinedGroup = new CombinedGroup(
          convertFromStringToCombinedGroupType(
              combinedGroupFromJSON["combined_group_type"]),
          combinedGroupFromJSON["columns_above"],
          combinedGroupFromJSON["columns_below"],
          combinedGroupFromJSON["number_of_columns"],
          combinedGroupFromJSON["number_of_rows"],
          allCombinedGroups);

      combinedGroups.add(combinedGroup);
    }

    return getInstance();
  }

  Future<GridUIView> initGridView(path) async {
    Grid grid = await loadJSON(path);
    this.gridColumns = grid.gridColumns;
    this.gridRows = grid.gridRows;
    this.combinedGroups = grid.combinedGroups;

    return GridUIView(grid.gridColumns, grid.gridRows, grid.combinedGroups);
  }

  CombinedGroupType convertFromStringToCombinedGroupType(String type) {
    if (type == "SINGLE_COMBINED_GROUP")
      return CombinedGroupType.SINGLE_COMBINED_GROUP;
    if (type == "MULTIPLE_COMBINED_GROUP_SAME_HEIGHT")
      return CombinedGroupType.MULITPLE_COMBINED_GROUP_SAME_HEIGHT;
    if (type == "MULTIPLE_COMBINED_GROUP_DIFF_HEIGHT")
      return CombinedGroupType.MULTIPLE_COMBINED_GROUP_DIFF_HEIGHT;

    return null;
  }

  Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
    print('--- Parse json from: $assetsPath');
    return rootBundle
        .loadString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  Map<String, dynamic> toJSON(Grid grid) {
    return {
      "gridColumns": gridColumns,
      "gridRows": gridRows,
      "combinedGroups": combinedGroups
    };
  }

  CombinedGroup getSpecificCombinedGroup(int index) {
    return combinedGroups[index - 1];
  }

  CombinedBlockInGroup getSpecificCombinedBlockInGroup(
      int index, CombinedGroup combinedGroup) {
    return combinedGroup.combinedBlocks[index - 1];
  }

  Block getSpecificBlock(CombinedBlockInGroup blockInGroup) {
    return blockInGroup.block;
  }

  int getNumberOfRowsBeforeCombinedBlock(
      int blockIndex, int combinedGroupIndex) {
    CombinedGroup combinedGroup = getSpecificCombinedGroup(combinedGroupIndex);
    CombinedBlockInGroup combinedBlockInGroup =
        getSpecificCombinedBlockInGroup(blockIndex, combinedGroup);
    Block block = combinedBlockInGroup.block;
    int totalCombinedGroupNumberOfRows = combinedGroup.numberOfRows;
    int combinedBlockWidth = block.numberOfRows;
    int numberOfBlocksAfter = 0;

    if (blockIndex == combinedGroup.combinedBlocks.length) {
      numberOfBlocksAfter = combinedBlockInGroup.numberOfRowsRight;
    } else {
      //get each combined block in the combined group
      for (int i = 1; i < combinedGroup.combinedBlocks.length; i++) {
        //check if the combined block looking at is the last
        if (i + blockIndex == combinedGroup.combinedBlocks.length) {
          int blocksBefore =
              getSpecificCombinedBlockInGroup(i + blockIndex, combinedGroup)
                  .numberOfRowsLeft;
          int combinedBlockWidth =
              getSpecificCombinedBlockInGroup(i + blockIndex, combinedGroup)
                  .block
                  .numberOfRows;
          int blocksAfter =
              getSpecificCombinedBlockInGroup(i + blockIndex, combinedGroup)
                  .numberOfRowsRight;
          // print("block $i in combined group, before $blocksBefore");
          // print("block $i in combined group, width $combinedBlockWidth");
          // print("block $i in combined group, after $blocksAfter");

          numberOfBlocksAfter +=
              blocksBefore + combinedBlockWidth + blocksAfter;
        } else {
          int blocksBefore = getSpecificCombinedBlockInGroup(i, combinedGroup)
              .numberOfRowsLeft;
          int combinedBlockWidth =
              getSpecificCombinedBlockInGroup(i, combinedGroup)
                  .block
                  .numberOfRows;
          numberOfBlocksAfter += blocksBefore + combinedBlockWidth;
          // print("block $i in combined group, before $blocksBefore");
        }
      }
    }

    int rowsBeforeCombinedBlock = totalCombinedGroupNumberOfRows -
        (combinedBlockWidth + numberOfBlocksAfter);

    // print(numberOfBlocksAfter);
    // print(combinedBlockWidth);
    // print(
    //     "for block $blockIndex in $combinedGroupIndex there are $rowsBeforeCombinedBlock's before the block");

    return rowsBeforeCombinedBlock;
  }

  int getNumberofColumnsAboveCombinedBlock(
      int blockIndex, int combinedGroupIndex) {
    CombinedGroup combinedGroup = getSpecificCombinedGroup(combinedGroupIndex);
    CombinedBlockInGroup combinedBlockInGroup =
        getSpecificCombinedBlockInGroup(blockIndex, combinedGroup);
    Block block = combinedBlockInGroup.block;
    int columnsAboveCombinedBlock = 0;

    if (combinedGroup.combinedGroupType ==
        CombinedGroupType.MULTIPLE_COMBINED_GROUP_DIFF_HEIGHT) {
      int combinedGroupHeight = combinedGroup.numberOfColumns;
      int numberOfEmptyColumnsAbove = combinedGroup.columnsAbove;
      if (combinedGroupIndex == 1) {
        int blockHeight = block.numberOfColumns;
        int numberOfEmptyColumnsAboveCombinedBlock =
            combinedBlockInGroup.numberOfColumnsAbove;
        int numberOfEmptyColumnsBelowCombinedBlock =
            combinedBlockInGroup.numberOfColumnsBelow;
        int excessColumnsAbove = (numberOfEmptyColumnsBelowCombinedBlock +
                numberOfEmptyColumnsAboveCombinedBlock) -
            blockHeight;
        if (block.numberOfColumns == combinedGroupHeight) {
          excessColumnsAbove = 0;
        }

        return combinedGroup.numberOfColumns +
            combinedGroup.columnsAbove +
            excessColumnsAbove;
      } else if (combinedGroupIndex == instance.combinedGroups.length) {
        int combinedGroupHeight = combinedGroup.numberOfColumns;
        int numberOfEmptyColumnsAbove = combinedGroup.columnsAbove;
        // int numberOfEmptyColumnsBelow = combinedGroup.columnsBelow;
        for (int i = 1; i < instance.combinedGroups.length; i++) {
          // print(getSpecificCombinedGroup(i).numberOfColumns);
          int height = getSpecificCombinedGroup(i).numberOfColumns;
          int numberOfEmptyColumnsAbove =
              getSpecificCombinedGroup(i).columnsAbove;
          columnsAboveCombinedBlock += height + numberOfEmptyColumnsAbove;
          // print('bub');
        }

        int blockHeight = block.numberOfColumns;
        int numberOfEmptyColumnsAboveCombinedBlock =
            combinedBlockInGroup.numberOfColumnsAbove;
        int numberOfEmptyColumnsBelowCombinedBlock =
            combinedBlockInGroup.numberOfColumnsBelow;
        int excessColumnsAbove = (numberOfEmptyColumnsBelowCombinedBlock +
                numberOfEmptyColumnsAboveCombinedBlock) -
            blockHeight;
        if (block.numberOfColumns == combinedGroupHeight) {
          excessColumnsAbove = 0;
        }

        return columnsAboveCombinedBlock +
            combinedGroupHeight +
            numberOfEmptyColumnsAbove +
            excessColumnsAbove;
      } else {
        int combinedGroupHeight = combinedGroup.numberOfColumns;
        int numberOfEmptyColumnsAbove = combinedGroup.columnsAbove;
        // int numberOfEmptyColumnsBelow = combinedGroup.columnsBelow;
        for (int i = 0;
            i < instance.combinedGroups.length - combinedGroupIndex;
            i++) {
          // print(getSpecificCombinedGroup(i + 1).numberOfColumns);
          int height = getSpecificCombinedGroup(i + 1).numberOfColumns;
          int numberOfEmptyColumnsAbove =
              getSpecificCombinedGroup(i + 1).columnsAbove;
          columnsAboveCombinedBlock += height + numberOfEmptyColumnsAbove;
          // print('bub');
        }

        int blockHeight = block.numberOfColumns;
        int numberOfEmptyColumnsAboveCombinedBlock =
            combinedBlockInGroup.numberOfColumnsAbove;
        int numberOfEmptyColumnsBelowCombinedBlock =
            combinedBlockInGroup.numberOfColumnsBelow;
        int excessColumnsAbove = (numberOfEmptyColumnsBelowCombinedBlock +
                numberOfEmptyColumnsAboveCombinedBlock) -
            blockHeight;
        if (block.numberOfColumns == combinedGroupHeight) {
          excessColumnsAbove = 0;
        }

        return columnsAboveCombinedBlock +
            combinedGroupHeight +
            numberOfEmptyColumnsAbove -
            numberOfEmptyColumnsBelowCombinedBlock +
            excessColumnsAbove;
      }
    } else {
      if (combinedGroupIndex == 1) {
        return combinedGroup.numberOfColumns + combinedGroup.columnsAbove;
      } else if (combinedGroupIndex == instance.combinedGroups.length) {
        int combinedGroupHeight = combinedGroup.numberOfColumns;
        int numberOfEmptyColumnsAbove = combinedGroup.columnsAbove;
        // int numberOfEmptyColumnsBelow = combinedGroup.columnsBelow;
        for (int i = 1; i < instance.combinedGroups.length; i++) {
          // print(getSpecificCombinedGroup(i).numberOfColumns);
          int height = getSpecificCombinedGroup(i).numberOfColumns;
          int numberOfEmptyColumnsAbove =
              getSpecificCombinedGroup(i).columnsAbove;
          columnsAboveCombinedBlock += height + numberOfEmptyColumnsAbove;
          // print('bub');
        }

        return columnsAboveCombinedBlock +
            combinedGroupHeight +
            numberOfEmptyColumnsAbove;
      } else {
        int combinedGroupHeight = combinedGroup.numberOfColumns;
        int numberOfEmptyColumnsAbove = combinedGroup.columnsAbove;
        // int numberOfEmptyColumnsBelow = combinedGroup.columnsBelow;
        for (int i = 0;
            i < instance.combinedGroups.length - combinedGroupIndex;
            i++) {
          // print(getSpecificCombinedGroup(i + 1).numberOfColumns);
          int height = getSpecificCombinedGroup(i + 1).numberOfColumns;
          int numberOfEmptyColumnsAbove =
              getSpecificCombinedGroup(i + 1).columnsAbove;
          columnsAboveCombinedBlock += height + numberOfEmptyColumnsAbove;
          // print('bub');
        }

        return columnsAboveCombinedBlock +
            combinedGroupHeight +
            numberOfEmptyColumnsAbove;
      }
    }
  }

  int getBlockStartColumn(int blockIndex, int combinedGroupIndex) {
    int rowsBeforeCombinedBlock =
        getNumberOfRowsBeforeCombinedBlock(blockIndex, combinedGroupIndex);
    int columnsAboveCombinedBlock =
        getNumberofColumnsAboveCombinedBlock(blockIndex, combinedGroupIndex);
    Block block = getSpecificCombinedBlockInGroup(
            blockIndex, getSpecificCombinedGroup(combinedGroupIndex))
        .block;

    return columnsAboveCombinedBlock - block.numberOfColumns;
  }

  int getBlockStartRow(int blockIndex, int combinedGroupIndex) {
    int rowsBeforeCombinedBlock =
        getNumberOfRowsBeforeCombinedBlock(blockIndex, combinedGroupIndex);
    int columnsAboveCombinedBlock =
        getNumberofColumnsAboveCombinedBlock(blockIndex, combinedGroupIndex);
    Block block = getSpecificCombinedBlockInGroup(
            blockIndex, getSpecificCombinedGroup(combinedGroupIndex))
        .block;

    return rowsBeforeCombinedBlock;
  }

  int getBlockColumn(
      int gridSection, int combinedGroupSection, int blockColumn) {
    int numberOfCombinedGroups = combinedGroups.length;
    CombinedGroup combinedGroup = getSpecificCombinedGroup(gridSection);
    int numberOfColumnsAboveCombinedGroup = combinedGroup.columnsAbove;
    int numberOfColumnsBelowCombinedGroup = combinedGroup.columnsBelow;
    int combinedGroupHeight = combinedGroup.numberOfColumns;
    int totalColumnsAbove = 0;

    if (gridSection == 1) {
      if (combinedGroupSection == 1) {
        return blockColumn;
      } else if (combinedGroupSection == 2) {
        return numberOfColumnsAboveCombinedGroup + blockColumn;
      } else if (combinedGroupSection == 3) {
        return combinedGroupHeight +
            numberOfColumnsAboveCombinedGroup +
            blockColumn;
      }
    } else {
      if (combinedGroupSection == 1) {
        for (int i = 1; i < gridSection; i++) {
          int columnsAbove = getSpecificCombinedGroup(i).columnsAbove;
          int height = getSpecificCombinedGroup(i).numberOfColumns;
          totalColumnsAbove += columnsAbove + height;
        }

        return totalColumnsAbove + blockColumn;
      } else if (combinedGroupSection == 2) {
        for (int i = 1; i < gridSection; i++) {
          int columnsAbove = getSpecificCombinedGroup(i).columnsAbove;
          int height = getSpecificCombinedGroup(i).numberOfColumns;
          totalColumnsAbove += columnsAbove + height;
        }

        return totalColumnsAbove +
            numberOfColumnsAboveCombinedGroup +
            blockColumn;
      } else if (combinedGroupSection == 3) {
        for (int i = 1; i < numberOfCombinedGroups; i++) {
          int columnsAbove = getSpecificCombinedGroup(i).columnsAbove;
          int height = getSpecificCombinedGroup(i).numberOfColumns;
          totalColumnsAbove += columnsAbove + height;
        }

        return totalColumnsAbove +
            numberOfColumnsAboveCombinedGroup +
            combinedGroupHeight +
            blockColumn;
      }
    }
  }

  int getBlockRow(int gridSection, int combinedGroupSection,
      int combinedBlockInGroupSection, int blockRow) {
    int numberOfCombinedGroups = combinedGroups.length;
    CombinedGroup combinedGroup = getSpecificCombinedGroup(gridSection);
    int numberOfColumnsAboveCombinedGroup = combinedGroup.columnsAbove;
    int combinedGroupHeight = combinedGroup.numberOfColumns;
    int totalColumnsAbove = 0;

    if (gridSection == 1) {
      if (combinedGroupSection == 1) {
        return blockRow + 1;
      } else if (combinedGroupSection == 2) {
        if (combinedBlockInGroupSection == 1) {
          return blockRow + 1;
        } else {
          int combinedBlockToTheLeftPosition = combinedBlockInGroupSection - 1;

          int combinedBlockRow =
              getBlockStartRow(combinedBlockToTheLeftPosition, gridSection) +
                  blockRow;
          Block combinedBlockToTheLeft = getSpecificCombinedBlockInGroup(
                  combinedBlockToTheLeftPosition, combinedGroup)
              .block;

          if (combinedBlockToTheLeft.numberOfRows > 1) {
            int combinedBlockWidth = combinedBlockToTheLeft.numberOfRows;
            return (combinedBlockRow + 1) + (combinedBlockWidth - 1);
          } else {
            return combinedBlockRow + 1;
          }
        }
      } else if (combinedGroupSection == 3) {
        return blockRow + 1;
      }
    } else {
      if (combinedGroupSection == 1) {
        return blockRow + 1;
      } else if (combinedGroupSection == 2) {
        if (combinedBlockInGroupSection == 1) {
          print('here: ${blockRow + 1}');

          return blockRow + 1;
        } else {
          int combinedBlockToTheLeftPosition = combinedBlockInGroupSection - 1;

          int combinedBlockRow =
              getBlockStartRow(combinedBlockToTheLeftPosition, gridSection) +
                  blockRow;
          Block combinedBlockToTheLeft = getSpecificCombinedBlockInGroup(
                  combinedBlockToTheLeftPosition, combinedGroup)
              .block;

          if (combinedBlockToTheLeft.numberOfRows > 1) {
            int combinedBlockWidth = combinedBlockToTheLeft.numberOfRows;
            return (combinedBlockRow + 1) + (combinedBlockWidth - 1);
          } else {
            return combinedBlockRow + 1;
          }
        }
      } else if (combinedGroupSection == 3) {
        return blockRow + 1;
      }
    }
  }
}

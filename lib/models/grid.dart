import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/combined_block_content.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/block_content/text_combined_block_content.dart';
import 'package:grid_ui_implementation/models/block_content/color_combined_block_content.dart';

import 'block_content/image_combined_block_content.dart';
import 'grid_custom_background.dart';

class Grid {
  static Grid instance;

  int gridColumns;
  int gridRows;
  List<CombinedGroup> combinedGroups;
  String grid_json;
  CustomGridBackground gridCustomBackground;

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

    ///Grid in json format
    this.grid_json = json.encode(gridJSON);

    ///Number of columns in the grid
    this.gridColumns = gridJSON["grid_columns"];

    ///Number or rows in the grid
    this.gridRows = gridJSON["grid_rows"];

    ///Grid's custom background
    this.gridCustomBackground = CustomGridBackground(
      gridJSON["custom_background"]["is_link"],
      gridJSON["custom_background"]["is_color"],
      gridJSON["custom_background"]["link_or_color"],
    );

    ///All combined groups in the grid
    this.combinedGroups = [];

    ///Create each combined group object and asign each to [combinedGroups]
    for (Map<String, dynamic> combinedGroupFromJSON
        in gridJSON["combined_groups"]) {
      List<CombinedBlockInGroup> allCombinedBlocks = [];

      ///Create each combined group's combined block
      for (Map<String, dynamic> combinedBlocks
          in combinedGroupFromJSON["combined_blocks"]) {
        String blockContentType =
            combinedBlocks["block"]["content"]["content_type"];

        dynamic content;
        //TODO: Only text content is supported. Need to add more.
        if (blockContentType == "text") {
          content = TextContent(
            combinedBlocks["block"]["content"]["value"]["value"],
            combinedBlocks["block"]["content"]["value"]["position"],
            combinedBlocks["block"]["content"]["value"]["font_size"],
            combinedBlocks["block"]["content"]["value"]["block_color"],
            combinedBlocks["block"]["content"]["value"]["color"],
            combinedBlocks["block"]["content"]["value"]["font_family"],
          );
        } else if (blockContentType == "color") {
          content = ColorContent(
              combinedBlocks["block"]["content"]["value"]["color_val"]);
        } else if (blockContentType == "image") {
          content =
              ImageContent(combinedBlocks["block"]["content"]["value"]["link"]);
        }

        BlockContent blockContent = new BlockContent(blockContentType, content);
        Block block = new Block(
          BlockType.combined,
          blockContent,
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

        allCombinedBlocks.add(combinedBlockInGroup);
      }

      CombinedGroup combinedGroup = new CombinedGroup(
          convertFromStringToCombinedGroupType(
              combinedGroupFromJSON["combined_group_type"]),
          combinedGroupFromJSON["columns_above"],
          combinedGroupFromJSON["columns_below"],
          combinedGroupFromJSON["number_of_columns"],
          combinedGroupFromJSON["number_of_rows"],
          allCombinedBlocks);

      combinedGroups.add(combinedGroup);
    }

    return getInstance();
  }

  Future<GridUIView> initGridView(path) async {
    Grid grid = await loadJSON(path);
    this.grid_json = grid.grid_json;
    this.gridColumns = grid.gridColumns;
    this.gridRows = grid.gridRows;
    this.combinedGroups = grid.combinedGroups;

    return GridUIView(grid.grid_json, grid.gridColumns, grid.gridRows,
        grid.gridCustomBackground, grid.combinedGroups);
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
    return rootBundle
        .loadString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  Map<String, dynamic> toJSON(Grid grid) {
    return {
      "grid_json": grid_json,
      "gridColumns": gridColumns,
      "gridRows": gridRows,
      "combinedGroups": combinedGroups
    };
  }

  CombinedGroup getSpecificCombinedGroup(int index) {
    return combinedGroups[index];
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
    int totalBlocksBefore = 0;

    for (int i = 0; i < combinedGroup.combinedBlocks.length; i++) {
      Block blockI =
          getSpecificCombinedBlockInGroup(i + 1, combinedGroup).block;
      if (i != blockIndex - 1) {
        totalBlocksBefore +=
            getSpecificCombinedBlockInGroup(i + 1, combinedGroup)
                    .numberOfRowsLeft +
                blockI.numberOfRows;
      } else {
        totalBlocksBefore +=
            getSpecificCombinedBlockInGroup(i + 1, combinedGroup)
                .numberOfRowsLeft;
        break;
      }
    }

    int rowsBeforeCombinedBlock = totalBlocksBefore;

    return rowsBeforeCombinedBlock;
  }

  int getNumberofColumnsAboveCombinedBlock(
      int blockIndex, int combinedGroupIndex) {
    CombinedGroup combinedGroup = getSpecificCombinedGroup(combinedGroupIndex);
    CombinedBlockInGroup combinedBlockInGroup =
        getSpecificCombinedBlockInGroup(blockIndex, combinedGroup);
    int columnsAboveCombinedBlock = 0;

    for (int i = 0; i < combinedGroups.length; i++) {
      CombinedGroup combinedGroup = getSpecificCombinedGroup(i);

      if (i != combinedGroupIndex - 1) {
        columnsAboveCombinedBlock +=
            combinedGroup.columnsAbove + combinedGroup.numberOfColumns;
      } else {
        columnsAboveCombinedBlock += combinedGroup.columnsAbove +
            combinedBlockInGroup.numberOfColumnsAbove;
        break;
      }
    }

    return columnsAboveCombinedBlock;
  }

  int getBlockStartColumn(int blockIndex, int combinedGroupIndex) {
    int columnsAboveCombinedBlock =
        getNumberofColumnsAboveCombinedBlock(blockIndex, combinedGroupIndex);
    Block block = getSpecificCombinedBlockInGroup(
            blockIndex, getSpecificCombinedGroup(combinedGroupIndex))
        .block;

    return columnsAboveCombinedBlock;
  }

  int getBlockStartRow(int blockIndex, int combinedGroupIndex) {
    int rowsBeforeCombinedBlock =
        getNumberOfRowsBeforeCombinedBlock(blockIndex, combinedGroupIndex);
    Block block = getSpecificCombinedBlockInGroup(
            blockIndex, getSpecificCombinedGroup(combinedGroupIndex))
        .block;

    return rowsBeforeCombinedBlock;
  }

  int getTargetColumn(int combinedGroupSection, int columnsAboveCombinedGroup,
      int blockColumn, int combinedGroupHeight, Block block, int offset) {
    List possibleColumns = [];
    for (int i = 0; i < combinedGroupHeight; i++) {
      possibleColumns
          .add((columnsAboveCombinedGroup - combinedGroupHeight) + i);
    }

    int targetColumn = possibleColumns[(blockColumn + offset) - 1];
    return targetColumn;
  }

  int getTargetRow(
      int rowsRightOfBlock, int blockRow, int offset, int combinedGroupWidth,
      {int difference = 0}) {
    List possibleRows = [];
    for (int i = 0; i < combinedGroupWidth; i++) {
      possibleRows.add(i);
    }

    int targetRow = possibleRows[((blockRow + offset) - difference) - 1];
    return targetRow;
  }
}

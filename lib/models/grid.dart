import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';

class Grid {
  static Grid instance;

  int gridColumns;
  int gridRows;
  List<CombinedGroup> combinedGroups; //each combined group in the grid

  Grid._();

  static Grid getInstance() {
    if (instance == null) instance = Grid._();
    return instance;
  }

  ///Load the grid's data from JSON file
  Future<Grid> loadJSON(String path) async {
    Map<String, dynamic> gridJSON = await parseJsonFromAssets(path);

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
}

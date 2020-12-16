import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/grid_content.dart';

class Grid {
  static Grid instance;

  int gridColumns;
  int gridRows;
  List<GridContent> gridCombinedGroups;

  Grid._();

  static Grid getInstance() {
    if (instance == null) instance = Grid._();
    return instance;
  }

  Future<Grid> loadJSON(String path) async {
    Map<String, dynamic> gridJSON = await parseJsonFromAssets(path);

    this.gridColumns = gridJSON["grid_columns"];
    this.gridRows = gridJSON["grid_rows"];
    this.gridCombinedGroups = [];

    for (Map<String, dynamic> item in gridJSON["combined_groups"]) {
      List<CombinedBlockInGroup> allCombinedGroups = [];

      for (Map<String, dynamic> combinedBlocks in item["combined_group"]
          ["combined_blocks"]) {
        Block block = new Block(
          BlockType.combined, //TODO: Fix this
          combinedBlocks["block"]["content"],
          combinedBlocks["block"]["number_of_rows"],
          combinedBlocks["block"]["number_of_columns"],
          // combinedBlocks["block"]["type"],
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
              item["combined_group"]["combined_group_type"]),
          item["combined_group"]["number_of_columns"],
          item["combined_group"]["number_of_rows"],
          allCombinedGroups);

      GridContent gridContent = new GridContent(item["columns_above_count"],
          item["columns_below_count"], combinedGroup);

      gridCombinedGroups.add(gridContent);
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
}

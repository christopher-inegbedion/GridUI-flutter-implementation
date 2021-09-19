import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/block.dart';
import 'package:grid_ui_implementation/models/block_content/image_carousel_block_content.dart';
import 'package:grid_ui_implementation/models/combined_block_content.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';
import 'package:grid_ui_implementation/models/combined_group.dart';
import 'package:grid_ui_implementation/models/block_content/text_combined_block_content.dart';
import 'package:grid_ui_implementation/models/block_content/color_combined_block_content.dart';

import 'block_content/image_combined_block_content.dart';
import 'block_content/task_combined_block_content.dart';
import 'grid_custom_background.dart';

class Grid {
  static Grid instance;

  int gridColumns;
  int gridRows;
  List<CombinedGroup> combinedGroups;
  String gridJson;
  CustomGridBackground gridCustomBackground;
  GridUIView _gridUIView;
  Function onViewInitComplete;

  bool editMode = false;

  Grid._() {
    _gridUIView = GridUIView.empty();
  }

  static Grid getInstance() {
    if (instance == null) {
      instance = Grid._();
      instance._gridUIView = GridUIView.empty();
    }

    return instance;
  }

  ///Load the grid's data from JSON file
  Future<Grid> loadJSON(String path,
      {bool fromNetwork = false, String grid}) async {
    Map<String, dynamic> gridJSON;
    instance.combinedGroups = [];
    if (fromNetwork) {
      gridJSON = jsonDecode(grid);
    } else {
      gridJSON = await parseJsonFromAssets(path);
    }

    ///Grid in json format
    instance.gridJson = json.encode(gridJSON);

    ///Number of columns in the grid
    instance.gridColumns = gridJSON["grid_columns"];

    ///Number or rows in the grid
    instance.gridRows = gridJSON["grid_rows"];

    ///Grid's custom background
    instance.gridCustomBackground = CustomGridBackground(
      gridJSON["custom_background"]["is_link"],
      gridJSON["custom_background"]["is_color"],
      gridJSON["custom_background"]["link_or_color"],
    );

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
        if (blockContentType == "text") {
          content = TextContent(
            combinedBlocks["block"]["content"]["value"]["value"],
            combinedBlocks["block"]["content"]["value"]["position"],
            combinedBlocks["block"]["content"]["value"]["x_pos"] == null
                ? 0
                : combinedBlocks["block"]["content"]["value"]["x_pos"],
            combinedBlocks["block"]["content"]["value"]["y_pos"] == null
                ? 0
                : combinedBlocks["block"]["content"]["value"]["y_pos"],
            combinedBlocks["block"]["content"]["value"]["font"],
            combinedBlocks["block"]["content"]["value"]["font_size"],
            combinedBlocks["block"]["content"]["value"]["block_color"],
            combinedBlocks["block"]["content"]["value"]["block_image"],
            combinedBlocks["block"]["content"]["value"]["color"],
            combinedBlocks["block"]["content"]["value"]["underline"],
            combinedBlocks["block"]["content"]["value"]["line_through"],
            combinedBlocks["block"]["content"]["value"]["bold"],
            combinedBlocks["block"]["content"]["value"]["italic"],
          );
        } else if (blockContentType == "color") {
          content = ColorContent(
              combinedBlocks["block"]["content"]["value"]["color_val"]);
        } else if (blockContentType == "image") {
          content =
              ImageContent(combinedBlocks["block"]["content"]["value"]["link"]);
        } else if (blockContentType == "task") {

          content = TaskContent(
              combinedBlocks["block"]["content"]["value"]["task_id"],
              combinedBlocks["block"]["content"]["value"]["task_image"]);
        } else if (blockContentType == "image_carousel") {
          content = ImageCarouselContent(
              combinedBlocks["block"]["content"]["value"]["images"]);
        } else {
          throw Exception("Content type: $blockContentType not inplemented");
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

    instance.combinedGroups = combinedGroups;

    return getInstance();
  }

  Widget buildViewLayout() {
    return _gridUIView;
  }

  get gridUIView {
    return _gridUIView;
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
      "grid_json": gridJson,
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

  void setData(String gridJson, int columns, int rows, List combinedGroups,
      CustomGridBackground customGridBackground) {
    instance.gridJson = gridJson;
    instance.gridColumns = columns;
    instance.gridRows = rows;
    instance.combinedGroups = combinedGroups;
    instance.gridCustomBackground = customGridBackground;
  }

  void buildGridView() {
    _gridUIView.changeCols(gridColumns);
    _gridUIView.changeRows(gridRows);
    _gridUIView.changeGrid(combinedGroups);
    _gridUIView.changeGridJSON(gridJson);
    _gridUIView.changeCustomBackground(gridCustomBackground);

    onViewInitComplete();

  }

  void toggleEditMode() {
    instance.editMode = !instance.editMode;
    _gridUIView.changeEditMode(instance.editMode);
  }
}

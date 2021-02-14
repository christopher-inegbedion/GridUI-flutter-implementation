import 'package:grid_ui_implementation/enum/combined_group_type.dart';
import 'package:grid_ui_implementation/models/combined_block_in_group.dart';

///A combined group in a grid contains multiple combined blocks.
///
///This class represents the properties of a combined group.
/// 'x' represents a combined block. '0' represents an empty block.
/// This combined group contains 2 combined blocks. This combined group type is MULITPLE_COMBINED_GROUP_SAME_HEIGHT
/// ```
/// | x x x 0 x |
/// | x x x 0 x |
/// | 0 0 0 0 0 |
/// | 0 0 0 0 0 |
/// | 0 0 0 0 0 |
/// ```
class CombinedGroup {
  ///The type of combined block. There are 3 types
  CombinedGroupType combinedGroupType;

  ///Number of columns above
  int columnsAbove;

  ///Number of columns below
  int columnsBelow;

  ///The total number of comlumns occupied by the group
  int numberOfColumns;

  ///The total number of rows occupied by the group
  int numberOfRows;

  ///All combined blocks in the group
  List<CombinedBlockInGroup> combinedBlocks;

  CombinedGroup(
      CombinedGroupType combinedGroupType,
      int columnsAbove,
      int columnsBelow,
      int numberOfColumns,
      int numberOfRows,
      List<CombinedBlockInGroup> combinedBlocks) {
    this.columnsAbove = columnsAbove;
    this.columnsBelow = columnsBelow;
    this.combinedGroupType = combinedGroupType;
    this.numberOfColumns = numberOfColumns;
    this.numberOfRows = numberOfRows;
    this.combinedBlocks = combinedBlocks;
  }

  Map<String, dynamic> toJSON(CombinedGroup combinedGroup) {
    return {
      "combinedGroupType": combinedGroupType,
      "columnsAbove": columnsAbove,
      "columnsBelow": columnsBelow,
      "numberOfColumns": numberOfColumns,
      "numberOfRows": numberOfRows,
      "combinedBlocks": combinedBlocks
    };
  }
}

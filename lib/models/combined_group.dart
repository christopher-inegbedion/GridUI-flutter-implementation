import 'package:grid_ui_implementation/enum/combined_group_type.dart';

class CombinedGroup {
  CombinedGroupType combinedGroupType;
  int numberOfColumns;
  int numberOfRows;
  List combinedBlocks;

  CombinedGroup(CombinedGroupType combinedGroupType, int numberOfColumns,
      int numberOfRows, List combinedBlocks) {
    this.combinedGroupType = combinedGroupType;
    this.numberOfColumns = numberOfColumns;
    this.numberOfRows = numberOfRows;
    this.combinedBlocks = combinedBlocks;
  }
}

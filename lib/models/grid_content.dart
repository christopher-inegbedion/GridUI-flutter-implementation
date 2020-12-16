import 'package:grid_ui_implementation/models/combined_group.dart';

class GridContent {
  int columnsAbove;
  int columnsBelow;
  CombinedGroup combinedGroup;

  GridContent(int columnsAbove, int columnsBelow, CombinedGroup combinedGroup) {
    this.columnsAbove = columnsAbove;
    this.columnsBelow = columnsBelow;
    this.combinedGroup = combinedGroup;
  }
}

import 'package:grid_ui_implementation/models/block.dart';

class CombinedBlockInGroup {
  int numberOfRowsLeft;
  int numberOfRowsRight;
  int numberOfColumnsAbove;
  int numberOfColumnsBelow;
  int positionInCombinedBlock;
  Block block;

  CombinedBlockInGroup(
      int numberOfRowsLeft,
      int numberOfRowsRight,
      int numberOfColumnsAbove,
      int numberOfColumnsBelow,
      int positionInCombinedBlock,
      Block block) {
    this.numberOfRowsLeft = numberOfRowsLeft;
    this.numberOfRowsRight = numberOfRowsRight;
    this.numberOfColumnsAbove = numberOfColumnsAbove;
    this.numberOfColumnsBelow = numberOfColumnsBelow;
    this.positionInCombinedBlock = positionInCombinedBlock;
    this.block = block;
  }
}

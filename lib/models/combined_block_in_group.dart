import 'package:grid_ui_implementation/models/block.dart';

///This class represents a combined block in a group.
///
///It contains the data relating to its position within the combined group and
///also its content and size(in the [block] field)
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

  Map<String, dynamic> toJSON(CombinedBlockInGroup combinedBlockInGroup) {
    return {
      "numberOfRowsLeft": numberOfRowsLeft,
      "numberOfRowsRight": numberOfRowsRight,
      "numberOfColumnsAbove": numberOfColumnsAbove,
      "numberOfColumnsBelow": numberOfColumnsBelow,
      "positionInCombinedBlock": positionInCombinedBlock,
      "block": block
    };
  }
}

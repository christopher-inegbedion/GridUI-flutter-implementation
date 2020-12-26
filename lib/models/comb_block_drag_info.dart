import 'block.dart';

class CombBlockDragInformation {
  Block block;
  int blockQuadrantDraggingFrom;
  int combinedBlockStartColumn;
  int combinedBlockStartRow;
  int combinedBlockWidth;
  int combinedBlockHeight;

  CombBlockDragInformation(
      {this.block,
      this.blockQuadrantDraggingFrom,
      this.combinedBlockStartColumn,
      this.combinedBlockStartRow,
      this.combinedBlockWidth,
      this.combinedBlockHeight});
}

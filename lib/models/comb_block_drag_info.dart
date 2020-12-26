import 'block.dart';

class CombBlockDragInformation {
  Block block;
  int blockQuadrantDraggingFrom;
  int blockQuadrantColumn;
  int blockQuadrantRow;
  int combinedBlockStartColumn;
  int combinedBlockStartRow;
  int combinedBlockWidth;
  int combinedBlockHeight;

  CombBlockDragInformation(
      {this.block,
      this.blockQuadrantDraggingFrom,
      this.blockQuadrantColumn,
      this.blockQuadrantRow,
      this.combinedBlockStartColumn,
      this.combinedBlockStartRow,
      this.combinedBlockWidth,
      this.combinedBlockHeight});
}

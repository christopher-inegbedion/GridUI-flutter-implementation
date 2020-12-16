import 'package:grid_ui_implementation/enum/block_type.dart';

class Block {
  dynamic content;
  int numberOfColumns;
  int numberOfRows;
  BlockType blockType;

  Block(BlockType blockType, dynamic content, int numberOfRows,
      int numberOfColumns) {
    this.content = content;
    this.numberOfColumns = numberOfColumns;
    this.numberOfRows = numberOfRows;
    this.blockType = blockType;
  }
}

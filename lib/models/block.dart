import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:uuid/uuid.dart';

import 'combined_block_content.dart';

///This object represents a block with its height (represented as the number of columns) and its width (represented as the number of rows) in a combined group
class Block {
  String uuid;

  ///Block's content
  BlockContent content;

  ///Block's height (represented as the number of columns)
  int numberOfColumns;

  ///Block's width (represented as the number of rows)
  int numberOfRows;

  ///Type of block
  BlockType blockType;

  Block(BlockType blockType, dynamic content, int numberOfRows,
      int numberOfColumns) {
    this.uuid = Uuid().v4();
    this.content = content;
    this.numberOfColumns = numberOfColumns;
    this.numberOfRows = numberOfRows;
    this.blockType = blockType;
  }

  Map<String, dynamic> toJSON(Block block) {
    return {
      "uuid": uuid,
      "blockType": blockType,
      "content": content,
      "numberOfRows": numberOfRows,
      "numberOfColumns": numberOfColumns
    };
  }
}

import 'package:grid_ui_implementation/enum/block_type.dart';
import 'package:grid_ui_implementation/models/block_command.dart';

import 'combined_block_content.dart';

///This object represents a block with its height (represented as the number of columns) and its width (represented as the number of rows) in a combined group
class Block {
  int index;

  ///Block's content
  BlockContent content;

  ///Block's height (represented as the number of columns)
  int numberOfColumns;

  ///Block's width (represented as the number of rows)
  int numberOfRows;

  ///Type of block
  BlockType blockType;

  ///Block command
  BlockCommand blockCommand;

  Block(BlockType blockType, dynamic content, int numberOfRows,
      int numberOfColumns, BlockCommand blockCommand) {
    this.index = index;
    this.content = content;
    this.numberOfColumns = numberOfColumns;
    this.numberOfRows = numberOfRows;
    this.blockType = blockType;
    this.blockCommand = blockCommand;
  }

  Map<String, dynamic> toJSON(Block block) {
    return {
      "index": index,
      "blockType": blockType,
      "content": content,
      "numberOfRows": numberOfRows,
      "numberOfColumns": numberOfColumns,
      "command": blockCommand
    };
  }
}

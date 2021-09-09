class TextContent {
  String value;
  int position;
  int x_pos;
  int y_pos;
  double fontSize;
  String blockColor;
  String blockImage;
  String color;
  String font;
  bool underline;
  bool lineThrough;
  bool bold;
  bool italic;

  TextContent(this.value, this.position, this.x_pos, this.y_pos, this.font,
      this.fontSize, this.blockColor, this.blockImage, this.color, this.underline,
      this.lineThrough, this.bold, this.italic);

  Map<String, dynamic> toJSON() {
    return {
      "value": value,
      "position": position,
      "x_pos": x_pos,
      "y_pos": y_pos,
      "font": font,
      "font_size": fontSize,
      "block_color": blockColor,
      "block_image": blockImage,
      "color": color,
      "underline": underline,
      "line_through": lineThrough,
      "bold": bold,
      "italic": italic
    };
  }
}

class TextContent {
  String value;
  int position;
  double fontSize;
  String blockColor;
  String color;
  String font_family;

  TextContent(this.value, this.position, this.fontSize, this.blockColor,
      this.color, this.font_family);

  Map<String, dynamic> toJSON(TextContent content) {
    return {
      "value": value,
      "position": position,
      "font_size": fontSize,
      "block_color": blockColor,
      "color": color,
      "font_family": font_family
    };
  }
}

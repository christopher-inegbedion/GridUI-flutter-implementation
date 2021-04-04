class TextContent {
  String value;
  int position;
  double fontSize;
  String blockColor;
  String color;
  String font;

  TextContent(String value, int position, double fontSize, String blockColor,
      String color, String font) {
    this.value = value;
    this.position = position;
    this.fontSize = fontSize;
    this.blockColor = blockColor;
    this.color = color;
    this.font = font;
  }

  Map<String, dynamic> toJSON(TextContent content) {
    return {
      "value": value,
      "position": position,
      "font_size": fontSize,
      "block_color": blockColor,
      "color": color,
      "font": font
    };
  }
}

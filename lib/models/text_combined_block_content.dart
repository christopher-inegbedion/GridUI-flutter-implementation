class TextContent {
  String value;
  int position;
  double font_size;
  String color;
  String font;

  TextContent(String value, int position, double font_size,
      String color, String font) {
    this.value = value;
    this.position = position;
    this.font_size = font_size;
    this.color = color;
    this.font = font;
  }

  Map<String, dynamic> toJSON(TextContent content) {
    return {
      "value": value,
      "position": position,
      "font_size": font_size,
      "color": color,
      "font": font
    };
  }
}

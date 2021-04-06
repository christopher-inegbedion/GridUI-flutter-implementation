class CustomGridBackground {
  bool is_link;
  bool is_color;
  String link_or_color;

  CustomGridBackground(this.is_link, this.is_color, this.link_or_color);

  Map<String, dynamic> toJSON() {
    return {
      "is_link": is_link,
      "is_color": is_color,
      "link_or_color": link_or_color
    };
  }
}

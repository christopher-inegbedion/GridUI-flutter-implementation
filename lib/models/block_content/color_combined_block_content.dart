class ColorContent {
  String colorVal;

  ColorContent(String colorVal) {
    this.colorVal = colorVal;
  }

  Map<String, String> toJSON() {
    return {"color_val": colorVal};
  }
}

class ImageContent {
  String link;

  ImageContent(this.link);

  Map<String, String> toJSON() {
    return {"link": link};
  }
}

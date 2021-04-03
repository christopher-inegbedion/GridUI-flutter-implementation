class BlockContent {
  String content_type;
  dynamic content;

  BlockContent(String content_type, dynamic content) {
    this.content_type = content_type;
    this.content = content;
  }

  Map<String, dynamic> toJSON(BlockContent content) {
    return {"content_type": content_type, "content": content};
  }
}

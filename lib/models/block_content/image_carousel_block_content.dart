import 'dart:convert';

class ImageCarouselContent {
  List images = [];

  ImageCarouselContent(this.images);

  Map<String, String> toJSON() {
    return {"images": jsonEncode(images)};
  }
}
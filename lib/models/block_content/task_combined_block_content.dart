class TaskContent {
  String id;
  String image;

  TaskContent(this.id, this.image);

  Map<String, dynamic> toJSON() {
    return {"task": id, "image": image};
  }
}

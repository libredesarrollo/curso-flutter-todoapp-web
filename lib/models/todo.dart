class Todo {
  int id;
  DateTime time;
  //DateTime created = DateTime.now();
  String title;
  String content;
  String image;

  Todo(
      {this.id = 0,
      required this.time,
      this.title = "",
      this.content = "",
      this.image = ""});
}

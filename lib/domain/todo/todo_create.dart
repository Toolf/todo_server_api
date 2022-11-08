class TodoCreate {
  const TodoCreate({
    required this.title,
    required this.description,
  });
  final String title;
  final String description;

  static TodoCreate fromJson(Map<String, dynamic> json) {
    return TodoCreate(
      title: json["title"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
    };
  }
}

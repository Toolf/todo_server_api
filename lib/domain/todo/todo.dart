class Todo {
  const Todo({
    required this.todoId,
    required this.title,
    required this.description,
    this.completed = false,
  });
  final int todoId;
  final String title;
  final String description;
  final bool completed;

  static Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      todoId: json["todoId"],
      title: json["title"],
      description: json["description"],
      completed: json["completed"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "todoId": todoId,
      "title": title,
      "description": description,
      "completed": completed,
    };
  }
}

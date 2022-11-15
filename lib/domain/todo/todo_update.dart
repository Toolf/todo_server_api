class TodoUpdate {
  final int todoId;
  final String? title;
  final String? description;
  final bool? completed;

  const TodoUpdate({
    required this.todoId,
    required this.title,
    required this.description,
    required this.completed,
  });

  static TodoUpdate fromJson(Map<String, dynamic> json) {
    return TodoUpdate(
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

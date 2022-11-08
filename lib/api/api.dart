import '../db/db.dart';
import 'todo/todo_api.dart';

class Api {
  final TodoApi todo;

  Api._({
    required this.todo,
  });

  factory Api() {
    return Api._(
      todo: TodoApi(db.todoDataSource),
    );
  }

  asyncInit() async {}
}

final api = Api();

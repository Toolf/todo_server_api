import '../../core/schema/schema_view.dart';
import '../../domain/todo/todo_create.dart';
import 'todo.dart';

final todoCreateSchema = SchemaView(
  "TodoCreate",
  todoSchema,
  [
    SchemaViewField(name: "title"),
    SchemaViewField(name: "description"),
  ],
  (data) => TodoCreate.fromJson(data),
);

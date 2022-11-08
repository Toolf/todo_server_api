import '../../core/schema/schema_view.dart';
import '../../domain/todo/todo_update.dart';
import 'todo.dart';

final todoUpdateSchema = SchemaView(
  "TodoUpdate",
  todoSchema,
  [
    SchemaViewField(name: "todoId", identity: true),
    SchemaViewField(name: "title", nullable: true),
    SchemaViewField(name: "description", nullable: true),
    SchemaViewField(name: "completed", nullable: true),
  ],
  (data) => TodoUpdate.fromJson(data),
);

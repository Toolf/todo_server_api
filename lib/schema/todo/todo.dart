import '../../core/schema/basic_shema.dart';
import '../../core/schema/schema.dart';
import '../../domain/todo/todo.dart';

final todoSchema = Schema(
  "Todo",
  {
    "todoId": BasicSchema(type: "integer"),
    "title": BasicSchema(type: "string", lengthMax: 64, lengthMin: 1),
    "description": BasicSchema(type: "string"),
    "completed": BasicSchema(type: "boolean"),
  },
  (data) => Todo.fromJson(data),
);

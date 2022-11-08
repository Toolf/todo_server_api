import '../core/db/mysql.dart';
import '../core/db/mysql_crudl_datasource.dart';
import '../domain/todo/todo.dart';
import '../domain/todo/todo_create.dart';
import '../domain/todo/todo_update.dart';
import '../schema/todo/todo.dart';
import '../schema/todo/todo_create.dart';
import '../schema/todo/todo_update.dart';

class TodoDataSource
    extends MysqlCrudlDatasource<Todo, TodoCreate, TodoUpdate> {
  @override
  String get tableName => 'Todo';

  TodoDataSource(MysqlConnectionFactory connectionFactory)
      : super(
          (todoJson) => Todo.fromJson(todoJson),
          todoSchema,
          todoCreateSchema,
          todoUpdateSchema,
          connectionFactory,
        );
}

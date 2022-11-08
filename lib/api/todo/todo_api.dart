import '../../core/crudl_api.dart';
import '../../db/todo_datasource.dart';
import '../../domain/todo/todo.dart';
import '../../domain/todo/todo_create.dart';
import '../../domain/todo/todo_update.dart';
import '../../schema/todo/todo.dart';
import '../../schema/todo/todo_create.dart';
import '../../schema/todo/todo_update.dart';

class TodoApi {
  final CrudlApi<Todo, TodoCreate, TodoUpdate> _crudl;

  get create => _crudl.create;
  get read => _crudl.read;
  get update => _crudl.update;
  get delete => _crudl.delete;
  get list => _crudl.list;

  TodoApi._(
    TodoDataSource dataSource,
  ) : _crudl = CrudlApi<Todo, TodoCreate, TodoUpdate>(
          datasource: dataSource,
          entitySchema: todoSchema,
          entityUpdateSchema: todoUpdateSchema,
          entityCreateSchema: todoCreateSchema,
        );

  factory TodoApi(TodoDataSource dataSource) {
    return TodoApi._(
      dataSource,
    );
  }
}

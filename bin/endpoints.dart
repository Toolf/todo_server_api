part of 'server.dart';

final endpoints = <String, Endpoint>{
  // Todo
  "todo/create": api.todo.create,
  "todo/read": api.todo.read,
  "todo/update": api.todo.update,
  "todo/delete": api.todo.delete,
  "todo/list": api.todo.list,
};

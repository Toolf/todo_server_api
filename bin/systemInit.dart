import 'package:todo_server_api/api/api.dart';
import 'package:todo_server_api/db/db.dart';

Future systemInit() async {
  await api.asyncInit();
  await db.asyncInit();
}

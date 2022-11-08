import 'dart:io';

import 'package:mysql_client/mysql_client.dart';

import '../config/config.dart';
import '../core/db/mysql.dart';
import 'todo_datasource.dart';

class DB {
  final MysqlConnectionFactory mysql;
  final TodoDataSource todoDataSource;

  DB._({
    required this.mysql,
    required this.todoDataSource,
  });

  factory DB() {
    final mysql = MysqlConnectionFactory(config.mysqlConfig);

    final db = DB._(
      mysql: mysql,
      todoDataSource: TodoDataSource(mysql),
    );

    return db;
  }

  Future asyncInit() async {
    final connection = await mysql.createConnection();
    try {
      print("DB init");
      await connection.connect();
      await connection.transactional((conn) async {
        print("CREATE CONNECTION");
        final res = await conn.execute(
          "SELECT COUNT(TABLE_NAME) "
          "FROM "
          "   information_schema.TABLES "
          "WHERE "
          "	TABLE_NAME = 'MySystem' ",
        );
        final dbExist = res.rows.single.typedColAt<int>(0)! == 1;

        try {
          print(dbExist);
          if (!dbExist) {
            // Prepare system tables
            final systemStructure = await File("db/system.sql").readAsString();
            await conn.execute(systemStructure);
            // Prepare project tables
            final dbStructure = await File("db/structure.sql").readAsString();
            await conn.execute(dbStructure);
          }
        } catch (e) {
          rethrow;
        }
      });
    } catch (e) {
      rethrow;
    } finally {
      connection.close();
      print("DB finish");
    }
  }
}

final db = DB();

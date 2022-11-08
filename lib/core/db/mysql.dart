import 'package:mysql_client/mysql_client.dart';

import 'database.dart';
import 'mysql_config.dart';

class MysqlConnectionFactory implements DatabaseConnectionFactory {
  final MysqlConfig config;

  MysqlConnectionFactory(this.config);

  @override
  Future<MySQLConnection> createConnection() {
    return MySQLConnection.createConnection(
      host: config.host,
      port: config.port,
      databaseName: config.database,
      userName: config.username,
      password: config.password,
    );
  }
}

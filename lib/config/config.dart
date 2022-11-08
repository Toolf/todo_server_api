import '../core/db/mysql_config.dart';
import 'mysql_config.dart';

class Config {
  final MysqlConfig mysqlConfig;

  Config._({
    required this.mysqlConfig,
  });

  factory Config.debug() {
    return Config._(mysqlConfig: mysqlDefaultConfig);
  }
}

final config = Config.debug();

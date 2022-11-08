class MysqlConfig {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  const MysqlConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });
}

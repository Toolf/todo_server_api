import 'dart:convert';

import '../exception/db_exception.dart';
import '../pagination/pagination.dart';
import '../schema/schema.dart';
import '../schema/schema_view.dart';
import 'crudl_datasource.dart';
import 'mysql.dart';

class MysqlCrudlDatasource<Entity, CreateEntity, UpdateEntity>
    implements CrudlDatasource<Entity, CreateEntity, UpdateEntity> {
  final MysqlConnectionFactory connectionFactory;
  String get tableName => throw UnimplementedError();
  String get identityName => "${tableName.toLowerCase()}Id";
  final Schema<Entity> entitySchema;
  final SchemaView<CreateEntity> createEntitySchema;
  final SchemaView<UpdateEntity> updateEntitySchema;
  final Entity Function(dynamic obj) entityConstructor;

  MysqlCrudlDatasource(
    this.entityConstructor,
    this.entitySchema,
    this.createEntitySchema,
    this.updateEntitySchema,
    this.connectionFactory,
  );

  @override
  Future<int> create(CreateEntity entity) async {
    final connection = await connectionFactory.createConnection();
    try {
      await connection.connect();
      final fieldsNames = createEntitySchema.fields.map((f) => f.name).toList();
      final res = await connection.execute(
        "INSERT INTO $tableName (${fieldsNames.join(', ')}) "
        "VALUES (${fieldsNames.map((f) => ':$f').join(', ')})",
        jsonDecode(jsonEncode(entity)),
      );
      return res.lastInsertID.toInt();
    } catch (e) {
      if (e is DbException) {
        rethrow;
      } else {
        throw DbException("Invalid create operation", e);
      }
    } finally {
      await connection.close();
    }
  }

  @override
  Future<Entity> read(int entityId) async {
    final connection = await connectionFactory.createConnection();
    try {
      await connection.connect();

      final fieldsNames = entitySchema.fields.entries
          .where((f) => !f.value.related)
          .map((f) => f.key)
          .toList();
      final res = await connection.execute(
        "SELECT ${fieldsNames.join(', ')} "
        "FROM $tableName "
        "WHERE $identityName = :$identityName ",
        {
          identityName: entityId,
        },
      );
      if (res.rows.isEmpty) {
        throw DbException("Not found entity", null);
      }
      final entityData = res.rows.single.typedAssoc();

      return entityConstructor(entityData);
    } catch (e) {
      if (e is DbException) {
        rethrow;
      } else {
        throw DbException("Invalid read operation", e);
      }
    } finally {
      await connection.close();
    }
  }

  @override
  Future<Entity> delete(int entityId) async {
    final connection = await connectionFactory.createConnection();
    try {
      await connection.connect();
      final res = await connection.transactional<Entity>((conn) async {
        final readFieldsNames = entitySchema.fields.entries
            .where((f) => !f.value.related)
            .map((f) => f.key)
            .toList();
        final readRes = await conn.execute(
          "SELECT ${readFieldsNames.join(', ')} "
          "FROM $tableName "
          "WHERE $identityName = :$identityName ",
          {
            identityName: entityId,
          },
        );
        if (readRes.rows.isEmpty) {
          throw DbException("Not found entity", null);
        }
        final deleteRes = await connection.execute(
          "DELETE "
          "FROM $tableName "
          "WHERE $identityName = :$identityName ",
          {
            identityName: entityId,
          },
        );
        if (deleteRes.affectedRows.toInt() != 1) {
          throw DbException("Invalid delete result", null);
        }
        final entityData = readRes.rows.single.typedAssoc();
        return entityConstructor(entityData);
      });
      return res;
    } catch (e) {
      if (e is DbException) {
        rethrow;
      } else {
        throw DbException("Invalid delete operation", e);
      }
    } finally {
      await connection.close();
    }
  }

  @override
  Future<PaginationResponce<Entity>> list(PaginationRequest request) async {
    final connection = await connectionFactory.createConnection();
    try {
      await connection.connect();
      final fieldsNames = entitySchema.fields.entries
          .where((f) => !f.value.related)
          .map((f) => f.key)
          .toList();
      final res = await connection.transactional((conn) async {
        final res = await conn.execute(
            "SELECT ${fieldsNames.join(', ')} "
            "FROM $tableName "
            "LIMIT :limit OFFSET :offset ",
            {
              "limit": request.perPage,
              "offset": request.page * request.perPage,
            });
        final entities = res.rows.map((r) => r.typedAssoc()).map((entityMap) {
          final entityData = entityMap;
          return entityConstructor(entityData);
        }).toList();

        final totalResult = await conn.execute(
          "SELECT COUNT(*) "
          "FROM $tableName",
        );
        final total = totalResult.rows.single.typedColAt<int>(0)!;

        return PaginationResponce<Entity>(
          filter: request.filter,
          page: request.page,
          perPage: request.perPage,
          total: total,
          data: entities,
        );
      });
      return res;
    } catch (e) {
      if (e is DbException) {
        rethrow;
      } else {
        throw DbException("Invalid list operation", e);
      }
    } finally {
      await connection.close();
    }
  }

  @override
  Future<Entity> update(UpdateEntity entity) async {
    final connection = await connectionFactory.createConnection();
    try {
      await connection.connect();
      final res = await connection.transactional<Entity>((conn) async {
        final updateFieldsNames = updateEntitySchema.fields
            .where((f) => !f.identity)
            .map((f) => f.name)
            .toList();
        await conn.execute(
          "UPDATE $tableName "
          "SET "
          "${updateFieldsNames.map((f) => '  $f = COALESCE(:$f, $f)').join(', ')} "
          "WHERE $identityName = :$identityName",
          jsonDecode(jsonEncode(entity)),
        );
        final readFieldsNames = entitySchema.fields.entries
            .where((f) => !f.value.related)
            .map((f) => f.key)
            .toList();
        final readRes = await conn.execute(
          "SELECT ${readFieldsNames.join(', ')} "
          "FROM $tableName "
          "WHERE $identityName = :$identityName ",
          jsonDecode(jsonEncode(entity)),
        );
        if (readRes.rows.isEmpty) {
          throw DbException("Not found entity", null);
        }
        final enityData = readRes.rows.single.typedAssoc();
        return entityConstructor(enityData);
      });
      return res;
    } catch (e) {
      if (e is DbException) {
        rethrow;
      } else {
        throw DbException("Invalid update operation", e);
      }
    } finally {
      await connection.close();
    }
  }
}

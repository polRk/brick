import 'demo_model.dart';
// ignore: unused_import, unused_shown_name
import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_core/core.dart' show Query;
import 'package:sqflite/sqflite.dart' show DatabaseExecutor;

Future<DemoModel> _$DemoModelFromSqlite(Map<String, dynamic> data,
    {SqliteProvider provider, repository}) async {
  return DemoModel(
      name: data['full_name'] == null ? null : data['full_name'] as String,
      assoc: data['assoc_DemoModelAssoc_brick_id'] == null
          ? null
          : (data['assoc_DemoModelAssoc_brick_id'] > -1
              ? (await repository?.getAssociation<DemoModelAssoc>(
                  Query.where('primaryKey', data['assoc_DemoModelAssoc_brick_id'] as int,
                      limit1: true),
                ))
                  ?.first
              : null),
      complexFieldName:
          data['complex_field_name'] == null ? null : data['complex_field_name'] as String,
      lastName: data['last_name'] == null ? null : data['last_name'] as String,
      manyAssoc: (await provider?.rawQuery(
              'SELECT DISTINCT `f_DemoModelAssoc_brick_id` FROM `_brick_DemoModel_many_assoc` WHERE l_DemoModel_brick_id = ?',
              [data['_brick_id'] as int])?.then((results) {
        final ids = results.map((r) => (r ?? {})['f_DemoModelAssoc_brick_id']);
        return Future.wait<DemoModelAssoc>(ids.map((primaryKey) => repository
            ?.getAssociation<DemoModelAssoc>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            ?.then((r) => (r?.isEmpty ?? true) ? null : r.first)));
      }))
          ?.toList()
          ?.cast<DemoModelAssoc>(),
      simpleBool: data['simple_bool'] == null ? null : data['simple_bool'] == 1)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DemoModelToSqlite(DemoModel instance,
    {SqliteProvider provider, repository}) async {
  return {
    'assoc_DemoModelAssoc_brick_id': instance.assoc?.primaryKey ??
        await provider?.upsert<DemoModelAssoc>(instance.assoc, repository: repository),
    'complex_field_name': instance.complexFieldName,
    'last_name': instance.lastName,
    'full_name': instance.name,
    'simple_bool': instance.simpleBool == null ? null : (instance.simpleBool ? 1 : 0)
  };
}

/// Construct a [DemoModel]
class DemoModelAdapter extends SqliteAdapter<DemoModel> {
  DemoModelAdapter();

  final String fromKey = null;
  final String toKey = null;

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: int,
    ),
    'someField': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'some_field',
      iterable: false,
      type: bool,
    ),
    'assoc': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'assoc_DemoModelAssoc_brick_id',
      iterable: false,
      type: DemoModelAssoc,
    ),
    'complexFieldName': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'complex_field_name',
      iterable: false,
      type: String,
    ),
    'lastName': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_name',
      iterable: false,
      type: String,
    ),
    'manyAssoc': RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'many_assoc',
      iterable: true,
      type: DemoModelAssoc,
    ),
    'name': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'full_name',
      iterable: false,
      type: String,
    ),
    'simpleBool': RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'simple_bool',
      iterable: false,
      type: bool,
    ),
  };

  @override
  Future<int> primaryKeyByUniqueColumns(DemoModel instance, DatabaseExecutor executor) async =>
      instance.primaryKey;

  @override
  final String tableName = 'DemoModel';
  @override
  Future<void> afterSave(instance, {provider, repository}) async {
    if (instance.primaryKey != null) {
      await Future.wait<int>(instance.manyAssoc?.map((s) async {
            final id =
                s?.primaryKey ?? await provider?.upsert<DemoModelAssoc>(s, repository: repository);
            return await provider?.rawInsert(
                'INSERT OR IGNORE INTO `_brick_DemoModel_many_assoc` (`l_DemoModel_brick_id`, `f_DemoModelAssoc_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }
  }

  @override
  Future<DemoModel> fromSqlite(Map<String, dynamic> input, {provider, repository}) async =>
      await _$DemoModelFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(DemoModel input, {provider, repository}) async =>
      await _$DemoModelToSqlite(input, provider: provider, repository: repository);
}

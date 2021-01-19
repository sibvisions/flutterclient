import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'i_database_provider.dart';

class LocalDatabase implements IDatabaseProvider {
  bool debug = true;
  Database db;
  String path;

  bool get isOpen => db != null;

  Future<void> openCreateDatabase(String path) async {
    if (this.debug) log('SQLite openCreateDatabase:' + path);
    this.db = await openDatabase(path, version: 1);
    this.path = path;
  }

  Future<void> closeDatabase() async {
    if (this.db?.isOpen ?? false) await this.db.close();
  }

  Future<bool> createTable(String tableName, String columnStr) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    String sql = "CREATE TABLE if not exists [$tableName] ($columnStr);";

    if (this.debug) {
      log('SQLite createTable:' + sql);
    }

    await this.db.execute(sql);

    return true;
  }

  Future<bool> dropTable(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    if (await this.tableExists(tableName)) {
      String sql = "DROP TABLE [$tableName];";
      await this.db.execute(sql);

      if (this.debug) {
        log('SQLite dropTable:' + sql);
      }

      if (!await this.tableExists(tableName)) return false;
    }

    return false;
  }

  Future<bool> cleanTable(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    if (await this.tableExists(tableName)) {
      String sql = "DELETE FROM [$tableName];";
      await this.db.execute(sql);

      if (this.debug) {
        log('SQLite cleanTable:' + sql);
      }

      if (!await this.tableExists(tableName)) return false;
    }

    return false;
  }

  Future<bool> tableExists(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    List<Map<String, dynamic>> result = await this.db.rawQuery(
        "SELECT COUNT(*) FROM sqlite_master WHERE type = ? AND name = ?",
        ['table', tableName]);

    return (result != null &&
        result.length > 0 &&
        result[0] != null &&
        result[0].length > 0 &&
        result[0]['COUNT(*)'] >
            0); // && result[0] is QueryRow && result[0].row[0]>0);
  }

  Future<bool> rowExists(String tableName, [String where]) async {
    if (tableName == null || this.db == null || !this.db.isOpen) {
      return false;
    }

    String sql = "SELECT * FROM [$tableName]";

    if (where != null && where.length > 0) {
      sql = "$sql WHERE $where";
    }

    if (this.debug) {
      log('SQLite rowExists:' + sql);
    }

    List<Map<String, dynamic>> result = await this.db.rawQuery(sql);
    return result.length > 0;
  }

  Future<int> rowCount(String tableName) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return 0;

    List<Map<String, dynamic>> result =
        await this.db.rawQuery("SELECT COUNT(*) FROM [$tableName]");

    if (result != null &&
        result.length > 0 &&
        result[0] != null &&
        result[0].length > 0 &&
        result[0].containsKey('COUNT(*)')) {
      return result[0]['COUNT(*)'];
    }

    return 0;
  }

  Future<List<Map<String, dynamic>>> selectRows(String tableName,
      [String where, String orderBy, String limit]) async {
    if (tableName == null || this.db == null || !this.db.isOpen) {
      return null;
    }

    String sql = "SELECT * FROM [$tableName]";

    if (where != null && where.length > 0) {
      sql = "$sql WHERE $where";
    }

    if (orderBy != null && orderBy.length > 0) {
      sql = "$sql ORDER BY $orderBy";
    }

    if (limit != null && limit.length > 0) {
      sql = "$sql LIMIT $limit";
    }

    if (this.debug) {
      log('SQLite selectRows:' + sql);
    }

    return await this.db.rawQuery(sql);
  }

  Future<bool> insert(
      String tableName, String columnString, String valueString) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    String sql =
        "INSERT INTO [$tableName] ($columnString) VALUES ($valueString)";

    if (this.debug) {
      log('SQLite insert:' + sql);
    }

    await this.db.execute(sql);

    return true;
  }

  Future<bool> update(String tableName, String setString, String where) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    if (where != null && where.length > 0) {
      where = " WHERE $where";
    } else {
      where = "";
    }

    String sql = "UPDATE [$tableName] SET $setString$where;";

    if (this.debug) {
      log('SQLite update:' + sql);
    }

    this.db.execute(sql);
    return true;
  }

  Future<bool> delete(String tableName, String where) async {
    if (tableName == null || this.db == null || !this.db.isOpen) return false;

    String sql = "DELETE FROM [$tableName] WHERE $where;";

    if (this.debug) {
      log('SQLite delete:' + sql);
    }

    this.db.execute(sql);

    return true;
  }

  static String escapeStringForSqlLite(String stringToEscape) {
    return stringToEscape.replaceAll("'", "''");
  }
}
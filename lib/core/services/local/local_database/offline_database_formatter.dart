import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import 'local_database.dart';

const String CREATE_TABLE_COLUMNS_SEPERATOR = ", ";
const String CREATE_TABLE_COLUMNS_OLD_SUFFIX = "_old";
const String CREATE_TABLE_COLUMNS_NEW_SUFFIX = "_new";
const String CREATE_TABLE_NAME_PREFIX = "off_";

const String INSERT_INTO_DATA_SEPERATOR = ", ";
const String UPDATE_DATA_SEPERATOR = ", ";
const String WHERE_AND = " AND ";

const String OFFLINE_COLUMNS_PRIMARY_KEY = "off_primaryKey";
const String OFFLINE_COLUMNS_MASTER_KEY = "off_masterKey";
const String OFFLINE_COLUMNS_STATE = "off_state";
const String OFFLINE_COLUMNS_CREATED = "off_created";
const String OFFLINE_COLUMNS_CHANGED = "off_changed";

const String OFFLINE_ROW_STATE_UPDATED = "U";
const String OFFLINE_ROW_STATE_INSERTED = "I";
const String OFFLINE_ROW_STATE_DELETED = "D";
const String OFFLINE_ROW_STATE_UNCHANGED = "";

const String OFFLINE_META_DATA_TABLE = "off_metaData";
const String OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER = "data_provider";
const String OFFLINE_META_DATA_TABLE_COLUMN_TABLE_NAME = "table_name";
const String OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID =
    "screen_comp_id";
const String OFFLINE_META_DATA_TABLE_COLUMN_DATA = "data";

class OfflineDatabaseFormatter {
  static String getRowState(Map<String, dynamic> result) {
    if (result != null && result.containsKey(OFFLINE_COLUMNS_STATE)) {
      return result[OFFLINE_COLUMNS_STATE].toString();
    }

    return null;
  }

  static dynamic getOfflinePrimaryKey(Map<String, dynamic> result) {
    if (result != null && result.containsKey(OFFLINE_COLUMNS_PRIMARY_KEY)) {
      return result[OFFLINE_COLUMNS_PRIMARY_KEY];
    }

    return null;
  }

  static dynamic getNewValue(Map<String, dynamic> result, String columnName) {
    if (result != null &&
        result.containsKey(columnName + CREATE_TABLE_COLUMNS_NEW_SUFFIX)) {
      return result[columnName + CREATE_TABLE_COLUMNS_NEW_SUFFIX];
    }

    return null;
  }

  static dynamic getOldValue(Map<String, dynamic> result, String columnName) {
    if (result != null &&
        result.containsKey(columnName + CREATE_TABLE_COLUMNS_OLD_SUFFIX)) {
      return result[columnName + CREATE_TABLE_COLUMNS_OLD_SUFFIX];
    }

    return null;
  }

  static Map<String, dynamic> getChangedValues(
      List<dynamic> onlineInsertedRow,
      List<dynamic> onlineColumnNames,
      Map<String, dynamic> offlineInsertedRow,
      List<dynamic> primaryKeyColumns) {
    Map<String, dynamic> changedValues = Map<String, dynamic>();

    if (onlineInsertedRow != null &&
        offlineInsertedRow != null &&
        onlineColumnNames != null &&
        onlineInsertedRow.length == onlineColumnNames.length) {
      for (int i = 0; i < onlineInsertedRow.length; i++) {
        String columnName = onlineColumnNames[i];
        dynamic onlineValue = onlineInsertedRow[i];
        dynamic offlineValue = getNewValue(offlineInsertedRow, columnName);
        if (onlineValue != offlineValue)
          changedValues[columnName] = offlineValue;
      }
    }

    return changedValues;
  }

  static Map<String, dynamic> getChangedValuesForUpdate(
      List<dynamic> columnNames,
      Map<String, dynamic> row,
      List<dynamic> primaryKeyColumns) {
    Map<String, dynamic> changedValues = Map<String, dynamic>();

    if (columnNames != null &&
        row != null &&
        primaryKeyColumns != null &&
        row.length == columnNames.length) {
      for (int i = 0; i < columnNames.length; i++) {
        String columnName = columnNames[i];
        if (!primaryKeyColumns.contains(columnName)) {
          dynamic oldValue = getOldValue(row, columnName);
          dynamic newValue = getNewValue(row, columnName);
          if (oldValue != oldValue) changedValues[columnName] = newValue;
        }
      }
    }

    return changedValues;
  }

  static String getStateSetString(String state) {
    switch (state) {
      case OFFLINE_ROW_STATE_DELETED:
        return "[$OFFLINE_COLUMNS_STATE] = '$OFFLINE_ROW_STATE_DELETED'$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED] = datetime('now')";
        break;
      case OFFLINE_ROW_STATE_UPDATED:
        return "[$OFFLINE_COLUMNS_STATE]='$OFFLINE_ROW_STATE_UPDATED'$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED]=datetime('now')";
        break;
      case OFFLINE_ROW_STATE_UNCHANGED:
        return "[$OFFLINE_COLUMNS_STATE]='$OFFLINE_ROW_STATE_UNCHANGED'$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED]=null";
        break;
      default:
    }

    return "";
  }

  static String getWhereFilter(
      List<dynamic> columnNames, List<dynamic> values) {
    String sqlWhere = "";
    if (columnNames != null &&
        values != null &&
        columnNames.length == values.length) {
      for (int i = 0; i < columnNames.length; i++) {
        dynamic value = values[i];
        String columnName = columnNames[i].toString();
        if (value != null)
          sqlWhere =
              "$sqlWhere[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX]='${value.toString()}'$WHERE_AND";
      }
    }

    if (sqlWhere.length > 0)
      sqlWhere = sqlWhere.substring(0, sqlWhere.length - WHERE_AND.length);

    return sqlWhere;
  }

  static String getUpdateSetString(
      List<dynamic> columnNames, List<dynamic> values) {
    String sqlSet = "";
    if (columnNames != null &&
        values != null &&
        columnNames.length == values.length) {
      for (int i = 0; i < columnNames.length; i++) {
        dynamic value = values[i];
        String columnName = columnNames[i];
        if (value == null)
          sqlSet =
              "$sqlSet[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX]=NULL$UPDATE_DATA_SEPERATOR";
        else
          sqlSet =
              "$sqlSet[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX]='${value.toString()}'$UPDATE_DATA_SEPERATOR";
      }
    }

    if (sqlSet.length > 0)
      sqlSet =
          sqlSet.substring(0, sqlSet.length - UPDATE_DATA_SEPERATOR.length);

    return sqlSet;
  }

  static String getInsertColumnList(List<dynamic> columnNames) {
    String columnList = "";

    columnNames.forEach((item) {
      columnList =
          "$columnList[$item$CREATE_TABLE_COLUMNS_OLD_SUFFIX]$INSERT_INTO_DATA_SEPERATOR[$item$CREATE_TABLE_COLUMNS_NEW_SUFFIX]$INSERT_INTO_DATA_SEPERATOR";
    });

    columnList =
        "$columnList$OFFLINE_COLUMNS_CREATED$INSERT_INTO_DATA_SEPERATOR";

    columnList = columnList.substring(
        0, columnList.length - INSERT_INTO_DATA_SEPERATOR.length);
    return columnList;
  }

  static String getInsertValueList(List<dynamic> row) {
    String insertString = "";
    if (row != null && row.length > 0) {
      // remove metaData column
      row.removeLast();

      row.forEach((item) {
        if (item != null) {
          dynamic value = item;
          if (value is String) {
            value = LocalDatabase.escapeStringForSqlLite(item);
          }
          insertString =
              "$insertString'$value'$INSERT_INTO_DATA_SEPERATOR'$value'$INSERT_INTO_DATA_SEPERATOR";
        } else {
          insertString =
              "${insertString}NULL${INSERT_INTO_DATA_SEPERATOR}NULL$INSERT_INTO_DATA_SEPERATOR";
        }
      });

      insertString =
          "${insertString}datetime('now')$INSERT_INTO_DATA_SEPERATOR";

      insertString = insertString.substring(
          0, insertString.length - INSERT_INTO_DATA_SEPERATOR.length);
    }

    return insertString;
  }

  static String getCreateTableOfflineColumns() {
    return "$OFFLINE_COLUMNS_PRIMARY_KEY INTEGER PRIMARY KEY$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_MASTER_KEY INTEGER$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_STATE TEXT DEFAULT ''$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_CREATED INTEGER$CREATE_TABLE_COLUMNS_SEPERATOR" +
        "$OFFLINE_COLUMNS_CHANGED INTEGER$CREATE_TABLE_COLUMNS_SEPERATOR";
  }

  static Map<String, dynamic> removeOfflineColumns(Map<String, dynamic> row) {
    Map<String, dynamic> cleanRows = new Map<String, dynamic>();

    row.forEach((columnName, value) {
      if (columnName.endsWith(CREATE_TABLE_COLUMNS_NEW_SUFFIX)) {
        String newColumnName = columnName.substring(
            0, columnName.length - CREATE_TABLE_COLUMNS_NEW_SUFFIX.length);
        cleanRows[newColumnName] = value;
      } else if (columnName == OFFLINE_COLUMNS_STATE) {
        cleanRows[OFFLINE_COLUMNS_STATE] = value;
      }
    });

    return cleanRows;
  }

  static Map<String, dynamic> getDataColumns(Map<String, dynamic> row,
      [List<String> columnNames]) {
    Map<String, dynamic> dataColumns = new Map<String, dynamic>();

    row.forEach((columnName, value) {
      if (columnName.endsWith(CREATE_TABLE_COLUMNS_NEW_SUFFIX)) {
        String newColumnName = columnName.substring(
            0, columnName.length - CREATE_TABLE_COLUMNS_NEW_SUFFIX.length);
        if (columnNames == null || columnNames.contains(newColumnName))
          dataColumns[newColumnName] = value;
      }
    });

    return dataColumns;
  }

  static String formatColumnForCreateTable(String columnName, String type) {
    return "[$columnName$CREATE_TABLE_COLUMNS_OLD_SUFFIX] $type $CREATE_TABLE_COLUMNS_SEPERATOR" +
        "[$columnName$CREATE_TABLE_COLUMNS_NEW_SUFFIX] $type $CREATE_TABLE_COLUMNS_SEPERATOR";
  }

  static String getDataType(CellEditor editor) {
    switch (editor.className) {
      case 'TextCellEditor':
        return "TEXT";
        break;
      case 'NumberCellEditor':
        if (editor.getProperty<int>(CellEditorProperty.SCALE) == 0)
          return "INTEGER";
        else
          return "NUMERIC";
        break;
      case 'DateCellEditor':
        return 'NUMERIC';
        break;
      case 'ImageCellEditor':
        return 'BLOB';
        break;
      case 'ChoiceCellEditor':
        return 'TEXT';
        break;
      case 'LinkedCellEditor':
        return 'TEXT';
        break;
      case 'CheckBoxCellEditor':
        return 'NUMERIC';
        break;
    }

    return 'TEXT';
  }

  static String formatTableName(String tableName) {
    if (tableName != null) {
      tableName = tableName.replaceAll(" ", "_");
      tableName = tableName.replaceAll("#", "_");
      tableName = tableName.replaceAll("!", "_");
      tableName = tableName.replaceAll("@", "_");
      tableName = tableName.replaceAll("'", "_");
      tableName = tableName.replaceAll("☺", "_");
      tableName = tableName.replaceAll("\\", "_");
      tableName = tableName.replaceAll("\"", "_");
      tableName = tableName.replaceAll("/", "_");

      tableName = CREATE_TABLE_NAME_PREFIX + tableName;
    }

    return tableName;
  }
}
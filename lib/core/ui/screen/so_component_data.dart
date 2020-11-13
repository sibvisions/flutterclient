import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../models/api/request.dart';
import '../../models/api/request/data/fetch_data.dart';
import '../../models/api/request/data/filter_data.dart';
import '../../models/api/request/data/insert_record.dart';
import '../../models/api/request/data/save_data.dart';
import '../../models/api/request/data/select_record.dart';
import '../../models/api/request/data/set_values.dart';
import '../../models/api/response/data/data_book.dart';
import '../../models/api/response/data/dataprovider_changed.dart';
import '../../models/api/response/data/filter.dart';
import '../../models/api/response/meta_data/data_book_meta_data.dart';
import '../../models/api/response/meta_data/data_book_meta_data_column.dart';
import '../../models/app/app_state.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/app/text_utils.dart';
import '../widgets/util/app_state_provider.dart';
import 'so_data_screen.dart';

class SoComponentData {
  String dataProvider;
  bool isFetchingMetaData = false;
  bool isFetching = false;

  DataBook data;
  DataBookMetaData metaData;
  SoDataScreen soDataScreen;

  List<VoidCallback> _onDataChanged = [];
  List<VoidCallback> _onMetaDataChanged = [];
  List<ValueChanged<dynamic>> _onSelectedRowChanged = [];

  SoComponentData(this.dataProvider, this.soDataScreen)
      : assert(dataProvider != null);

  bool get deleteEnabled {
    if (metaData != null && metaData.deleteEnabled != null)
      return metaData.deleteEnabled;
    return false;
  }

  bool get updateEnabled {
    if (metaData != null && metaData.updateEnabled != null)
      return metaData.updateEnabled;
    return false;
  }

  bool get insertEnabled {
    if (metaData != null && metaData.insertEnabled != null)
      return metaData.insertEnabled;
    return false;
  }

  List<String> get primaryKeyColumns {
    if (metaData != null && metaData.primaryKeyColumns != null)
      return metaData.primaryKeyColumns;
    return null;
  }

  List<dynamic> primaryKeyColumnsForRow(int index) {
    if (metaData != null && metaData.primaryKeyColumns != null)
      return metaData.primaryKeyColumns;
    return null;
  }

  void updateData(DataBook pData, [bool overrideData = false]) {
    //if (data==null || data.isAllFetched || overrideData) {
    if (data == null || overrideData) {
      if (data != null &&
          pData != null &&
          data.selectedRow != pData.selectedRow)
        _onSelectedRowChanged.forEach((d) => d(pData.selectedRow));
      data = pData;
    } else if (true /*data.isAllFetched*/) {
      if (pData.records.length > 0) {
        for (int i = pData.from; i <= pData.to; i++) {
          if ((i - pData.from) < data.records.length &&
              i < this.data.records.length) {
            List<dynamic> record = pData.records[(i - pData.from)];
            String recordState = record[record.length - 1];
            if (recordState == "I")
              this
                  .data
                  .records
                  .insert((i - pData.from), pData.records[(i - pData.from)]);
            else if (recordState == "D")
              this.data.records.removeAt((i - pData.from));
            else
              this.data.records[i] = pData.records[(i - pData.from)];
          } else {
            this.data.records.add(pData.records[(i - pData.from)]);
          }
        }
      }
      data.isAllFetched = pData.isAllFetched;
      if (data.selectedRow != pData.selectedRow)
        _onSelectedRowChanged.forEach((d) => d(pData.selectedRow));
      data.selectedRow = pData.selectedRow;
    } else {
      data.records.addAll(pData.records);
      if (data.selectedRow != pData.selectedRow)
        _onSelectedRowChanged.forEach((d) => d(pData.selectedRow));
      data.selectedRow = pData.selectedRow;
      data.isAllFetched = pData.isAllFetched;
    }

    if (data.selectedRow == null) data.selectedRow = 0;

    isFetching = false;
    _onDataChanged.forEach((d) => d());
  }

  void updateDataProviderChanged(
      BuildContext context, DataproviderChanged pDataproviderChanged) {
    _fetchData(context, pDataproviderChanged.reload, -1);
    if (data != null && pDataproviderChanged.selectedRow != null)
      updateSelectedRow(pDataproviderChanged.selectedRow);
  }

  void updateSelectedRow(int selectedRow,
      [bool raiseSelectedRowChangeEvent = false]) {
    if (data != null) {
      if (data.selectedRow == null || data.selectedRow != selectedRow) {
        data.selectedRow = selectedRow;
        if (raiseSelectedRowChangeEvent)
          _onSelectedRowChanged.forEach((d) => d(selectedRow));
        _onDataChanged.forEach((d) => d());
      }
    } else {
      print(
          "ComponentData tries to update selectedRow, but data object was null! DataProvider: " +
              this.dataProvider);
    }
  }

  void updateMetaData(DataBookMetaData pMetaData) {
    this.metaData = pMetaData;
    this.isFetchingMetaData = false;
    _onMetaDataChanged.forEach((d) => d());
  }

  dynamic getColumnData(BuildContext context, String columnName) {
    if (data != null && data.selectedRow < data.records.length) {
      return _getColumnValue(columnName);
    } else {
      this._fetchData(context, null, -1);
    }

    return "";
  }

  DataBook getData(BuildContext context, int rowCountNeeded) {
    if (isFetching == false && (data == null || !data.isAllFetched)) {
      if (rowCountNeeded >= 0 &&
          data != null &&
          data.records != null &&
          data.records.length >= rowCountNeeded) {
        return data;
      }
      if (!this.isFetching) this._fetchData(context, null, rowCountNeeded);
    }

    return data;
  }

  void selectRecord(BuildContext context, int index, [bool fetch = false]) {
    if (index < data.records.length) {
      SelectRecord select = getSelectRecordRequest(context, index, fetch);

      if (fetch != null) select.fetch = fetch;

      if (TextUtils.unfocusCurrentTextfield(context)) {
        select.soComponentData = this;
        this.soDataScreen.requestQueue.add(select);
      } else {
        BlocProvider.of<ApiBloc>(context).add(select);
      }
    } else {
      IndexError(index, data.records, "Select Record",
          "Select record failed. Index out of bounds!");
    }
  }

  SelectRecord getSelectRecordRequest(BuildContext context, int index,
      [bool fetch = false]) {
    SelectRecord select = SelectRecord(
        dataProvider,
        Filter(
            columnNames: this.primaryKeyColumns,
            values: data.getRow(index, this.primaryKeyColumns)),
        index,
        RequestType.DAL_SELECT_RECORD,
        AppStateProvider.of(context).appState.clientId);

    if (fetch != null) select.fetch = fetch;
    return select;
  }

  void deleteRecord(BuildContext context, int index) {
    if (index < data.records.length) {
      SelectRecord select = SelectRecord(
          dataProvider,
          Filter(
              columnNames: this.primaryKeyColumns,
              values: data.getRow(index, this.primaryKeyColumns)),
          index,
          RequestType.DAL_DELETE,
          AppStateProvider.of(context).appState.clientId);

      BlocProvider.of<ApiBloc>(context).add(select);
    } else {
      IndexError(index, data.records, "Delete Record",
          "Delete record failed. Index out of bounds!");
    }
  }

  void insertRecord(BuildContext context) {
    if (insertEnabled) {
      InsertRecord insert = InsertRecord(
          this.dataProvider, AppStateProvider.of(context).appState.clientId);

      BlocProvider.of<ApiBloc>(context).add(insert);
    }
  }

  void saveData(BuildContext context) {
    SaveData save = SaveData(
        this.dataProvider, AppStateProvider.of(context).appState.clientId);
    BlocProvider.of<ApiBloc>(context).add(save);
  }

  void filterData(
      BuildContext context, String value, String editorComponentId) {
    FilterData filter = FilterData(dataProvider, value, editorComponentId,
        AppStateProvider.of(context).appState.clientId, null, 0, 100);
    filter.reload = true;
    BlocProvider.of<ApiBloc>(context).add(filter);
  }

  void setValues(BuildContext context, List<dynamic> values,
      [List<dynamic> columnNames, Filter filter, bool isTextfield = false]) {
    SetValues setValues =
        SetValues(this.dataProvider, data?.columnNames, values, AppStateProvider.of(context).appState.clientId);

    if (columnNames != null) {
      columnNames.asMap().forEach((i, f) {
        if (i < values.length &&
            (filter == null || data.selectedRow == filter?.values[0])) {
          this._setColumnValue(f, values[i]);
        }
      });
      setValues.columnNames = columnNames;
    }

    if (filter != null) setValues.filter = filter;

    if (!isTextfield) {
      TextUtils.unfocusCurrentTextfield(context);

      Future.delayed(const Duration(milliseconds: 100), () {
        BlocProvider.of<ApiBloc>(context).add(setValues);
      });
    } else {
      BlocProvider.of<ApiBloc>(context).add(setValues);
    }
  }

  DataBookMetaDataColumn getMetaDataColumn(String columnName) {
    return this
        .metaData
        .columns
        .firstWhere((col) => col.name == columnName, orElse: () => null);
  }

  void _fetchData(BuildContext context, int reload, int rowCountNeeded) {
    this.isFetching = true;
    FetchData fetch = FetchData(dataProvider, sl<AppState>().clientId);

    if (reload != null && reload >= 0) {
      fetch.fromRow = reload;
      fetch.rowCount = 1;
    } else if (reload != null && reload == -1 && rowCountNeeded != -1) {
      fetch.fromRow = 0;
      fetch.rowCount = rowCountNeeded - data.records.length;
    } else if (data != null && !data.isAllFetched && rowCountNeeded != -1) {
      fetch.fromRow = data.records.length;
      fetch.rowCount = rowCountNeeded - data.records.length;
    }

    fetch.reload = (reload == -1);

    if (this.metaData == null) {
      fetch.includeMetaData = true;
      isFetchingMetaData = true;
    }

    BlocProvider.of<ApiBloc>(context).add(fetch);
  }

  dynamic _getColumnValue(String columnName) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex != null &&
        columnIndex >= 0 &&
        data.selectedRow >= 0 &&
        data.selectedRow < data.records.length) {
      dynamic value = data.records[data.selectedRow][columnIndex];
      if (value is String)
        return value;
      else
        return value;
    }

    return "";
  }

  void _setColumnValue(String columnName, dynamic value) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex != null &&
        data.selectedRow >= 0 &&
        data.selectedRow < data.records.length) {
      data.records[data.selectedRow][columnIndex] = value;
    }
  }

  int _getColumnIndex(String columnName) {
    return data?.columnNames?.indexWhere((c) => c == columnName);
  }

  void registerSelectedRowChanged(ValueChanged<dynamic> callback) {
    _onSelectedRowChanged.add(callback);
  }

  void unregisterSelectedRowChanged(ValueChanged<dynamic> callback) {
    _onSelectedRowChanged.remove(callback);
  }

  void registerDataChanged(VoidCallback callback) {
    _onDataChanged.add(callback);
  }

  void unregisterDataChanged(VoidCallback callback) {
    _onDataChanged.remove(callback);
  }

  void registerMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.add(callback);
  }

  void unregisterMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.remove(callback);
  }
}
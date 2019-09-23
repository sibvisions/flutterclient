import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

class JVxMultiLineCellEditor extends JVxCellEditor {
  List<ListTile> _items = <ListTile>[];
  String selectedValue;

  JVxMultiLineCellEditor(ComponentProperties properties, BuildContext context)
      : super(properties, context);

  void valueChanged(dynamic value) {
    this.value = value;
    getIt
        .get<JVxScreen>()
        .setValues(dataProvider, linkReference.columnNames, [value]);
  }

  List<ListTile> getItems(JVxData data) {
    List<ListTile> items = <ListTile>[];
    List<int> visibleColumnsIndex = <int>[];

    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (this.linkReference.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });

      data.records.forEach((record) {
        record.asMap().forEach((i, c) {
          items.add(getItem(c.toString(), c.toString()));
        });
      });
    }

    if (items.length == 0) items.add(getItem('loading', 'Loading...'));

    return items;
  }

  ListTile getItem(String val, String text) {
    return ListTile(
      onTap: () {
        selectedValue = val;
        valueChanged(val);
      },
      selected: selectedValue == val ? true : false,
      title: Text(text),
    );
  }

  @override
  void setInitialData(JVxData data) {
    if (data != null &&
        data.selectedRow != null &&
        data.selectedRow >= 0 &&
        data.selectedRow < data.records.length &&
        data.columnNames != null &&
        data.columnNames.length > 0 &&
        this.linkReference != null && this.linkReference.referencedColumnNames != null &&
        this.linkReference.referencedColumnNames.length > 0) {

      int columnIndex = -1;
      data.columnNames.asMap().forEach((i, c) {
        if (this.linkReference.referencedColumnNames[0] == c)
          columnIndex = i;
      });
      if (columnIndex >= 0) {
        value = data.records[data.selectedRow][columnIndex];
      }
    }

    this.setData(data);
  }

  @override
  void setData(JVxData data) {
    this._items = getItems(data);
  }

  @override
  Widget getWidget() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _items[index];
      },
    );
  }
}
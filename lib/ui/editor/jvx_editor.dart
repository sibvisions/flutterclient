import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_choice_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/i_editor.dart';

import '../../main.dart';
import '../jvx_screen.dart';
import 'celleditor/jvx_cell_editor.dart';
import 'celleditor/jvx_linked_cell_editor.dart';

class JVxEditor extends JVxComponent implements IEditor {
  Size maximumSize;
  String dataProvider;
  String dataRow;
  String columnName;
  bool readonly = false;
  bool eventFocusGained = false;
  JVxCellEditor cellEditor;
  int reload = -1;

  JVxEditor(Key componentId, BuildContext context) : super(componentId, context);

  void initData() {
    if (cellEditor?.linkReference!=null) {
      JVxData data = getIt.get<JVxScreen>().getData(cellEditor.dataProvider);
      if (data !=null) {
        cellEditor.setInitialData(data);
      }
    }
  }

  @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    maximumSize = properties.getProperty<Size>("maximumSize",null);
    dataProvider = properties.getProperty<String>("dataProvider", dataProvider);
    dataRow = properties.getProperty<String>("dataRow");
    columnName = properties.getProperty<String>("columnName", columnName);
    readonly = properties.getProperty<bool>("readonly", readonly);
    eventFocusGained = properties.getProperty<bool>("eventFocusGained", eventFocusGained);
  }

  @override
  Widget getWidget() {
    Color color = Colors.grey[200];
    if (cellEditor.linkReference!=null) {
      color = Colors.transparent;
      JVxData data = getIt.get<JVxScreen>().getData(cellEditor.linkReference.dataProvider, cellEditor.linkReference.referencedColumnNames);
      if (data !=null)
        cellEditor.setData(data);
    } else { 
      JVxData data = getIt.get<JVxScreen>().getData(this.dataProvider, [this.columnName], reload);
      reload = null;

      if (data !=null)
        cellEditor.setData(data);
    }

    if(this.cellEditor is JVxChoiceCellEditor) {
      return Container(child: this.cellEditor.getWidget());
    } else {  
    return Container(
      constraints: BoxConstraints.tightFor(),
      color: color,
      child: Container(width: 100, child: cellEditor.getWidget())
    );

    }
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/editor_component_model.dart';

import '../../model/api/response/data/data_book.dart';
import '../../model/api/response/meta_data/data_book_meta_data_column.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/screen/so_component_data.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/translations.dart';
import '../../utils/uidata.dart';
import '../editor/co_editor_widget.dart';
import '../screen.dart/so_component_creator.dart';
import 'component_model.dart';
import 'so_table_column_calculator.dart';

enum ContextMenuCommand { INSERT, DELETE }

class CoTableWidget extends CoEditorWidget {
  CoTableWidget({Key key, EditorComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  State<StatefulWidget> createState() => CoTableWidgetState();
}

class CoTableWidgetState extends CoEditorWidgetState<CoTableWidget> {
  // visible column names
  List<String> columnNames = <String>[];

  // column labels for header
  List<String> columnLabels = <String>[];

  // the show vertical lines flag.
  bool showVerticalLines = false;

  // the show horizontal lines flag.
  bool showHorizontalLines = false;

  // the show table header flag
  bool tableHeaderVisible = true;

  // table editable
  bool editable = true;

  int selectedRow;

  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _scrollPositionListener =
      ItemPositionsListener.create();
  int pageSize = 100;
  double fetchMoreItemOffset = 20;
  DataBook _data;
  List<SoTableColumn> columnInfo;
  var _tapPosition;
  SoComponentCreator componentCreator;
  bool autoResize = false;
  bool _hasHorizontalScroller = false;
  Function(int index) onRowTapped;

  TextStyle get headerStyleMandatory {
    return this.headerTextStyle;
  }

  TextStyle get headerTextStyle {
    return this.style.copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle get itemTextStyle {
    return this.style;
  }

  @override
  set data(SoComponentData data) {
    super.data?.unregisterDataChanged(onServerDataChanged);
    super.data?.unregisterSelectedRowChanged(onSelectedRowChanged);
    super.data = data;
    super.data?.registerDataChanged(onServerDataChanged);
    super.data?.registerSelectedRowChanged(onSelectedRowChanged);
  }

  /*@override
  get preferredSize {
    if (super.preferredSize!=null) 
      return super.preferredSize;
    return Size(300, 300);
  }

  @override
  get minimumSize {
    if (super.minimumSize!=null) 
      return super.minimumSize;
    return Size(300, 100);
  }*/

  /*@override
  bool get isPreferredSizeSet => true;
  @override
  bool get isMinimumSizeSet => true;
  @override
  bool get isMaximumSizeSet => maximumSize != null;
*/
  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    showVerticalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_VERTICAL_LINES, showVerticalLines);
    showHorizontalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_HORIZONTAL_LINES, showHorizontalLines);
    tableHeaderVisible = changedComponent.getProperty<bool>(
        ComponentProperty.TABLE_HEADER_VISIBLE, tableHeaderVisible);
    columnNames = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_NAMES, columnNames);
    columnLabels = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_LABELS, columnLabels);
    autoResize = changedComponent.getProperty<bool>(
        ComponentProperty.AUTO_RESIZE, autoResize);
    editable = changedComponent.getProperty<bool>(
        ComponentProperty.AUTO_RESIZE, editable);

    if (this.dataProvider == null)
      this.dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, this.dataProvider);

    int newSelectedRow =
        changedComponent.getProperty<int>(ComponentProperty.SELECTED_ROW);
    if (newSelectedRow != null &&
        newSelectedRow >= 0 &&
        newSelectedRow != selectedRow &&
        this.data != null &&
        this.data.data != null)
      this.data.updateSelectedRow(newSelectedRow, true);

    selectedRow = changedComponent.getProperty<int>(
        ComponentProperty.SELECTED_ROW, selectedRow);
  }

  void _onRowTapped(int index) {
    if (this.onRowTapped == null) {
      this.data.selectRecord(context, index);
    } else {
      this.onRowTapped(index);
    }
  }

  Widget getTableRow(
      List<Widget> children, int index, bool isHeader, bool isSelected) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white
                .withOpacity(globals.applicationStyle?.controlsOpacity ?? 1.0),
          ),
          child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1,
                          color: Colors.grey[800],
                          style: BorderStyle.solid))),
              child: Row(children: children)));
    } else {
      Color backgroundColor = Colors.white
          .withOpacity(globals.applicationStyle?.controlsOpacity ?? 1.0);

      if (isSelected)
        backgroundColor = UIData.ui_kit_color_2[100].withOpacity(0.1);
      else if (index % 2 == 1) {
        backgroundColor = Colors.grey[200]
            .withOpacity(globals.applicationStyle?.controlsOpacity ?? 1.0);
      }
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: backgroundColor),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.grey[400],
                    width: 1,
                    style: BorderStyle.solid)),
          ),
          child: Material(
              borderRadius: BorderRadius.circular(5),
              color: backgroundColor,
              child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  highlightColor: UIData.ui_kit_color_2[500].withOpacity(
                      globals.applicationStyle?.controlsOpacity ?? 1.0),
                  onTap: () {
                    _onRowTapped(index);
                  },
                  child: Row(children: children))),
        ),
      );
    }
  }

  PopupMenuItem<ContextMenuModel> _getContextMenuItem(
      IconData icon, String text, ContextMenuModel value) {
    return PopupMenuItem<ContextMenuModel>(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.grey[600],
          ),
          Text(Translations.of(context).text2(text)),
        ],
      ),
      enabled: true,
      value: value,
    );
  }

  showContextMenu(BuildContext context, int index) {
    List<PopupMenuEntry<ContextMenuModel>> popupMenuEntries =
        List<PopupMenuEntry<ContextMenuModel>>();

    if (this.data.insertEnabled) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.plusSquare,
          'Insert', ContextMenuModel(index, ContextMenuCommand.INSERT)));
    }

    if (this.data.deleteEnabled && index >= 0) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.minusSquare,
          'Delete', ContextMenuModel(index, ContextMenuCommand.DELETE)));
    }

    if (this.data.insertEnabled) {
      showMenu(
              position: RelativeRect.fromRect(_tapPosition & Size(40, 40),
                  Offset.zero & MediaQuery.of(context).size),
              context: context,
              items: popupMenuEntries)
          .then((val) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        if (val != null) {
          if (val.command == ContextMenuCommand.INSERT)
            this.data.insertRecord(context);
          else if (val.command == ContextMenuCommand.DELETE)
            this.data.deleteRecord(context, val.index);
        }
      });
    }
  }

  CoEditorWidget _getEditorForColumn(
      String text, String columnName, int index) {
    DataBookMetaDataColumn column = this.data.getMetaDataColumn(columnName);

    if (column != null) {
      CoEditorWidget clEditor = componentCreator.createEditorForTable(
          column.cellEditor, text, editable, index);
      if (clEditor != null) {
        (clEditor.componentModel as EditorComponentModel).columnName =
            columnName;
        (clEditor.componentModel as EditorComponentModel)
            .toUpdateData
            .add(this.data);
        (clEditor.componentModel as EditorComponentModel).update();
        return clEditor;
      }
    }
    return null;
  }

  Widget getTableColumn(
      String text, int rowIndex, int columnIndex, String columnName,
      {bool nullable}) {
    CoEditorWidget editor = _getEditorForColumn(text, columnName, rowIndex);
    double width = 1;

    if (columnInfo != null && columnIndex < columnInfo.length)
      width = columnInfo[columnIndex].preferredWidth;

    if (rowIndex == -1) {
      return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
            child: Container(
              child: Row(
                children: [
                  Text(text,
                      style: !nullable
                          ? headerStyleMandatory
                          : this.headerTextStyle),
                  SizedBox(
                    width: 2,
                  ),
                  !nullable
                      ? Container(
                          child: FaIcon(
                            FontAwesomeIcons.asterisk,
                            size: 8,
                          ),
                          alignment: Alignment.bottomRight,
                        )
                      : Text(''),
                ],
              ),
            ),
          ));
    } else {
      return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          width: width,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
            child: GestureDetector(
              child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  child: (editor != null)
                      ? editor
                      : Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(text, style: this.itemTextStyle),
                        )),
              onTap: () => _onRowTapped(rowIndex),
            ),
          ));
    }
  }

  Widget getHeaderRow() {
    List<Widget> children = new List<Widget>();

    if (this.columnLabels != null) {
      this.columnLabels.asMap().forEach((i, c) {
        DataBookMetaDataColumn column =
            this.data.getMetaDataColumn(columnNames[i]);
        if (column.nullable) {
          children.add(getTableColumn(c.toString(), -1, i, columnNames[i],
              nullable: column.nullable));
        } else {
          children.add(getTableColumn(c.toString(), -1, i, columnNames[i],
              nullable: column.nullable));
        }
      });
    }

    return getTableRow(children, 0, true, false);
  }

  Widget getDataRow(DataBook data, int index) {
    if (data != null && data.records != null && index < data.records.length) {
      List<Widget> children = new List<Widget>();

      data.getRow(index, columnNames).asMap().forEach((i, c) {
        children.add(getTableColumn(
            c != null ? c.toString() : "", index, i, columnNames[i]));
      });

      bool isSelected = index == data.selectedRow;
      if (this.selectedRow != null) isSelected = index == this.selectedRow;

      if (this.data.deleteEnabled && !_hasHorizontalScroller) {
        return this.editable
            ? GestureDetector(
                onLongPress: () => showContextMenu(context, index),
                child: Slidable(
                  actionExtentRatio: 0.25,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white.withOpacity(
                            globals.applicationStyle?.controlsOpacity ?? 1.0),
                      ),
                      child: getTableRow(children, index, false, isSelected)),
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    new IconSlideAction(
                      caption: Translations.of(context).text2('Delete'),
                      color: Colors.red.withOpacity(
                          globals.applicationStyle?.controlsOpacity ?? 1.0),
                      icon: Icons.delete,
                      onTap: () => this.data.deleteRecord(context, index),
                    ),
                  ],
                ))
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white.withOpacity(
                      globals.applicationStyle?.controlsOpacity ?? 1.0),
                ),
                child: getTableRow(children, index, false, isSelected));
      } else {
        return GestureDetector(
            onLongPress: () =>
                this.editable ? showContextMenu(context, index) : null,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white.withOpacity(
                        globals.applicationStyle?.controlsOpacity ?? 1.0)),
                child: getTableRow(children, index, false, isSelected)));
      }
    }

    return Container();
  }

  @override
  void onServerDataChanged() {
    setState(() {});
  }

  void onSelectedRowChanged(dynamic selectedRow) {
    if (_scrollController != null &&
        selectedRow is int &&
        selectedRow >= 0 &&
        _scrollController.isAttached) {
      _scrollController.scrollTo(
          index: selectedRow,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease);
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    if (index == 0 && tableHeaderVisible) {
      return getHeaderRow();
    } else {
      if (tableHeaderVisible) index--;
      return getDataRow(_data, index);
    }
  }

  _scrollListener() {
    ItemPosition pos = this
        ._scrollPositionListener
        .itemPositions
        .value
        .lastWhere((itemPosition) => itemPosition.itemTrailingEdge > 0,
            orElse: () => null);

    if (pos != null &&
        _data != null &&
        _data.records != null &&
        pos.index + fetchMoreItemOffset > _data.records.length) {
      this.data.getData(context, this.pageSize + _data.records.length);
    }
  }

  @override
  void initState() {
    super.initState();
    if (componentCreator == null)
      componentCreator = SoComponentCreator(context);
    _scrollPositionListener.itemPositions.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    double borderWidth = 1;
    int itemCount = tableHeaderVisible ? 1 : 0;
    _data = this.data.getData(context, pageSize);

    if (_data != null && _data.records != null)
      itemCount += _data.records.length;

    return ValueListenableBuilder(
      valueListenable: widget.componentModel,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            //print(this.rawComponentId + "- Constraints:" + constraints.toString());
            this.columnInfo = SoTableColumnCalculator.getColumnFlex(
                this.data,
                this.columnLabels,
                this.columnNames,
                itemTextStyle,
                componentCreator,
                autoResize,
                constraints.maxWidth,
                16.0,
                16.0);
            double columnWidth =
                SoTableColumnCalculator.getColumnWidthSum(this.columnInfo);
            double tableHeight =
                SoTableColumnCalculator.getPreferredTableHeight(
                    this.data,
                    this.columnLabels,
                    itemTextStyle,
                    tableHeaderVisible,
                    30,
                    30);

            _hasHorizontalScroller =
                (columnWidth + (2 * borderWidth) > constraints.maxWidth);

            Widget child = GestureDetector(
              onTapDown: (details) => _tapPosition = details.globalPosition,
              onLongPress: () =>
                  this.editable ? showContextMenu(context, -1) : null,
              child: Container(
                decoration: _hasHorizontalScroller
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: borderWidth,
                            color: UIData.ui_kit_color_2[500].withOpacity(
                                globals.applicationStyle?.controlsOpacity ??
                                    1.0)),
                        color: Colors.white.withOpacity(
                            globals.applicationStyle?.controlsOpacity ?? 1.0),
                      ),
                width: columnWidth + (2 * borderWidth),
                height: constraints.maxHeight == double.infinity
                    ? tableHeight
                    : constraints.maxHeight,
                child: ScrollablePositionedList.builder(
                  key: this.componentId,
                  itemScrollController: _scrollController,
                  itemPositionsListener: _scrollPositionListener,
                  itemCount: itemCount,
                  itemBuilder: itemBuilder,
                ),
              ),
            );

            if (_hasHorizontalScroller) {
              return Container(
                  decoration: BoxDecoration(
                      // borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(5),
                      //     topRight: Radius.circular(5)),
                      // border: Border.all(
                      //     width: borderWidth,
                      //     color: UIData.ui_kit_color_2[500].withOpacity(
                      //         globals.applicationStyle?.controlsOpacity ?? 1.0)),
                      color: Colors.white.withOpacity(
                          globals.applicationStyle?.controlsOpacity ?? 1.0)),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, child: child));
            } else {
              return child;
            }
          },
        );
      },
    );
  }
}

class ContextMenuModel {
  int index;
  ContextMenuCommand command;

  ContextMenuModel(this.index, this.command);
}
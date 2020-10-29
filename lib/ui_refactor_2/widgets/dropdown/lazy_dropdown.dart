import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_flutterclient/model/api/response/data/data_book.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_table_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/editor_component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/so_component_data.dart';
import 'package:jvx_flutterclient/utils/translations.dart';
import 'package:jvx_flutterclient/utils/uidata.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class LazyDropdown extends StatefulWidget {
  final allowNull;
  final ValueChanged<dynamic> onSave;
  final VoidCallback onCancel;
  final VoidCallback onScrollToEnd;
  final ValueChanged<String> onFilter;
  final BuildContext context;
  final double fetchMoreYOffset;
  final SoComponentData data;
  final List<String> displayColumnNames;
  final bool editable;

  LazyDropdown(
      {@required this.allowNull,
      @required this.context,
      @required this.data,
      this.editable,
      this.displayColumnNames,
      this.onSave,
      this.onCancel,
      this.onScrollToEnd,
      this.onFilter,
      this.fetchMoreYOffset = 0})
      : assert(allowNull != null),
        assert(context != null),
        assert(data != null);

  @override
  _LazyDropdownState createState() => _LazyDropdownState();
}

class _LazyDropdownState extends State<LazyDropdown> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode node = FocusNode();
  Timer filterTimer; // 200-300 Milliseconds
  dynamic lastChangedFilter;
  CoTableWidget table;

  void updateData() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) this.setState(() {});
    });
  }

  void startTimerValueChanged(dynamic value) {
    lastChangedFilter = value;
    if (filterTimer != null && filterTimer.isActive) filterTimer.cancel();

    filterTimer =
        new Timer(Duration(milliseconds: 300), onTextFieldValueChanged);
  }

  void onTextFieldValueChanged() {
    if (this.widget.onFilter != null) this.widget.onFilter(lastChangedFilter);
  }

  void _onCancel() {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onCancel != null) this.widget.onCancel();
  }

  void _onDelete() {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onSave != null) this.widget.onSave(null);
  }

  void _onRowTapped(int index) {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onSave != null) {
      dynamic value = widget.data.data.getRow(index);
      this.widget.onSave(value);
      this.updateData();
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    List<Widget> children = new List<Widget>();
    List<dynamic> row =
        widget.data.data.getRow(index, widget.displayColumnNames);

    if (row != null) {
      row.forEach((c) {
        children.add(getTableColumn(c != null ? c.toString() : "", index));
      });

      return getTableRow(children, index, false);
    }

    return Container();
  }

  Container getTableRow(List<Widget> children, int index, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[200],
          ),
          child: ListTile(title: Row(children: children)));
    } else {
      return Container(
          child: Column(
        children: [
          GestureDetector(
            onTap: () => _onRowTapped(index),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(children: children),
            ),
          ),
          Divider(
            color: Colors.grey,
            indent: 10,
            endIndent: 10,
            thickness: 0.5,
          )
        ],
      ));
    }
  }

  Widget getTableColumn(String text, int rowIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(child: Text(text), padding: EdgeInsets.all(0)),
        ));
  }

  _scrollListener() {
    if (_scrollController.offset + this.widget.fetchMoreYOffset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (this.widget.onScrollToEnd != null) this.widget.onScrollToEnd();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.data.registerDataChanged(updateData);
    _scrollController.addListener(_scrollListener);

    EditorComponentModel editorComponentModel =
        EditorComponentModel.withoutChangedComponent(false, false, true,
            widget.displayColumnNames, _onRowTapped, null, null);

    table = CoTableWidget(
      data: widget.data,
      componentModel: editorComponentModel,
    );
  }

  @override
  void dispose() {
    widget.data.unregisterDataChanged(updateData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    int itemCount = 0;
    DataBook data = widget.data.data;
    if (data != null && data.records != null) itemCount = data.records.length;

    return Dialog(
        insetPadding: EdgeInsets.fromLTRB(25, 25, 25, 25),
        elevation: 0.0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Container(
          child: Container(
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Column(
              children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                        color: UIData.ui_kit_color_2,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0))),
                    // color: UIData.ui_kit_color_2,
                    child: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Text(
                              Translations.of(context)
                                  .text2("Select item", 'Select item')
                                  .toUpperCase(),
                              style: TextStyle(
                                  color:
                                      colorScheme.brightness == Brightness.light
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface),
                            )),
                      ],
                    )),
                Container(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextFormField(
                          key: widget.key,
                          controller: _controller,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          onChanged: startTimerValueChanged,
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.black),
                          decoration: new InputDecoration(
                              hintStyle: TextStyle(color: Colors.green),
                              labelText: Translations.of(context)
                                  .text2("Search", 'Search'),
                              labelStyle: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w600)),
                        ))),
                Expanded(
                  child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 10),
                      // child: ListView.builder(
                      //   controller: _scrollController,
                      //   itemCount: itemCount,
                      //   itemBuilder: itemBuilder,
                      // ),
                      child: table),
                ),
                ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new FlatButton(
                        child: Text(
                          Translations.of(context)
                              .text2("Cancel")
                              .toUpperCase(),
                        ),
                        onPressed: _onCancel,
                      ),
                    ]),
              ],
            ),
          ),
        ));
  }
}
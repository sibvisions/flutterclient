import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../utils/text_utils.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import '../../../ui/editor/celleditor/jvx_cell_editor.dart';
import '../../../utils/globals.dart' as globals;
import '../../../utils/uidata.dart';

class JVxDateCellEditor extends JVxCellEditor {
  String dateFormat;

  get isTimeFormat {
    return dateFormat.contains("H") || dateFormat.contains("m");
  }

  get isDateFormat {
    return dateFormat.contains("d") ||
        dateFormat.contains("M") ||
        dateFormat.contains("y");
  }

  @override
  get preferredSize {
    String text = DateFormat(this.dateFormat)
        .format(DateTime.parse("2020-12-31 22:22:22Z"));

    if (text.isEmpty) text = TextUtils.averageCharactersDateField;

    double width =
        TextUtils.getTextWidth(text, Theme.of(context).textTheme.bodyText1)
            .toDouble();
    return Size(width + 16, 50);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  JVxDateCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    dateFormat =
        changedCellEditor.getProperty<String>(CellEditorProperty.DATE_FORMAT);
  }

  void onDateValueChanged(dynamic value) {
    super.onValueChanged(value);
  }

  void setDatePart(DateTime date) {
    DateTime timePart;
    if (this.value == null)
      timePart = DateTime(1970);
    else
      timePart = DateTime.fromMillisecondsSinceEpoch(this.value);

    timePart = DateTime(
        date.year,
        date.month,
        date.day,
        timePart.hour,
        timePart.minute,
        timePart.second,
        timePart.millisecond,
        timePart.microsecond);

    this.value = date.millisecondsSinceEpoch;
  }

  void setTimePart(TimeOfDay time) {
    DateTime date;
    if (this.value == null)
      date = DateTime(1970);
    else
      date = DateTime.fromMillisecondsSinceEpoch(this.value);

    date = DateTime(
        date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);

    this.value = date.millisecondsSinceEpoch;
  }

  @override
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    setEditorProperties(
        editable: editable,
        background: background,
        foreground: foreground,
        placeholder: placeholder,
        font: font,
        horizontalAlignment: horizontalAlignment);

    if (!this.isTableView) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
            color: background != null
                ? background
                : Colors.white
                    .withOpacity(globals.applicationStyle.controlsOpacity),
            borderRadius: BorderRadius.circular(
                globals.applicationStyle.cornerRadiusEditors),
            border: borderVisible
                ? (this.editable
                    ? Border.all(color: UIData.ui_kit_color_2)
                    : Border.all(color: Colors.grey))
                : null),
        child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      (this.value != null && this.value is int)
                          ? DateFormat(this.dateFormat).format(
                              DateTime.fromMillisecondsSinceEpoch(this.value))
                          : (placeholderVisible && placeholder!=null ? placeholder : ""),
                      style: (this.value != null && this.value is int)
                          ? TextStyle(
                              fontSize: 16,
                              color: this.foreground == null
                                  ? Colors.grey[700]
                                  : this.foreground)
                          : TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Icon(
                    FontAwesomeIcons.calendarAlt,
                    color: Colors.grey[600],
                  ),
                )
              ],
            ),
            onPressed: () {
              TextUtils.unfocusCurrentTextfield(context);

              return showDatePicker(
                context: context,
                locale: Locale(globals.language),
                firstDate: DateTime(1900),
                lastDate: DateTime(2050),
                initialDate: (this.value != null && this.value is int)
                    ? DateTime.fromMillisecondsSinceEpoch(this.value)
                    : DateTime.now().subtract(Duration(seconds: 1)),
              ).then((date) {
                if (date != null && isTimeFormat) {
                  this.setDatePart(date);
                  return showTimePicker(
                          context: context,
                          initialTime: (this.value != null && this.value is int)
                              ? TimeOfDay.fromDateTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      this.value))
                              : TimeOfDay.fromDateTime(DateTime.now()
                                  .subtract(Duration(seconds: 1))))
                      .then((time) {
                    if (time != null) {
                      this.setTimePart(time);
                      this.onDateValueChanged(this.value);
                    }
                  });
                } else {
                  if (date != null) {
                    this.setDatePart(date);
                    this.onDateValueChanged(this.value);
                  }
                }
              });
            }),
      );
    } else {
      if (this.value is String && int.tryParse(this.value) != null) {
        this.value = int.parse(this.value);
      }

      String text = (this.value != null && this.value is int)
          ? DateFormat(this.dateFormat)
              .format(DateTime.fromMillisecondsSinceEpoch(this.value))
          : '';
      return Text(text);
    }
  }
}

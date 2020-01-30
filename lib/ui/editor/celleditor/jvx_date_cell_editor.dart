import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxDateCellEditor extends JVxCellEditor {
  String dateFormat;

  get isTimeFormat {
    return dateFormat.contains("H") || dateFormat.contains("m");
  }

  get isDateFormat {
    return dateFormat.contains("d") || dateFormat.contains("M")|| dateFormat.contains("y");
  }

  @override
  get preferredSize {
    return Size(200,50);
  }

  @override
  get minimumSize {
    return Size(50,50);
  }

  JVxDateCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    dateFormat =
        changedCellEditor.getProperty<String>(CellEditorProperty.DATE_FORMAT);
  }

  void onDateValueChanged(dynamic value) {
    super.onValueChanged(value);
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
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: background != null ? background : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
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
                      : '',
                  style: TextStyle(
                      fontSize: 16,
                      color: this.foreground == null
                          ? Colors.grey[700]
                          : this.foreground),
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
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        return showDatePicker(
          context: context,
          locale: Locale(globals.language),
          firstDate: DateTime(1900),
          lastDate: DateTime(2050),
          initialDate: (this.value != null && this.value is int)
              ? DateTime.fromMillisecondsSinceEpoch(this.value)
              : DateTime.now().subtract(Duration(seconds: 1)),
        ).then((date) {
          /*if (date!=null && isTimeFormat) {
            return showTimePicker(
              context: context,
              initialTime: (this.value != null && this.value is int)
              ? TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(this.value))
              : TimeOfDay.fromDateTime(DateTime.now().subtract(Duration(seconds: 1)))
            ).then((time) {

            });
          } else {*/
            if (date != null) {
              this.value = date.toString();
              this.onDateValueChanged(date.millisecondsSinceEpoch);
            }
          //}
        });
        }
      ),
    );
  }
}

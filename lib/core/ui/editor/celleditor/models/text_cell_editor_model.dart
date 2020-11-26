import 'package:flutter/material.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../utils/app/text_utils.dart';
import 'cell_editor_model.dart';

class TextCellEditorModel extends CellEditorModel {
  String dateFormat;
  bool multiLine = false;
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.fromLTRB(12, 15, 12, 5);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);

  TextEditingController textController = TextEditingController();
  bool password = false;
  bool valueChanged = false;
  FocusNode focusNode = FocusNode();

  TextCellEditorModel(CellEditor cellEditor) : super(cellEditor) {
    this.multiLine = this
            .cellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('multiline') ??
        false;
    this.password = (this
            .cellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE)
            ?.contains('password') ??
        false);
  }

  @override
  get preferredSize {
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    String text = TextUtils.averageCharactersTextField;

    if (!multiLine && cellEditorValue != null) {
      text = cellEditorValue;
    }

    double width = TextUtils.getTextWidth(text, fontStyle).toDouble();
    if (multiLine)
      return Size(width + iconWidth + textPadding.horizontal, 100);
    else
      return Size(width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    return Size(10 + iconWidth + textPadding.horizontal, 100);
  }

  @override
  get tableMinimumSize {
    return this.preferredSize;
  }
}
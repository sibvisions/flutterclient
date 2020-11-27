import 'package:flutter/material.dart';

import '../../../utils/app/so_text_align.dart';
import 'co_cell_editor_widget.dart';
import 'models/text_cell_editor_model.dart';

class CoTextCellEditorWidget extends CoCellEditorWidget {
  final TextCellEditorModel cellEditorModel;

  CoTextCellEditorWidget({Key key, this.cellEditorModel})
      : super(cellEditorModel: cellEditorModel, key: key);

  @override
  State<StatefulWidget> createState() => CoTextCellEditorWidgetState();
}

class CoTextCellEditorWidgetState
    extends CoCellEditorWidgetState<CoTextCellEditorWidget> {
  void onTextFieldValueChanged(dynamic newValue) {
    if (widget.cellEditorModel.cellEditorValue != newValue) {
      widget.cellEditorModel.cellEditorValue = newValue;
      widget.cellEditorModel.valueChanged = true;
    }
  }

  void onTextFieldEndEditing() {
    widget.cellEditorModel.focusNode.unfocus();

    if (widget.cellEditorModel.valueChanged) {
      widget.cellEditorModel.onValueChanged(context,
          widget.cellEditorModel.cellEditorValue, widget.cellEditorModel.indexInTable);
      widget.cellEditorModel.valueChanged = false;
    } else if (super.onEndEditing != null) {
      super.onEndEditing();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.cellEditorModel.focusNode.addListener(() {
      if (!widget.cellEditorModel.focusNode.hasFocus) onTextFieldEndEditing();
    });
  }

  @override
  void dispose() {
    // widget.cellEditorModel.focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String controllerValue = (widget.cellEditorModel.cellEditorValue != null
        ? widget.cellEditorModel.cellEditorValue.toString()
        : "");
    widget.cellEditorModel.textController.value =
        widget.cellEditorModel.textController.value.copyWith(
            text: controllerValue,
            selection: TextSelection.collapsed(offset: controllerValue.length));

    return DecoratedBox(
      decoration: BoxDecoration(
          color: widget.cellEditorModel.background != null
              ? widget.cellEditorModel.background
              : Colors.white.withOpacity(widget.cellEditorModel.appState
                      .applicationStyle?.controlsOpacity ??
                  1.0),
          borderRadius: BorderRadius.circular(widget.cellEditorModel.appState
                  .applicationStyle?.cornerRadiusEditors ??
              10),
          border: widget.cellEditorModel.borderVisible &&
                  widget.cellEditorModel.editable != null &&
                  widget.cellEditorModel.editable
              ? Border.all(color: Theme.of(context).primaryColor)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        height: (widget.cellEditorModel.multiLine ? 100 : 50),
        child: TextField(
            textAlign: SoTextAlign.getTextAlignFromInt(
                widget.cellEditorModel.horizontalAlignment),
            decoration: InputDecoration(
                contentPadding: widget.cellEditorModel.textPadding,
                border: InputBorder.none,
                hintText: widget.cellEditorModel.placeholderVisible
                    ? widget.cellEditorModel.placeholder
                    : null,
                suffixIcon: widget.cellEditorModel.editable != null &&
                        widget.cellEditorModel.editable
                    ? Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            if (widget.cellEditorModel.cellEditorValue != null &&
                                widget.cellEditorModel.textController.text
                                    .isNotEmpty) {
                              widget.cellEditorModel.cellEditorValue = null;
                              widget.cellEditorModel.valueChanged = true;
                              super
                                  .onValueChanged(context, widget.cellEditorModel.cellEditorValue);
                              widget.cellEditorModel.valueChanged = false;
                            }
                          },
                          child: widget.cellEditorModel.textController.text
                                  .isNotEmpty
                              ? Icon(Icons.clear,
                                  size: widget.cellEditorModel.iconSize,
                                  color: Colors.grey[400])
                              : SizedBox(
                                  height: widget.cellEditorModel.iconSize,
                                  width: 1),
                        ),
                      )
                    : null),
            style: TextStyle(
                color: widget.cellEditorModel.editable != null &&
                        widget.cellEditorModel.editable
                    ? (widget.cellEditorModel.foreground != null
                        ? widget.cellEditorModel.foreground
                        : Colors.black)
                    : Colors.grey[700]),
            controller: widget.cellEditorModel.textController,
            focusNode: widget.cellEditorModel.focusNode,
            minLines: null,
            maxLines: widget.cellEditorModel.multiLine ? null : 1,
            keyboardType: widget.cellEditorModel.multiLine
                ? TextInputType.multiline
                : TextInputType.text,
            onEditingComplete: onTextFieldEndEditing,
            onChanged: onTextFieldValueChanged,
            readOnly: widget.cellEditorModel.editable != null &&
                    !widget.cellEditorModel.editable ??
                false,
            obscureText: widget.cellEditorModel.password
            //expands: this.verticalAlignment==1 && multiLine ? true : false,
            ),
      ),
    );
  }
}

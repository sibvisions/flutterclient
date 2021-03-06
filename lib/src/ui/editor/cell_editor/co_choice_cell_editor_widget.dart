import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/layout/i_alignment_constants.dart';
import 'co_cell_editor_widget.dart';
import 'models/choice_cell_editor_model.dart';

class CoChoiceCellEditorWidget extends CoCellEditorWidget {
  CoChoiceCellEditorWidget(
      {Key? key, required ChoiceCellEditorModel cellEditorModel})
      : super(cellEditorModel: cellEditorModel);

  @override
  CoCellEditorWidgetState<CoChoiceCellEditorWidget> createState() =>
      CoChoiceCellEditorWidgetState();
}

class CoChoiceCellEditorWidgetState
    extends CoCellEditorWidgetState<CoChoiceCellEditorWidget> {
  void valueChanged(dynamic value) {
    widget.cellEditorModel.cellEditorValue = value;
    this.onValueChanged!(context, value);
  }

  changeImage() {
    ChoiceCellEditorModel cellEditorModel =
        widget.cellEditorModel as ChoiceCellEditorModel;

    if ((cellEditorModel.items.indexOf(cellEditorModel.selectedImage!) + 1) <
        cellEditorModel.items.length)
      cellEditorModel.selectedImage = cellEditorModel.items[
          cellEditorModel.items.indexOf(cellEditorModel.selectedImage!) + 1];
    else
      cellEditorModel.selectedImage = cellEditorModel.items[0];

    cellEditorModel.cellEditorValue = cellEditorModel.selectedImage!.value;
    onValueChanged!(context, cellEditorModel.selectedImage!.value,
        cellEditorModel.indexInTable);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ChoiceCellEditorModel cellEditorModel =
        widget.cellEditorModel as ChoiceCellEditorModel;

    if (cellEditorModel.cellEditorValue is bool) {
      if (cellEditorModel.cellEditorValue)
        cellEditorModel.selectedImage = cellEditorModel.items[0];
      else
        cellEditorModel.selectedImage = cellEditorModel.items[1];
    } else {
      if (cellEditorModel.cellEditorValue != null &&
          (cellEditorModel.cellEditorValue as String).trim().isNotEmpty) {
        cellEditorModel.selectedImage = cellEditorModel.items[cellEditorModel
            .allowedValues!
            .indexOf(cellEditorModel.cellEditorValue)];
      } else if (cellEditorModel.defaultImage != null) {
        cellEditorModel.selectedImage = cellEditorModel.defaultImage;
      }
    }

    return Container(
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                cellEditorModel.horizontalAlignment),
            children: <Widget>[
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
              // child: ElevatedButton(
              //   style: ButtonStyle(
              //       backgroundColor:
              //           MaterialStateProperty.all(Colors.transparent)),
              //   onPressed: () => cellEditorModel.editable
              //       ? setState(() => changeImage())
              //       : null,
              //   child: cellEditorModel.selectedImage!.image,
              // ),
              child: GestureDetector(
                child: cellEditorModel.selectedImage!.image,
                onTap: () => cellEditorModel.editable
                    ? setState(() => changeImage())
                    : null,
              ))
        ]));
  }
}

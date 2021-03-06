import 'package:flutter/material.dart';

import '../../ui/layout/i_alignment_constants.dart';
import 'component_widget.dart';
import 'model/selectable_component_model.dart';

class CoRadioButtonWidget extends ComponentWidget {
  final SelectableComponentModel componentModel;

  CoRadioButtonWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoRadioButtonWidgetState();
}

class CoRadioButtonWidgetState
    extends ComponentWidgetState<CoRadioButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
            widget.componentModel.horizontalAlignment),
        children: <Widget>[
          Radio<String>(
              value: widget.componentModel.selected
                  ? '${widget.componentModel.name}'
                  : '${widget.componentModel.name}_value',
              groupValue: (widget.componentModel.selected
                  ? widget.componentModel.name
                  : '${widget.componentModel.name}_groupValue'),
              onChanged: (String? change) {
                setState(() {
                  widget.componentModel.selected =
                      !widget.componentModel.selected;
                });

                if (widget.componentModel.eventAction) {
                  widget.componentModel.onComponentValueChanged(
                      context, widget.componentModel.name, change);
                }
              }),
          widget.componentModel.text.isNotEmpty
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          widget.componentModel.text.isNotEmpty
              ? Text(widget.componentModel.text)
              : Container(),
        ],
      ),
    );
  }
}

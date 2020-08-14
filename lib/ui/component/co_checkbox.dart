import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../layout/i_alignment_constants.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/set_component_value.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'i_component.dart';
import 'component.dart';

class CoCheckbox extends Component implements IComponent {
  String text;
  bool selected = false;
  bool eventAction = false;

  CoCheckbox(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoCheckbox.withCompContext(ComponentContext componentContext) {
    return CoCheckbox(componentContext.globalKey, componentContext.context);
  }

  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    selected = changedProperties.getProperty<bool>(
        ComponentProperty.SELECTED, selected);
  }

  void valueChanged(dynamic value) {
    SetComponentValue setComponentValue = SetComponentValue(this.name, value);
    BlocProvider.of<ApiBloc>(context).dispatch(setComponentValue);
  }

  @override
  Widget getWidget() {
    return Container(
      child: Row(
        mainAxisAlignment:
            IAlignmentConstants.getMainAxisAlignment(this.horizontalAlignment),
        children: <Widget>[
          Checkbox(
            value: this.selected,
            onChanged: (bool change) =>
                (this.eventAction != null && this.eventAction)
                    ? valueChanged(change)
                    : null,
            tristate: false,
          ),
          text != null
              ? SizedBox(
                  width: 0,
                )
              : Container(),
          text != null ? Text(text) : Container(),
        ],
      ),
    );
  }
}

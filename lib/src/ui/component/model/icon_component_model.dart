import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import 'component_model.dart';

class IconComponentModel extends ComponentModel {
  String text = '';
  bool selected = false;
  bool eventAction = false;
  String image = '';

  @override
  int verticalAlignment = 2;
  @override
  int horizontalAlignment = 1;

  IconComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);

    eventAction = changedComponent.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction)!;
    selected = changedComponent.getProperty<bool>(
        ComponentProperty.SELECTED, selected)!;
    image =
        changedComponent.getProperty<String>(ComponentProperty.IMAGE, image)!;
  }
}

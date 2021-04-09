import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import 'component_model.dart';

class ChartComponentModel extends ComponentModel {
  // @override
  // get isPreferredSizeSet => this.preferredSize != null;

  // @override
  // get isMinimumSizeSet => this.minimumSize != null;

  ChartComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);
  }
}

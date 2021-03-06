import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/component_properties.dart';
import 'package:flutterclient/src/ui/component/model/component_model.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';

class LabelComponentModel extends ComponentModel {
  TextStyle fontStyle = new TextStyle(fontSize: 16.0, color: Colors.black);

  @override
  get isPreferredSizeSet => this.preferredSize != null;

  @override
  get preferredSize {
    //if (super.isPreferredSizeSet) return super.preferredSize;

    Size size = TextUtils.getTextSize(text, fontStyle, textScaleFactor);
    return Size(size.width, max(size.height, getBaseline() + 4));
  }

  @override
  get isMinimumSizeSet => this.minimumSize != null;

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    return preferredSize;
  }

  LabelComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    super.updateProperties(context, changedComponent);
    this.text = changedComponent.getProperty<String>(
        ComponentProperty.TEXT, this.text)!;
  }

  double getBaseline() {
    double labelBaseline = 30;

    if (fontStyle.fontSize != null) {
      labelBaseline = fontStyle.fontSize! / 2 + 21;
    }

    return labelBaseline;
  }
}

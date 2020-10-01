import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui/component/i_component.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_data.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

class ComponentModel extends ValueNotifier {
  String componentId;
  String parentComponentId;
  ChangedComponent currentChangedComponent;
  ComponentWidgetState componentState;
  SoComponentData data;
  String dataProvider;
  CoState coState;
  String constraints;
  bool isVisible = true;
  Size _preferredSize;
  Size _minimumSize;
  Size _maximumSize;
  String columnName;
  String dataRow;
  ButtonPressedCallback onButtonPressed;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size size) => _preferredSize = size;
  Size get minimumSize => _minimumSize;
  set minimumSize(Size size) => _minimumSize = size;
  Size get maximumSize => _maximumSize;
  set maximumSize(Size size) => _maximumSize = size;

  ComponentModel({this.currentChangedComponent}) : super(null) {
    this.compId = currentChangedComponent.id;
    this.updateProperties(this.currentChangedComponent);
  }

  void updateProperties(ChangedComponent changedComponent) {
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    isVisible = changedComponent.getProperty<bool>(
        ComponentProperty.VISIBLE, isVisible);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, _preferredSize);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, _maximumSize);
    minimumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MINIMUM_SIZE, _minimumSize);

    if (dataProvider == null)
      dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, dataProvider);

    dataRow = changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);

    if (dataProvider == null) dataProvider = dataRow;
  }

  set compId(String newComponentId) {
    componentId = newComponentId;
  }

  set changedComponent(ChangedComponent changedComponent) {
    currentChangedComponent = changedComponent;
    compId = changedComponent.id;
    notifyListeners();
  }
}
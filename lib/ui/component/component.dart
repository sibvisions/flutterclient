import 'package:flutter/material.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../model/properties/hex_color.dart';
import '../../utils/so_text_style.dart';
import 'i_component.dart';

abstract class Component implements IComponent {
  String name;
  GlobalKey componentId;
  String rawComponentId;
  CoState state = CoState.Free;
  Color background = Colors.transparent;
  Color foreground;
  TextStyle style = new TextStyle(fontSize: 16.0, color: Colors.black);
  Size _preferredSize;
  Size _minimumSize;
  Size _maximumSize;
  bool isVisible = true;
  bool enabled = true;
  String constraints = "";
  BuildContext context;
  int verticalAlignment = 1;
  int horizontalAlignment = 0;

  String parentComponentId;
  List<Key> childComponentIds;

  bool get isForegroundSet => foreground != null;
  bool get isBackgroundSet => background != null;
  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size size) => _preferredSize = size;
  Size get minimumSize => _minimumSize;
  set minimumSize(Size size) => _minimumSize = size;
  Size get maximumSize => _maximumSize;
  set maximumSize(Size size) => _maximumSize = size;

  Component(this.componentId, this.context);

  void updateProperties(ChangedComponent changedComponent) {
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, _preferredSize);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, _maximumSize);
    minimumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MINIMUM_SIZE, _minimumSize);
    rawComponentId = changedComponent.getProperty<String>(ComponentProperty.ID);
    background =
        changedComponent.getProperty<HexColor>(ComponentProperty.BACKGROUND);
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name);
    isVisible =
        changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, true);
    style = SoTextStyle.addFontToTextStyle(
        changedComponent.getProperty<String>(ComponentProperty.FONT, ""),
        style);
    foreground = changedComponent.getProperty<HexColor>(
        ComponentProperty.FOREGROUND, null);
    style = SoTextStyle.addForecolorToTextStyle(foreground, style);
    enabled =
        changedComponent.getProperty<bool>(ComponentProperty.ENABLED, true);
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
    verticalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.VERTICAL_ALIGNMENT, verticalAlignment);
    horizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/model/properties/hex_color.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_state.dart';
import 'package:jvx_flutterclient/utils/so_text_style.dart';

import 'component_widget.dart';

class CoLabelWidget extends StatefulWidget {
  final String text;

  const CoLabelWidget({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  _CoLabelWidgetState createState() => _CoLabelWidgetState();
}

class _CoLabelWidgetState extends State<CoLabelWidget> with ComponentState {
  String text = "";

  ComponentModel componentModel;

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  @override
  void initState() {
    super.initState();
    if (widget.text != null) {
      this.text = widget.text;
    }

    componentModel = ComponentWidget.of(context).widget.componentModel;

    componentModel.componentState = this;

    componentModel.addListener(
        () => updateProperties(componentModel.currentChangedComponent));
  }

  static Alignment getLabelAlignment(
      int horizontalAlignment, int verticalAlignment) {
    switch (horizontalAlignment) {
      case 0:
        switch (verticalAlignment) {
          case 0:
            return Alignment.topLeft;
          case 1:
            return Alignment.centerLeft;
          case 2:
            return Alignment.bottomLeft;
        }
        return Alignment.centerLeft;
      case 1:
        switch (verticalAlignment) {
          case 0:
            return Alignment.topCenter;
          case 1:
            return Alignment.center;
          case 2:
            return Alignment.bottomCenter;
        }
        return Alignment.center;
      case 2:
        switch (verticalAlignment) {
          case 0:
            return Alignment.topRight;
          case 1:
            return Alignment.centerRight;
          case 2:
            return Alignment.bottomRight;
        }
        return Alignment.centerRight;
    }

    return Alignment.centerLeft;
  }

  double getBaseline() {
    double labelBaseline = 30;

    if (style != null && style.fontSize != null) {
      labelBaseline = style.fontSize / 2 + 21;
    }

    return labelBaseline;
  }

  @override
  Widget build(BuildContext context) {
    TextOverflow overflow;

    if (this.isMaximumSizeSet) overflow = TextOverflow.ellipsis;

    Widget child = Container(
      padding: EdgeInsets.only(top: 0.5),
      color: this.background,
      child: Align(
        alignment: getLabelAlignment(horizontalAlignment, verticalAlignment),
        child: Baseline(
            baselineType: TextBaseline.alphabetic,
            baseline: getBaseline(),
            child: text.trim().startsWith('<html>')
                ? Html(data: text)
                : Text(
                    text,
                    style: style,
                    overflow: overflow,
                  )),
      ),
    );

    if (this.isMaximumSizeSet) {
      return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: this.maximumSize.width),
          child: child);
    } else {
      return SizedBox(key: componentId, child: child);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import 'component_widget.dart';
import 'label_component_model.dart';

class CoLabelWidget extends ComponentWidget {
  final String text;

  CoLabelWidget({this.text, LabelComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoLabelWidgetState();
}

class CoLabelWidgetState extends ComponentWidgetState<CoLabelWidget> {
  String text = '';

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
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  @override
  void initState() {
    super.initState();
    if (text.isEmpty) this.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    TextOverflow overflow;

    if (this.isMaximumSizeSet) overflow = TextOverflow.ellipsis;

    if (text.isEmpty)
      this.updateProperties(widget.componentModel.changedComponent);

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
      return SizedBox(child: child);
    }
  }
}
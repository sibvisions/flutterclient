import 'package:flutter/material.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/component_model.dart';
import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';

class CoGroupPanelWidget extends CoContainerWidget {
  CoGroupPanelWidget({@required ComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoGroupPanelWidgetState();
}

class CoGroupPanelWidgetState extends CoContainerWidgetState {
  String text = "";

  @override
  void updateProperties(ChangedComponent changedcomponent) {
    super.updateProperties(changedcomponent);
    text = changedcomponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  BoxConstraints _calculateConstraints(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight == constraints.maxHeight
            ? ((constraints.maxHeight - 31) < 0
                ? 0
                : (constraints.maxHeight - 31))
            : constraints.minHeight,
        maxHeight: (constraints.maxHeight - 31) < 0
            ? 0
            : (constraints.maxHeight - 31));
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (this.layout != null) {
      child = this.layout as Widget;
      if (this.layout.setState != null) {
        this.layout.setState(() {});
      }
    } else if (this.components.isNotEmpty) {
      child = Column(
        children: this.components,
      );
    }

    if (child != null) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight != double.infinity) {
          constraints = _calculateConstraints(constraints);
        }
        return SingleChildScrollView(
          child: Container(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              CoScrollPanelLayout(
                preferredConstraints: CoScrollPanelConstraints(constraints),
                children: [
                  CoScrollPanelLayoutId(
                      constraints: CoScrollPanelConstraints(constraints),
                      child: Card(
                          color: this.appState.applicationStyle != null
                              ? Colors.white.withOpacity(this
                                  .appState
                                  .applicationStyle
                                  ?.controlsOpacity)
                              : null,
                          margin: EdgeInsets.all(5),
                          elevation: 2.0,
                          child: child,
                          shape: this.appState.applicationStyle != null
                              ? this.appState.applicationStyle?.containerShape
                              : RoundedRectangleBorder()))
                ],
              )
            ],
          )),
        );
      });
    } else {
      return new Container();
    }
  }
}
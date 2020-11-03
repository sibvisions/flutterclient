import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'co_scroll_panel_layout.dart';
import 'i_container.dart';
import 'co_container.dart';
import '../../utils/globals.dart' as globals;

class CoGroupPanel extends CoContainer implements IContainer {
  Key key = GlobalKey();
  String text = "";

  CoGroupPanel(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoGroupPanel.withCompContext(ComponentContext componentContext) {
    return CoGroupPanel(componentContext.globalKey, componentContext.context);
  }

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

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
    }

    if (child != null) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight != double.infinity) {
          constraints = _calculateConstraints(constraints);
        }
        return SingleChildScrollView(
          key: componentId,
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
                key: this.key,
                preferredConstraints: CoScrollPanelConstraints(constraints),
                children: [
                  CoScrollPanelLayoutId(
                      key: ValueKey(this.key),
                      constraints: CoScrollPanelConstraints(constraints),
                      child: Card(
                          color: Colors.white.withOpacity(
                              globals.applicationStyle.controlsOpacity),
                          margin: EdgeInsets.all(5),
                          elevation: 2.0,
                          child: child,
                          shape: globals.applicationStyle.containerShape))
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

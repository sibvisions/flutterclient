import 'package:flutter/material.dart';
import 'i_container.dart';
import 'jvx_container.dart';

class JVxPanel extends JVxContainer implements IContainer {
  JVxPanel(Key componentId, BuildContext context) : super(componentId, context);

  Widget getWidget() {
    if (this.layout!= null) {
      return Container(
          key: componentId, 
          color: this.background, 
          child: this.layout.getWidget()
        );
    } else {
      return new Container(child: Text('No layout defined'),);
    }
  }
}
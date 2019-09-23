import 'package:flutter/material.dart';
import 'i_container.dart';
import 'jvx_container.dart';

class JVxScrollPanel extends JVxContainer implements IContainer {
  JVxScrollPanel(Key componentId, BuildContext context) : super(componentId, context);

  Widget getWidget() {
    Widget child;
    if (this.layout != null) {
      child = this.layout.getWidget();
    } else if (this.components.isNotEmpty) {
      child = this.components[0].getWidget();
    }

    if (child!= null) {
      return SingleChildScrollView( 
          child: Container(
            color: this.background, 
            child: child
          )
        );
    } else {
      return new Container();
    }
  }
}
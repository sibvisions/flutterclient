import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

class RebuildOpenScreen extends StatefulWidget {
  final Widget child;

  RebuildOpenScreen({this.child});

  static rebuildOpenScreenPage(BuildContext context) {
    final _RebuildOpenScreenState state =
      context.ancestorStateOfType(const TypeMatcher<_RebuildOpenScreenState>());

    

    state.rebuildOpenScreen();
  }

  _RebuildOpenScreenState createState() => _RebuildOpenScreenState();
}

class _RebuildOpenScreenState extends State<RebuildOpenScreen> {
  Key key = new UniqueKey();

  void rebuildOpenScreen() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.child,
    );
  }
}
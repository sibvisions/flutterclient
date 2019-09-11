import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/close_screen_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/close_screen_view_model.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class OpenScreenPage extends StatefulWidget {
  final String title;
  final List<ChangedComponent> changedComponents;
  final Key componentId;

  OpenScreenPage({Key key, this.changedComponents, this.componentId, this.title}) : super(key: key);

  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage> {

  void rebuildOpenScreen(List<ChangedComponent> data) {
    this.setState(() {
      getIt.get<JVxScreen>().updateComponents(data);
    });
  }

  @override
  void initState() {
    setState(() {
      getIt.get<JVxScreen>().componentId = widget.componentId;
      getIt.get<JVxScreen>().context = context;
      getIt.get<JVxScreen>().buttonCallback = (List<ChangedComponent> data) {
        rebuildOpenScreen(data);
      };

      getIt.get<JVxScreen>().components = <String, JVxComponent>{};
      getIt.get<JVxScreen>().title = widget.title;
      for(var i = 0; i < widget.changedComponents.length; i++){
        getIt.get<JVxScreen>().addComponent(widget.changedComponents[i], context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        CloseScreenBloc closeScreenBloc = CloseScreenBloc();
        StreamSubscription<FetchProcess> apiStreamSubscription;

        apiStreamSubscription = apiSubscription(closeScreenBloc.apiResult, context);
          
        closeScreenBloc.closeScreenController.add(
          new CloseScreenViewModel(clientId: globals.clientId, componentId: widget.componentId)
        );

        return true;
      },
      child: Scaffold(
        key: widget.componentId,
        appBar: AppBar(
          title: Text(getIt.get<JVxScreen>().title),
        ),
        body: getIt.get<JVxScreen>().getWidget(),
      ),
    );
  }
}
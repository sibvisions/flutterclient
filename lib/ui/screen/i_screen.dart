import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/screen/component_creator.dart';
import 'package:jvx_mobile_v3/ui/screen/component_screen.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/api/response/meta_data/jvx_meta_data.dart';
import '../../model/api/response/screen_generic.dart';

abstract class IScreen {
  ComponentScreen componentScreen;

  factory IScreen(ComponentCreator componentCreator, IScreen customScreen) =>
      customScreen != null ? customScreen : JVxScreen(componentCreator);

  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData,
      ScreenGeneric genericScreen);
  Widget getWidget();
}

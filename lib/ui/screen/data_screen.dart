
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/request/press_button.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'package:jvx_mobile_v3/model/action.dart' as jvxAction;

class DataScreen {
  BuildContext context;
  List<ComponentData> componentData = <ComponentData>[];

  void updateData(Request request, List<JVxData> data, List<JVxMetaData> metaData) {

    if(request is SelectRecord && request.requestType==RequestType.DAL_DELETE) {
      ComponentData cData = getComponentData(request.dataProvider);
      cData.data.deleteLocalRecord(request.filter);
    }

    if (request==null || request?.requestType!=RequestType.DAL_SET_VALUE) {
      data?.forEach((d) {
        ComponentData cData = getComponentData(d.dataProvider);
        cData.updateData(d, request.reload);
      });

      metaData?.forEach((m) {
        ComponentData cData = getComponentData(m.dataProvider);
        cData.updateMetaData(m);
      });
    }

    if (request != null && request.requestType==RequestType.DAL_SELECT_RECORD && (request is SelectRecord)) {
      ComponentData cData = getComponentData(request.dataProvider);
      cData?.updateSelectedRow(request.selectedRow);
    }

  }

  ComponentData getComponentData(String dataProvider) {
    ComponentData data;
    if (componentData.length>0)
      data = componentData.firstWhere((d) => d.dataProvider == dataProvider, orElse: () => null);

    if (data==null) {
      data = ComponentData(dataProvider);
      //data.addToRequestQueue = this._addToRequestQueue;
      componentData.add(data);
    }

    return data;
  }

  void onButtonPressed(String componentId, String label) {
    // wait until textfields focus lost. 10 millis should do it.
    Future.delayed(const Duration(milliseconds: 10), () {
      PressButton pressButton = PressButton(jvxAction.Action(componentId: componentId, label: label));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });
  }
}
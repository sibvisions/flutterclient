
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';

class DataScreen {
  BuildContext context;
  List<ComponentData> componentData = <ComponentData>[];

  Queue<Request> _requestQueue = Queue<Request>();

  void updateData(Request request, List<JVxData> data, List<JVxMetaData> metaData) {

    data?.forEach((d) {
      ComponentData cData = getComponentData(d.dataProvider);
      cData.updateData(d, (request.requestType==RequestType.DAL_FILTER));
    });

    metaData?.forEach((m) {
      ComponentData cData = getComponentData(m.dataProvider);
      cData.updateMetaData(m);
    });

    if (request != null && request.requestType==RequestType.DAL_SELECT_RECORD && (request is SelectRecord)) {
      ComponentData cData = getComponentData(request.dataProvider);
      cData?.updateSelectedRow(request.selectedRow);
    }

    _requestQueue.remove(request);
    _sendFromQueue();
  }

  ComponentData getComponentData(String dataProvider) {
    ComponentData data;
    if (componentData.length>0)
      data = componentData.firstWhere((d) => d.dataProvider == dataProvider, orElse: () => null);

    if (data==null) {
      data = ComponentData(dataProvider);
      data.addToRequestQueue = this._addToRequestQueue;
      componentData.add(data);
    }

    return data;
  }

  void _addToRequestQueue(Request request) {
    _requestQueue.add(request);

    if (_requestQueue.length==1)
      _sendFromQueue();
  }

  void _sendFromQueue() {
    if (_requestQueue.length>0) {
      Request request = _requestQueue.first;
      if (!request.isProcessing) {
          request.isProcessing = true;
          BlocProvider.of<ApiBloc>(context).dispatch(request);
      }
    }
  }
}
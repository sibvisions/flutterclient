import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';
import 'package:latlong/latlong.dart';

import 'component_widget.dart';
import 'model/map_component_model.dart';

class CoMapWidget extends ComponentWidget {
  final MapComponentModel componentModel;

  CoMapWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoMapWidgetState();
}

class CoMapWidgetState extends ComponentWidgetState<CoMapWidget> {
  late MapController _controller;

  @override
  void initState() {
    _controller = MapController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      SoScreenState screen = SoScreen.of(context)!;

      if (widget.componentModel.groupsDataBook != null) {
        widget.componentModel.groupsComponentData =
            screen.getComponentData(widget.componentModel.groupsDataBook!);

        widget.componentModel.groupsComponentData
            ?.registerDataChanged(widget.componentModel.onGroupDataChanged);

        widget.componentModel.groupsComponentData?.getData(context, -1);
      }

      if (widget.componentModel.pointsDataBook != null) {
        widget.componentModel.pointsComponentData =
            screen.getComponentData(widget.componentModel.pointsDataBook!);

        widget.componentModel.pointsComponentData
            ?.registerDataChanged(widget.componentModel.onPointDataChanged);

        widget.componentModel.pointsComponentData?.getData(context, -1);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.componentModel.pointsComponentData?.data != null &&
        widget.componentModel.groupsComponentData?.data != null) {
      return FlutterMap(
        mapController: _controller,
        options: MapOptions(
            onTap: (LatLng latlng) =>
                widget.componentModel.onPointSelection(context, latlng),
            zoom: widget.componentModel.zoomLevel.toDouble()),
        children: [
          if (widget.componentModel.points.isNotEmpty)
            MarkerLayerWidget(
                options:
                    MarkerLayerOptions(markers: widget.componentModel.points)),
          if (widget.componentModel.groups.isNotEmpty)
            PolygonLayerWidget(
                options: PolygonLayerOptions(
                    polygons: widget.componentModel.groups)),
          TileLayerWidget(
              options: TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c']))
        ],
      );
    } else {
      return Center(
        child: Text('Loading...'),
      );
    }
  }
}

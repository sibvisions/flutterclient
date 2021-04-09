import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

import 'component_widget.dart';
import 'model/chart_component_model.dart';

class CoChartWidget extends ComponentWidget {
  final ChartComponentModel componentModel;

  CoChartWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoChartWidgetState();
}

class CoChartWidgetState extends ComponentWidgetState<CoChartWidget> {
  List<Series> seriesList = <Series>[];
  bool animate = true;

  @override
  void initState() {
    super.initState();
    seriesList = _createRandomData();
  }

  static List<Series<LinearSales, num>> _createRandomData() {
    final random = new Random();

    final data = [
      new LinearSales(0, random.nextInt(100)),
      new LinearSales(1, random.nextInt(100)),
      new LinearSales(2, random.nextInt(100)),
      new LinearSales(3, random.nextInt(100)),
    ];

    return [
      new Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  Widget _getChart() {
    return LineChart(seriesList, animate: animate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.componentModel.text!.isEmpty)
      widget.componentModel
          .updateProperties(context, widget.componentModel.changedComponent);

    return SizedBox(
      width: 50,
      height: 50,
      child: _getChart(),
    );
  }
}

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

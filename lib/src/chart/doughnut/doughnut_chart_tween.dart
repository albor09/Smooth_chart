import 'package:flutter/widgets.dart';
import 'package:smooth_chart/src/chart/doughnut/doughnut_chart_data.dart';

class DoughnutChartTween extends Tween<DoughnutChartData> {
  DoughnutChartTween(
      {required DoughnutChartData begin, required DoughnutChartData end})
      : super(begin: begin, end: end);

  @override
  DoughnutChartData lerp(double t) {
    return begin!.lerp(begin!, end!, t);
  }
}

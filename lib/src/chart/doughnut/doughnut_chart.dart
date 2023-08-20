import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:smooth_chart/src/utils.dart';

import 'doughnut_chart_data.dart';
import 'doughnut_chart_paint.dart';
import 'doughnut_chart_tween.dart';

class DoughnutChart extends ImplicitlyAnimatedWidget {
  final DoughnutChartData data;

  DoughnutChart(
    this.data, {
    super.key,
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve animationCurve = Curves.linear,
  }) : super(duration: animationDuration, curve: animationCurve);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      DoughnutChartState();
}

class DoughnutChartState extends AnimatedWidgetBaseState<DoughnutChart> {
  DoughnutChartTween? _doughnutChartTween;
  DoughnutChartData? _evaluatedData;

  @override
  Widget build(BuildContext context) {
    double valueScale = getValueScale();
    double size = getMaxRadius() * 2;
    _evaluatedData = _doughnutChartTween!.evaluate(animation);

    return GestureDetector(
      onTapUp: (details) {
        if (widget.data.onSegmentPress == null ||
            animation.status == AnimationStatus.forward ||
            animation.status == AnimationStatus.reverse) return;
        double x = details.localPosition.dx - size / 2;
        double y = details.localPosition.dy - size / 2;
        double distance = distanceBetweenPoints(Offset.zero, Offset(x, y));
        double angleToX = toDegress(atan2(y, x) - pi / 2) * -1;
        double angle = angleToX > 0 ? angleToX : 180 + (180 - angleToX * -1);
        double currentAngle = 0;
        for (var i = 0; i < widget.data.segments.length; i++) {
          DoughnutSegmentData segment = widget.data.segments[i];
          double sweepAngle =
              segment.value * valueScale + widget.data.segmentSpacing;
          if (angle > currentAngle &&
              angle < currentAngle + sweepAngle &&
              distance > segment.radius! - segment.width! &&
              distance < segment.radius!) {
            widget.data.onSegmentPress!(i);
            return;
          }
          currentAngle += sweepAngle;
        }
        widget.data.onSegmentPress!(-1);
      },
      child: Container(
        width: size,
        height: size,
        child: CustomPaint(
          painter: DoughnutChartPaint(
              _doughnutChartTween!.evaluate(animation), valueScale),
        ),
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _doughnutChartTween =
        visitor(_doughnutChartTween, widget.data, (dynamic value) {
      return DoughnutChartTween(
          begin: value as DoughnutChartData, end: widget.data);
    }) as DoughnutChartTween?;
  }

  double getMaxRadius() {
    double max = 0;
    widget.data.segments.forEach((element) {
      if (element.radius! > max) max = element.radius!;
    });
    return max;
  }

  double getValueScale() {
    DoughnutChartData data = _doughnutChartTween!.evaluate(animation);
    double sum = 0;
    for (var element in data.segments) {
      sum += element.value;
    }
    return (360 - data.segmentSpacing * data.segments.length) / sum;
  }
}

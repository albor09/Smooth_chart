import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'doughnut_chart_data.dart';
import 'package:smooth_chart/src/utils.dart';

class DoughnutChartPaint extends CustomPainter {
  final DoughnutChartData data;

  final double valueScale;

  DoughnutChartPaint(this.data, this.valueScale);

  @override
  void paint(Canvas canvas, Size size) {
    double currentAngle = data.angleOffset;
    for (var i = 0; i < data.segments.length; i++) {
      double totalSweepAngle = data.segments[i].value * valueScale;
      drawSegment(canvas, currentAngle, totalSweepAngle, data.segments[i],
          Offset(size.width / 2, size.height / 2));
      currentAngle += totalSweepAngle + data.segmentSpacing;
    }
  }

  void drawSegment(Canvas canvas, double startAngle, double sweepAngle,
      DoughnutSegmentData segmentData, Offset offset) {
    Path path = Path();
    Paint paint = Paint()
      ..color = segmentData.color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..isAntiAlias = true;

    double clamped = clampDouble(sweepAngle, -180, 180);

    double x0 = segmentData.radius! * sin(toRadians(startAngle)) + offset.dx;
    double y0 = segmentData.radius! * cos(toRadians(startAngle)) + offset.dy;

    path.moveTo(x0, y0);

    double x1 =
        segmentData.radius! * sin(toRadians(startAngle + clamped)) + offset.dx;
    double y1 =
        segmentData.radius! * cos(toRadians(startAngle + clamped)) + offset.dy;

    path.arcToPoint(Offset(x1, y1),
        radius: Radius.circular(segmentData.radius!),
        clockwise: sweepAngle > 0 ? false : true);

    if (sweepAngle > 180) {
      x1 = segmentData.radius! *
              sin(toRadians(startAngle + 180 + (sweepAngle - 180))) +
          offset.dx;
      y1 = segmentData.radius! *
              cos(toRadians(startAngle + 180 + (sweepAngle - 180))) +
          offset.dy;

      path.arcToPoint(Offset(x1, y1),
          radius: Radius.circular(segmentData.radius!),
          clockwise: sweepAngle > 0 ? false : true);
    }

    double x2 = (segmentData.radius! - segmentData.width!) *
            sin(toRadians(startAngle + sweepAngle)) +
        offset.dx;
    double y2 = (segmentData.radius! - segmentData.width!) *
            cos(toRadians(startAngle + sweepAngle)) +
        offset.dy;

    path.arcToPoint(Offset(x2, y2),
        radius: Radius.circular(1), clockwise: sweepAngle > 0 ? false : true);

    double x3 = (segmentData.radius! - segmentData.width!) *
            sin(toRadians(startAngle + sweepAngle - clamped)) +
        offset.dx;
    double y3 = (segmentData.radius! - segmentData.width!) *
            cos(toRadians(startAngle + sweepAngle - clamped)) +
        offset.dy;

    path.arcToPoint(Offset(x3, y3),
        radius: Radius.circular(segmentData.radius! - segmentData.width!),
        clockwise: sweepAngle > 0 ? true : false);

    if (sweepAngle > 180) {
      x3 = (segmentData.radius! - segmentData.width!) *
              sin(toRadians(startAngle)) +
          offset.dx;
      y3 = (segmentData.radius! - segmentData.width!) *
              cos(toRadians(startAngle)) +
          offset.dy;
      path.arcToPoint(Offset(x3, y3),
          radius: Radius.circular(segmentData.radius! - segmentData.width!),
          clockwise: sweepAngle > 0 ? true : false);
    }
    path.arcToPoint(Offset(x0, y0),
        radius: Radius.circular(1), clockwise: sweepAngle > 0 ? false : true);

    paint.shader = segmentData.gradient?.createShader(Rect.fromPoints(
        Offset([x0, x1, x2, x3].reduce(min), [y0, y1, y2, y3].reduce(min)),
        Offset([x0, x1, x2, x3].reduce(max), [y0, y1, y2, y3].reduce(max))));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as DoughnutChartPaint).data != data;
  }
}

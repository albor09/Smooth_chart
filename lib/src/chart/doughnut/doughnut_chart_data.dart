import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_chart/src/chart/base/base_chart_data.dart';
import 'package:smooth_chart/src/chart/base/lerping_data.dart';

class DoughnutChartData implements LerpingData<DoughnutChartData> {
  final List<DoughnutSegmentData> segments;
  final double segmentSpacing;
  final double angleOffset;
  final void Function(int selectedInd)? onSegmentPress;

  DoughnutChartData(
      {required List<DoughnutSegmentData> segments,
      this.onSegmentPress,
      this.angleOffset = 0,
      this.segmentSpacing = 0})
      : this.segments =
            segments.where((element) => element.value != 0).toList();

  @override
  DoughnutChartData lerp(DoughnutChartData a, DoughnutChartData b, double t) {
    return DoughnutChartData(
        segments: lerpSegments(a.segments, b.segments, t),
        segmentSpacing: lerpDouble(a.segmentSpacing, b.segmentSpacing, t)!,
        angleOffset: lerpDouble(a.angleOffset, b.angleOffset, t)!,
        onSegmentPress: b.onSegmentPress);
  }

  List<DoughnutSegmentData> lerpSegments(
      List<DoughnutSegmentData> a, List<DoughnutSegmentData> b, double t) {
    List<DoughnutSegmentData> segments = [];

    if (b.length >= a.length) {
      for (var i = 0; i < b.length; i++) {
        if (a.length > i) {
          segments.add(a[i].lerp(a[i], b[i], t));
        } else {
          segments.add(b[i].lerp(
              DoughnutSegmentData(
                  value: 0, color: Colors.transparent, radius: 0, width: 0),
              b[i],
              t));
        }
      }
    } else {
      for (var i = 0; i < a.length; i++) {
        if (b.length > i) {
          segments.add(b[i].lerp(a[i], b[i], t));
        } else {
          segments.add(a[i].lerp(
              a[i],
              DoughnutSegmentData(
                  value: 0, color: Colors.transparent, radius: 0, width: 0),
              t));
        }
      }
    }

    return segments;
  }

  // double calculateValueScale(List<>) {
  //   double sum = 0;
  //   for (var element in this.segments) {
  //     sum += element.value;
  //   }
  //   return
  // }
}

class DoughnutSegmentData implements LerpingData<DoughnutSegmentData> {
  final double value;
  final Color color;
  final double? radius;
  final double? width;
  final LinearGradient? gradient;

  late UniqueKey id;

  DoughnutSegmentData(
      {required this.value,
      required this.color,
      this.radius = 60,
      this.width = 8,
      this.gradient,
      UniqueKey? id}) {
    if (id == null)
      this.id = UniqueKey();
    else
      this.id = id;
  }

  DoughnutSegmentData copyWith(
      {double? value,
      Color? color,
      double? radius,
      double? width,
      LinearGradient? gradient,
      UniqueKey? id}) {
    return DoughnutSegmentData(
        value: value ?? this.value,
        color: color ?? this.color,
        radius: radius ?? this.radius,
        width: width ?? this.width,
        gradient: gradient ?? this.gradient,
        id: id ?? this.id);
  }

  @override
  DoughnutSegmentData lerp(
      DoughnutSegmentData a, DoughnutSegmentData b, double t) {
    return DoughnutSegmentData(
        value: lerpDouble(a.value, b.value, t)!,
        color: Color.lerp(a.color, b.color, t)!,
        radius: lerpDouble(a.radius, b.radius, t),
        width: lerpDouble(a.width, b.width, t),
        gradient: a.gradient != null && b.gradient != null
            ? LinearGradient(colors: [
                Color.lerp(a.gradient?.colors[0], b.gradient?.colors[0], t)!,
                Color.lerp(a.gradient?.colors[1], b.gradient?.colors[1], t)!,
              ])
            : b.gradient,
        id: b.id);
  }
}

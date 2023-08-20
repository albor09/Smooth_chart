import 'dart:math';
import 'dart:ui';

double toRadians(double degress) => degress * pi / 180.0;

double toDegress(double radians) => radians * 180 / pi;

double distanceBetweenPoints(Offset a, Offset b) {
  return sqrt((b.dx - a.dx) * (b.dx - a.dx) + (b.dy - a.dy) * (b.dy - a.dy));
}

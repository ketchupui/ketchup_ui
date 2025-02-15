import 'dart:ui';

Color darkenColor(Color color, double factor) {
  int r = (color.r * factor).toInt();
  int g = (color.g * factor).toInt();
  int b = (color.b * factor).toInt();

  // 确保每个分量不小于0
  r = r < 0 ? 0 : r;
  g = g < 0 ? 0 : g;
  b = b < 0 ? 0 : b;

  return Color.fromRGBO(r, g, b, color.a);
}

extension ColorExtension on Color {
  Color darkenColor(double factor) {
    int r = (this.r * factor).toInt();
    int g = (this.g * factor).toInt();
    int b = (this.b * factor).toInt();

    // 确保每个分量不小于0
    r = r < 0 ? 0 : r;
    g = g < 0 ? 0 : g;
    b = b < 0 ? 0 : b;

    return Color.fromRGBO(r, g, b, a);
  }
}
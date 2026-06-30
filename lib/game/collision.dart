import 'dart:ui';

class Collision {
  static bool intersects(Rect a, Rect b) {
    return a.overlaps(b.deflate(6));
  }
}

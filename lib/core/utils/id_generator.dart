import 'dart:math';

class IdGenerator {
  static String generate() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(999).toString();
  }
}

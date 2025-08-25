import 'dart:math';

String generateRandomKey(int length) {
  const String _chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  Random random = Random();
  String result = '';
  for (int i = 0; i < length; i++) {
    result += _chars[random.nextInt(_chars.length)];
  }
  return result;
}
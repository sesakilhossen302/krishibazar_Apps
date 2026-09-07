import 'english.dart';

class Translator {
  static String translate(String key) {
    return english[key] ?? key;
  }
}

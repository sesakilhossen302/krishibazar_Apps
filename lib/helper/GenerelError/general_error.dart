class GeneralError {
  static String handle(dynamic error) {
    return error?.toString() ?? "একটি অজানা ত্রুটি ঘটেছে";
  }
}

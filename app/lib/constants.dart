class AppConstants {

  AppConstants._();

  static const String appName =
      "Journey Planner AI";

  static const String baseUrl =
      "http://10.0.2.2:8000";

  static const double defaultPadding = 16.0;

  static const double cardRadius = 16.0;

  static const double buttonRadius = 12.0;

  static const List<String> transports = [
    "car",
    "bike",
    "bus",
    "train",
    "flight",
  ];

  static const List<String> groupTypes = [
    "couple",
    "family",
    "friends",
  ];
}
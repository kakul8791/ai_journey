import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  // Emulator ke liye:
  // Android Emulator => 10.0.2.2
  // Real Device => Laptop IP (e.g. 192.168.1.5)

  static const String baseUrl =
      "http://10.0.2.2:8000";

  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {

        return jsonDecode(response.body);
      }

      throw Exception(
        "Server Error: ${response.statusCode}",
      );

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getRequest(
    String endpoint,
  ) async {

    try {

      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {

        return jsonDecode(response.body);
      }

      throw Exception(
        "Server Error: ${response.statusCode}",
      );

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ---------------------------
  // CHAT API
  // ---------------------------

  Future<Map<String, dynamic>> chat({
    required String message,
    List<Map<String, dynamic>> history =
        const [],
  }) async {

    return await postRequest(
      "/chat",
      {
        "message": message,
        "session_id": "flutter_app",
        "history": history,
      },
    );
  }

  // ---------------------------
  // RECOMMENDATION API
  // ---------------------------

  Future<Map<String, dynamic>> recommend({
    required String groupType,
    required double budget,
    required int days,
    required String origin,
    required double maxDistanceKm,
    required int numPeople,
    required List<String> preferences,
  }) async {

    return await postRequest(
      "/recommend",
      {
        "group_type": groupType,
        "budget": budget,
        "days": days,
        "origin": origin,
        "max_distance_km": maxDistanceKm,
        "num_people": numPeople,
        "preferences": preferences,
      },
    );
  }

  // ---------------------------
  // FUEL API
  // ---------------------------

  Future<Map<String, dynamic>> fuelEstimate({
    required String placeId,
    required String origin,
    required String transport,
    required int numPeople,
    required double budget,
    required int days,
    required String groupType,
  }) async {

    return await postRequest(
      "/fuel",
      {
        "place_id": placeId,
        "origin": origin,
        "transport": transport,
        "num_people": numPeople,
        "budget": budget,
        "days": days,
        "group_type": groupType,
      },
    );
  }

  // ---------------------------
  // ITINERARY API
  // ---------------------------

  Future<Map<String, dynamic>> itinerary({
    required String placeId,
    required String origin,
    required String transport,
    required int numPeople,
    required double budget,
    required int days,
    required String groupType,
  }) async {

    return await postRequest(
      "/itinerary",
      {
        "place_id": placeId,
        "origin": origin,
        "transport": transport,
        "num_people": numPeople,
        "budget": budget,
        "days": days,
        "group_type": groupType,
      },
    );
  }

  // ---------------------------
  // FEEDBACK API
  // ---------------------------

  Future<Map<String, dynamic>> submitFeedback({
    required String placeId,
    required int rating,
    required String groupType,
    required String budgetRange,
  }) async {

    return await postRequest(
      "/feedback",
      {
        "place_id": placeId,
        "rating": rating,
        "group_type": groupType,
        "budget_range": budgetRange,
      },
    );
  }

  // ---------------------------
  // HEALTH API
  // ---------------------------

  Future<Map<String, dynamic>> healthCheck()
  async {
    return await getRequest("/health");
  }
}
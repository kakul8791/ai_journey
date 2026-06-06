import 'dart:convert';
import 'package:http/http.dart' as http;

//const String BASE_URL = 'http://10.0.2.2:8000';
 // Android emulator → localhost
const String BASE_URL = 'http://localhost:8000';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  // ── Chat / NLP ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> chat({
    required String message,
    required List<Map<String, dynamic>> history,
    String sessionId = 'default',
  }) async {
    final res = await _client.post(
      Uri.parse('$BASE_URL/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'session_id': sessionId,
        'history': history,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Chat API error: ${res.statusCode}');
  }

  // ── Recommend ──────────────────────────────────────────────────────────

  Future<List<dynamic>> recommend(Map<String, dynamic> tripParams) async {
    final res = await _client.post(
      Uri.parse('$BASE_URL/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tripParams),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['recommendations'];
    }
    throw Exception('Recommend API error: ${res.statusCode}');
  }

  // ── Fuel ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fuelEstimate(Map<String, dynamic> params) async {
    final res = await _client.post(
      Uri.parse('$BASE_URL/fuel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Fuel API error: ${res.statusCode}');
  }

  // ── Itinerary ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> buildItinerary(Map<String, dynamic> params) async {
    final res = await _client.post(
      Uri.parse('$BASE_URL/itinerary'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Itinerary API error: ${res.statusCode}');
  }

  // ── Feedback ──────────────────────────────────────────────────────────

  Future<void> sendFeedback(Map<String, dynamic> params) async {
    await _client.post(
      Uri.parse('$BASE_URL/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/approaching_bus.dart';
import '../models/ml_status.dart';
import '../models/stop_meta.dart';
import '../models/stop_summary.dart';

/// Backend base URL.
///
/// **Debug** (Android emülatör): otomatik `http://10.0.2.2:3142`
/// **Release**: `https://gorisle.dalciksoft.com`
///
/// Elle ayarlamak için:
/// ```bash
/// flutter run --dart-define=API_BASE=http://10.0.2.2:3142
/// ```
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 15);

  // --dart-define=API_BASE=... ile explicit set edilebilir
  static const String _envBase = String.fromEnvironment('API_BASE');

  /// Debug modda lokal sunucu, release'de üretim sunucusu.
  static String get baseUrl {
    if (_envBase.isNotEmpty) return _envBase.replaceAll(RegExp(r'/+$'), '');
    if (kDebugMode) return 'http://10.0.2.2:3142';
    return 'https://gorisle.dalciksoft.com';
  }

  /// Tüm duraklar + en yakın şablon sefer özeti (sunucu verisi).
  Future<List<StopSummary>> fetchStopSummaries() async {
    final uri = Uri.parse('$baseUrl/api/v1/stops');
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => StopSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Durak adı / erişilebilirlik (detay başlığı için).
  Future<StopMeta?> fetchStopMeta(String durakKodu) async {
    final encoded = Uri.encodeComponent(durakKodu);
    final uri = Uri.parse('$baseUrl/api/v1/stops/$encoded');
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return StopMeta.fromJson(map);
  }

  Future<List<ApproachingBus>> fetchApproachingBuses(String durakKodu) async {
    final encoded = Uri.encodeComponent(durakKodu);
    final uri = Uri.parse('$baseUrl/api/v1/stops/$encoded/approaching-buses');
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => ApproachingBus.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ML köprüsü (Python FastAPI) durumu. Ağ hatasında `null` döner.
  Future<MlStatus?> fetchMlStatus() async {
    final uri = Uri.parse('$baseUrl/api/v1/ml/status');
    try {
      final response = await _client.get(uri);
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      if (map == null) return null;
      return MlStatus.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}

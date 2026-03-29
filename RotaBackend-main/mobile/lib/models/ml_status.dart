import 'stop_summary.dart' show jsonBool;

/// Response from GET /api/v1/ml/status (Node proxy to Python bridge).
class MlStatus {
  const MlStatus({
    required this.mlEnabled,
    this.bridgeOk,
    this.modelsLoaded,
    this.note,
    this.bridgeError,
  });

  final bool mlEnabled;
  final bool? bridgeOk;
  final bool? modelsLoaded;
  final String? note;
  final String? bridgeError;

  /// Yeşil şerit: ML açık, köprü OK ve Python açıkça [ml_loaded: false] dememiş.
  bool get isLiveMl =>
      mlEnabled && bridgeOk == true && modelsLoaded != false;

  factory MlStatus.fromJson(Map<String, dynamic> json) {
    final bridgeMap = _jsonMap(json['bridge']);
    bool? bridgeOk;
    bool? modelsLoaded;
    String? bridgeError;

    if (bridgeMap != null) {
      final okVal = bridgeMap['ok'];
      bridgeOk = okVal is bool ? okVal : (okVal != null ? jsonBool(okVal) : null);
      bridgeError = bridgeMap['error']?.toString();

      final body = _jsonMap(bridgeMap['body']);
      if (body != null) {
        final mlRaw = body['ml_loaded'] ?? body['mlLoaded'];
        if (mlRaw != null) {
          modelsLoaded = mlRaw is bool ? mlRaw : jsonBool(mlRaw);
        }
      }
    }

    return MlStatus(
      mlEnabled: jsonBool(json['mlEnabled']),
      bridgeOk: bridgeOk,
      modelsLoaded: modelsLoaded,
      note: json['note'] as String?,
      bridgeError: bridgeError,
    );
  }
}

/// jsonDecode iç içe nesneleri bazen `Map<dynamic,dynamic>` yapar; `is Map<String,dynamic>` false kalır.
Map<String, dynamic>? _jsonMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

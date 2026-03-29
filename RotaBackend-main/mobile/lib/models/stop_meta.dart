import 'stop_summary.dart' show jsonBool;

/// GET /api/v1/stops/{durakKodu}
class StopMeta {
  const StopMeta({
    required this.durakKodu,
    required this.durakAdi,
    required this.engelliErisimi,
  });

  final String durakKodu;
  final String durakAdi;
  final bool engelliErisimi;

  factory StopMeta.fromJson(Map<String, dynamic> json) {
    return StopMeta(
      durakKodu: json['durakKodu'] as String,
      durakAdi: json['durakAdi'] as String,
      engelliErisimi: jsonBool(json['engelliErisimi']),
    );
  }
}

/// GET /api/v1/stops öğesi — ana liste (sunucudan).
class StopSummary {
  const StopSummary({
    required this.durakKodu,
    required this.durakAdi,
    required this.engelliErisimi,
    this.enYakinSeferDk,
    this.enYakinHatKodu,
    this.enlem,
    this.boylam,
  });

  final String durakKodu;
  final String durakAdi;
  final bool engelliErisimi;
  final int? enYakinSeferDk;
  final String? enYakinHatKodu;
  final double? enlem;
  final double? boylam;

  bool get hasLocation => enlem != null && boylam != null;

  factory StopSummary.fromJson(Map<String, dynamic> json) {
    return StopSummary(
      durakKodu: json['durakKodu'] as String,
      durakAdi: json['durakAdi'] as String,
      engelliErisimi: jsonBool(json['engelliErisimi']),
      enYakinSeferDk: json['enYakinSeferDk'] == null
          ? null
          : (json['enYakinSeferDk'] as num).toInt(),
      enYakinHatKodu: json['enYakinHatKodu'] as String?,
      enlem: (json['enlem'] as num?)?.toDouble(),
      boylam: (json['boylam'] as num?)?.toDouble(),
    );
  }
}

/// Ortak JSON bool (Node / PG farklı tipler için).
bool jsonBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final u = v.toUpperCase();
    return u == 'TRUE' || u == '1' || u == 'E' || u == 'Y';
  }
  return false;
}

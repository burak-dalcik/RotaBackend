import 'stop_summary.dart' show jsonBool;

class ApproachingBus {
  const ApproachingBus({
    required this.hatKodu,
    required this.hatAdi,
    required this.kalanSureDk,
    required this.dolulukOrani,
    required this.engelliErisimi,
    required this.beklenenYolcu,
    required this.mlTahmin,
    required this.aracKapasitesi,
  });

  final String hatKodu;
  final String hatAdi;
  final int kalanSureDk;
  final int dolulukOrani;
  final bool engelliErisimi;

  /// Sunucunun ML / yedek akışından gelen tahmini yolcu sayısı.
  final int beklenenYolcu;

  /// `true` ise bu satır için XGBoost cevabı kullanıldı.
  final bool mlTahmin;

  /// Doluluk yüzdesinin hesaplandığı kapasite.
  final int aracKapasitesi;

  factory ApproachingBus.fromJson(Map<String, dynamic> json) {
    final dolulukOrani = (json['dolulukOrani'] as num).toInt();
    final capFromApi = (json['aracKapasitesi'] as num?)?.toInt();
    final defaultCap = capFromApi ?? 100;
    final beklenenYolcu = json['beklenenYolcu'] != null
        ? (json['beklenenYolcu'] as num).toInt()
        : (dolulukOrani * defaultCap / 100).round().clamp(0, defaultCap);
    final aracKapasitesi = capFromApi ?? defaultCap;
    final mlTahmin =
        json.containsKey('mlTahmin') ? jsonBool(json['mlTahmin']) : true;

    return ApproachingBus(
      hatKodu: json['hatKodu'] as String,
      hatAdi: json['hatAdi'] as String,
      kalanSureDk: (json['kalanSureDk'] as num).toInt(),
      dolulukOrani: dolulukOrani,
      engelliErisimi: jsonBool(json['engelliErisimi']),
      beklenenYolcu: beklenenYolcu,
      mlTahmin: mlTahmin,
      aracKapasitesi: aracKapasitesi,
    );
  }
}

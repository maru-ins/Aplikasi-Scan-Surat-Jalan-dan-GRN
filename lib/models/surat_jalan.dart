class SuratJalan {
  final String nomor;
  final DateTime waktuScan;

  SuratJalan({
    required this.nomor,
    required this.waktuScan,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'waktuScan': waktuScan.toIso8601String(),
    };
  }

  factory SuratJalan.fromJson(Map<String, dynamic> json) {
    return SuratJalan(
      nomor: json['nomor']?.toString() ?? '',
      waktuScan: DateTime.tryParse(
            json['waktuScan']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
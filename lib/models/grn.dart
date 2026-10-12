class Grn {
  final String nomor;
  final DateTime waktuScan;

  Grn({
    required this.nomor,
    required this.waktuScan,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'waktuScan': waktuScan.toIso8601String(),
    };
  }

  factory Grn.fromJson(Map<String, dynamic> json) {
    return Grn(
      nomor: json['nomor']?.toString() ?? '',
      waktuScan:
          DateTime.tryParse(
            json['waktuScan']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
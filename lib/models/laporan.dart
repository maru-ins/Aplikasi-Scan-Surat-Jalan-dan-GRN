import 'dart:convert';

import 'grn.dart';
import 'surat_jalan.dart';

class Laporan {
  final String id;
  final DateTime tanggalMulai;
  final DateTime? tanggalFinal;
  final String status;
  final List<SuratJalan> daftarSJ;
  final List<Grn> daftarGRN;
  final String? filePdf;

  Laporan({
    required this.id,
    required this.tanggalMulai,
    required this.tanggalFinal,
    required this.status,
    required this.daftarSJ,
    required this.daftarGRN,
    required this.filePdf,
  });

  factory Laporan.baru() {
    final now = DateTime.now();

    return Laporan(
      id: '${now.millisecondsSinceEpoch}',
      tanggalMulai: now,
      tanggalFinal: null,
      status: 'draft',
      daftarSJ: [],
      daftarGRN: [],
      filePdf: null,
    );
  }

  Laporan copyWith({
    String? id,
    DateTime? tanggalMulai,
    DateTime? tanggalFinal,
    String? status,
    List<SuratJalan>? daftarSJ,
    List<Grn>? daftarGRN,
    String? filePdf,
  }) {
    return Laporan(
      id: id ?? this.id,
      tanggalMulai:
          tanggalMulai ?? this.tanggalMulai,
      tanggalFinal:
          tanggalFinal ?? this.tanggalFinal,
      status: status ?? this.status,
      daftarSJ:
          daftarSJ ?? this.daftarSJ,
      daftarGRN:
          daftarGRN ?? this.daftarGRN,
      filePdf:
          filePdf ?? this.filePdf,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggalMulai':
          tanggalMulai.toIso8601String(),
      'tanggalFinal':
          tanggalFinal?.toIso8601String(),
      'status': status,

      'daftarSJ': daftarSJ
          .map((item) => item.toJson())
          .toList(),

      'daftarGRN': daftarGRN
          .map((item) => item.toJson())
          .toList(),

      'filePdf': filePdf,
    };
  }

  factory Laporan.fromJson(
    Map<String, dynamic> json,
  ) {
    final sjData =
        json['daftarSJ'] as List? ?? [];

    final grnData =
        json['daftarGRN'] as List? ?? [];

    return Laporan(
      id: json['id']?.toString() ?? '',
      tanggalMulai:
          DateTime.tryParse(
                json['tanggalMulai']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      tanggalFinal:
          json['tanggalFinal'] == null
              ? null
              : DateTime.tryParse(
                  json['tanggalFinal']
                      .toString(),
                ),

      status:
          json['status']?.toString() ??
              'draft',

      daftarSJ: sjData
          .map(
            (item) =>
                SuratJalan.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(),

      daftarGRN: grnData
          .map(
            (item) => Grn.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(),

      filePdf:
          json['filePdf']?.toString(),
    );
  }

  String encode() {
    return jsonEncode(toJson());
  }

  factory Laporan.decode(
    String value,
  ) {
    return Laporan.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(value),
      ),
    );
  }
}
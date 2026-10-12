import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/grn.dart';
import '../models/laporan.dart';
import '../models/surat_jalan.dart';

class StorageService {
  static const String _keyActiveReport =
      'laporan_aktif';

  static const String _keyArchivedReports =
      'laporan_arsip';

  // ==========================================================
  // LAPORAN AKTIF
  // ==========================================================

  Future<Laporan> getOrCreateActiveReport() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getString(_keyActiveReport);

    if (data != null && data.isNotEmpty) {
      try {
        return Laporan.decode(data);
      } catch (_) {
        // Kalau data rusak, buat laporan baru.
      }
    }

    final laporan =
        Laporan.baru();

    await _saveActiveReport(
      laporan,
    );

    return laporan;
  }

  Future<Laporan?> getActiveReport() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getString(_keyActiveReport);

    if (data == null || data.isEmpty) {
      return null;
    }

    try {
      return Laporan.decode(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveActiveReport(
    Laporan laporan,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _keyActiveReport,
      laporan.encode(),
    );
  }

  // ==========================================================
  // SURAT JALAN
  // ==========================================================

  Future<List<SuratJalan>>
      getSuratJalan() async {
    final laporan =
        await getOrCreateActiveReport();

    return List<SuratJalan>.from(
      laporan.daftarSJ,
    );
  }

  Future<bool> tambahSuratJalan(
    String nomor,
  ) async {
    final laporan =
        await getOrCreateActiveReport();

    final sudahAda =
        laporan.daftarSJ.any(
      (item) => item.nomor == nomor,
    );

    if (sudahAda) {
      return false;
    }

    final list =
        List<SuratJalan>.from(
      laporan.daftarSJ,
    );

    list.add(
      SuratJalan(
        nomor: nomor,
        waktuScan:
            DateTime.now(),
      ),
    );

    final updated =
        laporan.copyWith(
      daftarSJ: list,
    );

    await _saveActiveReport(
      updated,
    );

    return true;
  }

  Future<void> hapusSuratJalan(
    String nomor,
  ) async {
    final laporan =
        await getOrCreateActiveReport();

    final list =
        List<SuratJalan>.from(
      laporan.daftarSJ,
    );

    list.removeWhere(
      (item) => item.nomor == nomor,
    );

    await _saveActiveReport(
      laporan.copyWith(
        daftarSJ: list,
      ),
    );
  }

  // ==========================================================
  // GRN
  // ==========================================================

  Future<List<Grn>> getGrn() async {
    final laporan =
        await getOrCreateActiveReport();

    return List<Grn>.from(
      laporan.daftarGRN,
    );
  }

  Future<bool> tambahGrn(
    String nomor,
  ) async {
    final laporan =
        await getOrCreateActiveReport();

    final sudahAda =
        laporan.daftarGRN.any(
      (item) => item.nomor == nomor,
    );

    if (sudahAda) {
      return false;
    }

    final list =
        List<Grn>.from(
      laporan.daftarGRN,
    );

    list.add(
      Grn(
        nomor: nomor,
        waktuScan:
            DateTime.now(),
      ),
    );

    final updated =
        laporan.copyWith(
      daftarGRN: list,
    );

    await _saveActiveReport(
      updated,
    );

    return true;
  }

  Future<void> hapusGrn(
    String nomor,
  ) async {
    final laporan =
        await getOrCreateActiveReport();

    final list =
        List<Grn>.from(
      laporan.daftarGRN,
    );

    list.removeWhere(
      (item) => item.nomor == nomor,
    );

    await _saveActiveReport(
      laporan.copyWith(
        daftarGRN: list,
      ),
    );
  }

  // ==========================================================
  // ARSIP
  // ==========================================================

  Future<List<Laporan>>
      getArchivedReports() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getString(
      _keyArchivedReports,
    );

    if (data == null ||
        data.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(data);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) => Laporan.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> archiveAndClearActive(
    String filePdf,
  ) async {
    final active =
        await getActiveReport();

    if (active == null) {
      return;
    }

    final finalReport =
        active.copyWith(
      status: 'final',
      tanggalFinal:
          DateTime.now(),
      filePdf: filePdf,
    );

    final archived =
        await getArchivedReports();

    archived.insert(
      0,
      finalReport,
    );

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _keyArchivedReports,
      jsonEncode(
        archived
            .map(
              (item) => item.toJson(),
            )
            .toList(),
      ),
    );

    // Hapus hanya laporan AKTIF,
    // bukan arsip.
    await prefs.remove(
      _keyActiveReport,
    );
  }

  // ==========================================================
  // RESET MANUAL
  // ==========================================================

  Future<void> clearActiveReport() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _keyActiveReport,
    );
  }
}
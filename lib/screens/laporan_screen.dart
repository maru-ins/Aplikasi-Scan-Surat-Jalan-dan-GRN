import 'package:flutter/material.dart';

import '../models/grn.dart';
import '../models/laporan.dart';
import '../models/surat_jalan.dart';
import '../services/storage_service.dart';
import 'finance_screen.dart';

class LaporanScreen
    extends StatefulWidget {
  const LaporanScreen({
    super.key,
  });

  @override
  State<LaporanScreen> createState() =>
      _LaporanScreenState();
}

class _LaporanScreenState
    extends State<LaporanScreen> {
  final StorageService storage =
      StorageService();

  Laporan? laporan;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data =
        await storage
            .getActiveReport();

    if (!mounted) return;

    setState(() {
      laporan = data;
      loading = false;
    });
  }

  String formatTanggal(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatJam(
    DateTime waktu,
  ) {
    return '${waktu.hour.toString().padLeft(2, '0')}:'
        '${waktu.minute.toString().padLeft(2, '0')}:'
        '${waktu.second.toString().padLeft(2, '0')}';
  }

  Future<void> bukaFinance() async {
    final data =
        await storage.getActiveReport();

    if (!mounted) return;

    if (data == null) {
      return;
    }

    final hasil =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FinanceScreen(
          daftarSJ: data.daftarSJ
              .map(
                (e) => e.nomor,
              )
              .toList(),

          daftarGRN: data.daftarGRN
              .map(
                (e) => e.nomor,
              )
              .toList(),

          tanggalMulai:
              data.tanggalMulai,
        ),
      ),
    );

    if (!mounted) return;

    if (hasil is String &&
        hasil.isNotEmpty) {
      await loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Laporan berhasil difinalisasi.',
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    }
  }

  Widget buildSectionSJ(
    List<SuratJalan> data,
  ) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.fromLTRB(
            4,
            8,
            4,
            8,
          ),
          child: Text(
            'SURAT JALAN',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        ...List.generate(
          data.length,
          (index) {
            final sj =
                data[index];

            return Card(
              child: ListTile(
                leading:
                    CircleAvatar(
                  child: Text(
                    '${index + 1}',
                  ),
                ),
                title: Text(
                  sj.nomor,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text(
                  'Scan: ${formatJam(
                    sj.waktuScan,
                  )}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildSectionGRN(
    List<Grn> data,
  ) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.fromLTRB(
            4,
            18,
            4,
            8,
          ),
          child: Text(
            'GRN',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        ...List.generate(
          data.length,
          (index) {
            final grn =
                data[index];

            return Card(
              child: ListTile(
                leading:
                    CircleAvatar(
                  child: Text(
                    '${index + 1}',
                  ),
                ),
                title: Text(
                  grn.nomor,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text(
                  'Scan: ${formatJam(
                    grn.waktuScan,
                  )}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Laporan Aktif',
          ),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (laporan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Laporan Aktif',
          ),
        ),
        body: const Center(
          child: Text(
            'Belum ada laporan aktif.',
          ),
        ),
      );
    }

    final total =
        laporan!.daftarSJ.length +
            laporan!.daftarGRN.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Aktif',
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ======================================================
          // INFO LAPORAN
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    const Text(
                      'LAPORAN AKTIF',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Mulai: ${formatTanggal(
                        laporan!.tanggalMulai,
                      )}',
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Status: BELUM FINAL',
                      style:
                          TextStyle(
                        color:
                            Colors.orange
                                .shade800,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,
                      children: [
                        Text(
                          'SJ: ${laporan!.daftarSJ.length}',
                        ),
                        Text(
                          'GRN: ${laporan!.daftarGRN.length}',
                        ),
                        Text(
                          'Total: $total',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // LIST
          // ======================================================

          Expanded(
            child: total == 0
                ? const Center(
                    child: Text(
                      'Belum ada dokumen.',
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                    ),
                    children: [
                      buildSectionSJ(
                        laporan!
                            .daftarSJ,
                      ),

                      buildSectionGRN(
                        laporan!
                            .daftarGRN,
                      ),
                    ],
                  ),
          ),

          // ======================================================
          // FINANCE
          // ======================================================

          if (total > 0)
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: SizedBox(
                  width:
                      double.infinity,
                  height: 56,
                  child:
                      ElevatedButton
                          .icon(
                    icon:
                        const Icon(
                      Icons.draw,
                    ),
                    label:
                        const Text(
                      'PERIKSA & TTD FINANCE',
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    onPressed:
                        bukaFinance,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
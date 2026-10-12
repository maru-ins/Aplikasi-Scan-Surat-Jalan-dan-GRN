import 'package:flutter/material.dart';

import '../models/laporan.dart';
import '../services/storage_service.dart';

import 'grn_scan_screen.dart';
import 'laporan_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  final StorageService storage =
      StorageService();

  Laporan? laporanAktif;

  @override
  void initState() {
    super.initState();

    cekLaporanAktif();
  }

  // ==========================================================
  // CEK LAPORAN AKTIF
  // ==========================================================

  Future<void> cekLaporanAktif() async {
    final data =
        await storage.getActiveReport();

    if (!mounted) return;

    setState(() {
      laporanAktif = data;
    });
  }

  // ==========================================================
  // CEK APAKAH ADA DRAFT
  // ==========================================================

  bool get adaLaporanAktif {
    if (laporanAktif == null) {
      return false;
    }

    return laporanAktif!.daftarSJ.isNotEmpty ||
        laporanAktif!.daftarGRN.isNotEmpty;
  }

  // ==========================================================
  // SCAN SURAT JALAN
  // ==========================================================

  Future<void> bukaScannerSJ() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ScanScreen(),
      ),
    );

    if (!mounted) return;

    await cekLaporanAktif();
  }

  // ==========================================================
  // SCAN GRN
  // ==========================================================

  Future<void> bukaScannerGRN() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const GrnScanScreen(),
      ),
    );

    if (!mounted) return;

    await cekLaporanAktif();
  }

  // ==========================================================
  // BUKA LAPORAN
  // ==========================================================

  Future<void> bukaLaporan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LaporanScreen(),
      ),
    );

    if (!mounted) return;

    await cekLaporanAktif();
  }

  // ==========================================================
  // LANJUTKAN LAPORAN
  // ==========================================================

  Future<void> lanjutkanLaporan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LaporanScreen(),
      ),
    );

    if (!mounted) return;

    await cekLaporanAktif();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan SJ & GRN Logistik',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            children: [
              // ==================================================
              // BAGIAN UTAMA
              // ==================================================

              Expanded(
                child:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      const SizedBox(
                        height: 30,
                      ),

                      // ==================================================
                      // ICON
                      // ==================================================

                      const Icon(
                        Icons.local_shipping,
                        size: 75,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      const Text(
                        'LAPORAN DOKUMEN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // ==================================================
                      // LAPORAN AKTIF
                      // ==================================================

                      if (adaLaporanAktif) ...[
                        Container(
                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets.all(
                            14,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors.orange
                                .withValues(
                              alpha: 0.12,
                            ),

                            border:
                                Border.all(
                              color:
                                  Colors.orange,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),

                          child: Column(
                            children: [
                              const Text(
                                'ADA LAPORAN AKTIF',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                'SJ: ${laporanAktif!.daftarSJ.length}   '
                                'GRN: ${laporanAktif!.daftarGRN.length}',
                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              if (laporanAktif !=
                                  null)
                                Text(
                                  'Mulai: '
                                  '${laporanAktif!.tanggalMulai.day.toString().padLeft(2, '0')}/'
                                  '${laporanAktif!.tanggalMulai.month.toString().padLeft(2, '0')}/'
                                  '${laporanAktif!.tanggalMulai.year}',
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                    color:
                                        Colors.grey,
                                  ),
                                ),

                              const SizedBox(
                                height: 12,
                              ),

                              SizedBox(
                                width:
                                    double.infinity,
                                height: 52,

                                child:
                                    ElevatedButton
                                        .icon(
                                  icon:
                                      const Icon(
                                    Icons.play_arrow,
                                  ),

                                  label:
                                      const Text(
                                    'LANJUTKAN LAPORAN',
                                    style:
                                        TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  onPressed:
                                      lanjutkanLaporan,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                      ],

                      // ==================================================
                      // SCAN SURAT JALAN
                      // ==================================================

                      SizedBox(
                        width:
                            double.infinity,
                        height: 58,

                        child:
                            ElevatedButton
                                .icon(
                          icon:
                              const Icon(
                            Icons
                                .qr_code_scanner,
                          ),

                          label:
                              const Text(
                            'SCAN SURAT JALAN',
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          onPressed:
                              bukaScannerSJ,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ==================================================
                      // SCAN GRN
                      // ==================================================

                      SizedBox(
                        width:
                            double.infinity,
                        height: 58,

                        child:
                            ElevatedButton
                                .icon(
                          icon:
                              const Icon(
                            Icons
                                .document_scanner,
                          ),

                          label:
                              const Text(
                            'SCAN GRN',
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          onPressed:
                              bukaScannerGRN,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ==================================================
                      // LAPORAN HARI INI
                      // ==================================================

                      SizedBox(
                        width:
                            double.infinity,
                        height: 58,

                        child:
                            OutlinedButton
                                .icon(
                          icon:
                              const Icon(
                            Icons.description,
                          ),

                          label:
                              const Text(
                            'LAPORAN HARI INI',
                            style:
                                TextStyle(
                              fontSize: 17,
                            ),
                          ),

                          onPressed:
                              bukaLaporan,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // COPYRIGHT
              // ==================================================

              const Text(
                '@divaltfnd',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/surat_jalan.dart';
import '../services/storage_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller =
      MobileScannerController();

  final StorageService storage = StorageService();

  final TextEditingController searchController =
      TextEditingController();

  List<SuratJalan> daftarSJ = [];

  bool loading = true;
  bool sedangMemproses = false;
  bool flashAktif = false;

  String? nomorTerakhir;
  bool tampilKonfirmasi = false;

  // ==========================================================
  // VALIDASI BARCODE
  // ==========================================================
  //
  // Untuk sementara dibuat fleksibel.
  // Contoh yang diterima:
  // SJ/26/0818/001
  // SJ-26-0818-001
  // 11-10052-05-0012-0001
  //
  // Nanti kalau format barcode SJ sudah pasti,
  // regex ini bisa dibuat lebih ketat.
  //
  final RegExp polaBarcode = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9._/\- ]{2,59}$',
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ==========================================================
  // LOAD DATA
  // ==========================================================

  Future<void> loadData() async {
    final data = await storage.getSuratJalan();

    if (!mounted) return;

    setState(() {
      daftarSJ = data;
      loading = false;
    });
  }

  // ==========================================================
  // VALIDASI BARCODE
  // ==========================================================

  bool barcodeValid(String value) {
    final nomor = value.trim();

    if (nomor.isEmpty) {
      return false;
    }

    return polaBarcode.hasMatch(nomor);
  }

  // ==========================================================
  // PROSES BARCODE
  // ==========================================================

  Future<void> prosesBarcode(String value) async {
    if (sedangMemproses) {
      return;
    }

    final nomor = value.trim();

    // --------------------------------------------------------
    // VALIDASI
    // --------------------------------------------------------

    if (!barcodeValid(nomor)) {
      await tampilPesan(
        title: 'BARCODE TIDAK VALID',
        message:
            'Isi barcode tidak sesuai format yang dapat diproses.\n\n'
            'Data terbaca:\n$nomor',
        warna: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );

      return;
    }

    // --------------------------------------------------------
    // CEK DUPLIKAT DI MEMORY
    // --------------------------------------------------------

    final sudahAda = daftarSJ.any(
      (item) => item.nomor == nomor,
    );

    if (sudahAda) {
      await tampilPesan(
        title: 'SJ SUDAH TERDAFTAR',
        message:
            'Nomor Surat Jalan berikut sudah ada '
            'dalam daftar hari ini:\n\n$nomor',
        warna: Colors.orange,
        icon: Icons.content_copy,
      );

      return;
    }

    sedangMemproses = true;

    // --------------------------------------------------------
    // SIMPAN KE STORAGE
    // --------------------------------------------------------

    final berhasil = await storage.tambahSuratJalan(
      nomor,
    );

    if (!berhasil) {
      sedangMemproses = false;

      await tampilPesan(
        title: 'SJ SUDAH TERDAFTAR',
        message:
            'Nomor Surat Jalan berikut sudah ada:\n\n$nomor',
        warna: Colors.orange,
        icon: Icons.content_copy,
      );

      return;
    }

    final waktuSekarang = DateTime.now();

    if (!mounted) return;

    // --------------------------------------------------------
    // MASUKKAN KE LIST
    // --------------------------------------------------------

    setState(() {
      daftarSJ.add(
        SuratJalan(
          nomor: nomor,
          waktuScan: waktuSekarang,
        ),
      );

      nomorTerakhir = nomor;
      tampilKonfirmasi = true;
    });

    // Getar singkat
    await HapticFeedback.mediumImpact();

    // --------------------------------------------------------
    // KONFIRMASI TAMPIL 1 DETIK
    // --------------------------------------------------------

    await Future.delayed(
      const Duration(milliseconds: 1000),
    );

    if (!mounted) return;

    setState(() {
      tampilKonfirmasi = false;
      sedangMemproses = false;
    });
  }

  // ==========================================================
  // DIALOG PESAN
  // ==========================================================

  Future<void> tampilPesan({
    required String title,
    required String message,
    required Color warna,
    required IconData icon,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            icon,
            color: warna,
            size: 42,
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // HAPUS SJ
  // ==========================================================

  Future<void> hapusSJ(SuratJalan sj) async {
    await storage.hapusSuratJalan(
      sj.nomor,
    );

    if (!mounted) return;

    setState(() {
      daftarSJ.removeWhere(
        (item) => item.nomor == sj.nomor,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SJ ${sj.nomor} dihapus.',
        ),
        action: SnackBarAction(
          label: 'BATAL',
          onPressed: () async {
            final berhasil =
                await storage.tambahSuratJalan(
              sj.nomor,
            );

            if (!berhasil || !mounted) {
              return;
            }

            setState(() {
              daftarSJ.add(sj);

              daftarSJ.sort(
                (a, b) => a.waktuScan.compareTo(
                  b.waktuScan,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  // ==========================================================
  // BATALKAN SCAN TERAKHIR
  // ==========================================================

  Future<void> batalScanTerakhir() async {
    if (daftarSJ.isEmpty) {
      return;
    }

    final terakhir = daftarSJ.last;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Batalkan Scan Terakhir?',
          ),
          content: Text(
            'Nomor SJ:\n${terakhir.nomor}\n\n'
            'SJ ini akan dihapus dari laporan hari ini.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('HAPUS'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    await storage.hapusSuratJalan(
      terakhir.nomor,
    );

    if (!mounted) return;

    setState(() {
      daftarSJ.removeLast();
    });
  }

  // ==========================================================
  // SELESAI SCAN
  // ==========================================================
  //
  // TIDAK LAGI MASUK KE FINANCE.
  //
  // Alurnya:
  // Scan SJ
  //   ↓
  // selesai
  //   ↓
  // kembali Home
  //
  // Finance dibuka dari Laporan Hari Ini,
  // setelah data SJ + GRN lengkap.
  //
  void selesai() {
    Navigator.pop(context, true);
  }

  // ==========================================================
  // FORMAT JAM
  // ==========================================================

  String formatJam(DateTime waktu) {
    return '${waktu.hour.toString().padLeft(2, '0')}:'
        '${waktu.minute.toString().padLeft(2, '0')}:'
        '${waktu.second.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // HASIL PENCARIAN
  // ==========================================================

  List<SuratJalan> get daftarHasilPencarian {
    final query =
        searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return daftarSJ;
    }

    return daftarSJ.where((sj) {
      return sj.nomor
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final daftarTampil =
        daftarHasilPencarian;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Surat Jalan',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Flash',
            icon: Icon(
              flashAktif
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: () async {
              await controller.toggleTorch();

              if (!mounted) return;

              setState(() {
                flashAktif = !flashAktif;
              });
            },
          ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // =================================================
                // CAMERA
                // =================================================

                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          for (final barcode
                              in capture.barcodes) {
                            final value =
                                barcode.rawValue;

                            if (value != null &&
                                value.trim().isNotEmpty) {
                              prosesBarcode(
                                value,
                              );

                              break;
                            }
                          }
                        },
                      ),

                      // Kotak scanner
                      Center(
                        child: Container(
                          width: 300,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      // Instruksi
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Text(
                          sedangMemproses
                              ? 'Memproses...'
                              : 'Arahkan barcode ke dalam kotak',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // =================================================
                      // KONFIRMASI BERHASIL
                      // =================================================

                      AnimatedOpacity(
                        opacity:
                            tampilKonfirmasi ? 1 : 0,
                        duration:
                            const Duration(
                          milliseconds: 200,
                        ),
                        child: Center(
                          child: Container(
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 30,
                            ),
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 25,
                              vertical: 18,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.green
                                  .withValues(
                                alpha: 0.95,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text(
                                  'BERHASIL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  nomorTerakhir ?? '',
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // JUMLAH SJ
                // =================================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    15,
                    16,
                    8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Surat Jalan Hari Ini',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .primaryContainer,
                        ),
                        child: Text(
                          '${daftarSJ.length} SJ',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // SEARCH
                // =================================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    8,
                  ),
                  child: TextField(
                    controller:
                        searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration:
                        InputDecoration(
                      hintText:
                          'Cari nomor SJ...',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      suffixIcon:
                          searchController
                                  .text
                                  .isEmpty
                              ? null
                              : IconButton(
                                  icon:
                                      const Icon(
                                    Icons.clear,
                                  ),
                                  onPressed: () {
                                    searchController
                                        .clear();

                                    setState(
                                      () {},
                                    );
                                  },
                                ),
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                ),

                // =================================================
                // LIST SJ
                // =================================================

                Expanded(
                  child: daftarTampil.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                searchController
                                        .text
                                        .isEmpty
                                    ? Icons
                                        .qr_code_scanner
                                    : Icons
                                        .search_off,
                                size: 60,
                                color:
                                    Colors.grey,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                searchController
                                        .text
                                        .isEmpty
                                    ? 'Belum ada Surat Jalan'
                                    : 'SJ tidak ditemukan',
                                style:
                                    const TextStyle(
                                  fontSize: 16,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                          ),
                          itemCount:
                              daftarTampil.length,
                          itemBuilder:
                              (context, index) {
                            final sj =
                                daftarTampil[index];

                            final nomorAsli =
                                daftarSJ.indexOf(
                              sj,
                            );

                            return Card(
                              child: ListTile(
                                leading:
                                    CircleAvatar(
                                  child: Text(
                                    '${nomorAsli + 1}',
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
                                subtitle: Text(
                                  'Scan: ${formatJam(
                                    sj.waktuScan,
                                  )}',
                                ),
                                trailing:
                                    IconButton(
                                  icon:
                                      const Icon(
                                    Icons
                                        .delete_outline,
                                  ),
                                  onPressed: () {
                                    hapusSJ(
                                      sj,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // =================================================
                // BATALKAN SCAN TERAKHIR
                // =================================================

                if (daftarSJ.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          batalScanTerakhir,
                      icon: const Icon(
                        Icons.undo,
                      ),
                      label: const Text(
                        'BATALKAN SCAN TERAKHIR',
                      ),
                    ),
                  ),

                // =================================================
                // SELESAI
                // =================================================

                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: SizedBox(
                      width:
                          double.infinity,
                      height: 55,
                      child:
                          ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check,
                        ),
                        label: Text(
                          'SELESAI SCAN (${daftarSJ.length} SJ)',
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        onPressed:
                            daftarSJ.isEmpty
                                ? null
                                : selesai,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
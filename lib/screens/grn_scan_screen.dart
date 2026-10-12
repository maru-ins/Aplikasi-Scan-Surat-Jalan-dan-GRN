import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/grn.dart';
import '../services/storage_service.dart';

class GrnScanScreen extends StatefulWidget {
  const GrnScanScreen({super.key});

  @override
  State<GrnScanScreen> createState() =>
      _GrnScanScreenState();
}

class _GrnScanScreenState
    extends State<GrnScanScreen> {
  final ImagePicker picker =
      ImagePicker();

  final StorageService storage =
      StorageService();

  final TextEditingController
      manualController =
      TextEditingController();

  final TextRecognizer textRecognizer =
      TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  List<Grn> daftarGRN = [];

  bool loading = true;
  bool sedangOCR = false;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final data =
        await storage.getGrn();

    if (!mounted) return;

    setState(() {
      daftarGRN = data;
      loading = false;
    });
  }

  // =========================================================
  // AMBIL FOTO
  // =========================================================

  Future<void> ambilFoto() async {
    if (sedangOCR) return;

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 2200,
    );

    if (image == null) {
      return;
    }

    await prosesOCR(image.path);
  }

  // =========================================================
  // PILIH FOTO
  // =========================================================

  Future<void> pilihFoto() async {
    if (sedangOCR) return;

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2200,
    );

    if (image == null) {
      return;
    }

    await prosesOCR(image.path);
  }

  // =========================================================
  // OCR
  // =========================================================

  Future<void> prosesOCR(
    String imagePath,
  ) async {
    setState(() {
      sedangOCR = true;
    });

    try {
      final inputImage =
          InputImage.fromFilePath(
        imagePath,
      );

      final recognizedText =
          await textRecognizer.processImage(
        inputImage,
      );

      final String? nomor =
          cariNomorGRN(
        recognizedText.text,
      );

      if (!mounted) return;

      if (nomor == null) {
        await tampilGagalOCR(
          recognizedText.text,
        );

        return;
      }

      await konfirmasiGRN(nomor);
    } catch (e) {
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 45,
            ),
            title: const Text(
              'OCR Gagal',
            ),
            content: Text(
              'Terjadi kesalahan saat membaca GRN:\n\n$e',
              textAlign:
                  TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child:
                    const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          sedangOCR = false;
        });
      }
    }
  }

  // =========================================================
  // CARI NOMOR GRN
  // =========================================================

  String? cariNomorGRN(
    String text,
  ) {
    final upper =
        text.toUpperCase();

    // -------------------------------------------------------
    // 1. Prioritaskan baris yang mengandung GRN
    // -------------------------------------------------------

    final lines =
        upper.split(
      RegExp(r'\r?\n'),
    );

    for (final line in lines) {
      if (!line.contains('GRN')) {
        continue;
      }

      final nomor =
          cariKodeFC(line);

      if (nomor != null) {
        return nomor;
      }
    }

    // -------------------------------------------------------
    // 2. Kalau tidak ditemukan di baris GRN,
    //    cari di seluruh hasil OCR
    // -------------------------------------------------------

    return cariKodeFC(upper);
  }

  String? cariKodeFC(
    String text,
  ) {
    /*
     * Contoh target:
     *
     * FC260800004
     *
     * OCR kadang membaca:
     *
     * FC 260800004
     * FC-260800004
     * FC:260800004
     * FC26080000O
     *
     * Karena itu karakter pemisah dibuang
     * dan O kita anggap 0.
     */

    final normalized =
        text.replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    final regex =
        RegExp(r'FC[0-9O]{9}');

    final match =
        regex.firstMatch(normalized);

    if (match == null) {
      return null;
    }

    final hasil =
        match.group(0)!;

    final nomor = hasil
        .replaceFirst(
          RegExp(r'^FC'),
          'FC',
        )
        .replaceAll('O', '0');

    if (!RegExp(
      r'^FC[0-9]{9}$',
    ).hasMatch(nomor)) {
      return null;
    }

    return nomor;
  }

  // =========================================================
  // KONFIRMASI
  // =========================================================

  Future<void> konfirmasiGRN(
    String nomor,
  ) async {
    final sudahAda =
        daftarGRN.any(
      (item) => item.nomor == nomor,
    );

    if (sudahAda) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.content_copy,
              color: Colors.orange,
              size: 45,
            ),
            title: const Text(
              'GRN SUDAH TERDAFTAR',
            ),
            content: Text(
              'Nomor GRN berikut sudah ada:\n\n$nomor',
              textAlign:
                  TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child:
                    const Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }

    final hasil =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.document_scanner,
            color: Colors.green,
            size: 48,
          ),

          title: const Text(
            'NOMOR GRN DITEMUKAN',
            textAlign:
                TextAlign.center,
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Text(
                'Apakah nomor GRN ini sudah benar?',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 18,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.grey
                      .shade100,
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: Text(
                  nomor,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('SCAN ULANG'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('GUNAKAN'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      await simpanGRN(nomor);
    }
  }

  // =========================================================
  // SIMPAN GRN
  // =========================================================

  Future<void> simpanGRN(
  String nomor,
) async {
  final berhasil =
      await storage.tambahGrn(
    nomor,
  );

  if (!berhasil) {
    return;
  }

  if (!mounted) return;

  setState(() {
    daftarGRN.add(
      Grn(
        nomor: nomor,
        waktuScan: DateTime.now(),
      ),
    );
  });

  await HapticFeedback.mediumImpact();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'GRN $nomor berhasil ditambahkan.',
      ),
      backgroundColor: Colors.green,
    ),
  );
}
  // =========================================================
  // OCR GAGAL
  // =========================================================

  Future<void> tampilGagalOCR(
  String text,
) async {
  if (!mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const Icon(
          Icons.search_off,
          color: Colors.orange,
          size: 45,
        ),

        title: const Text(
          'NOMOR GRN TIDAK DITEMUKAN',
          textAlign: TextAlign.center,
        ),

        content: const Text(
          'Kamera berhasil membaca dokumen, '
          'tetapi nomor GRN dengan format FCxxxxxxxxx '
          'belum ditemukan.\n\n'
          'Coba foto ulang dengan posisi lebih lurus '
          'dan nomor GRN terlihat jelas.',
          textAlign: TextAlign.center,
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'OK',
            ),
          ),
        ],
      );
    },
  );
}

  // =========================================================
  // INPUT MANUAL
  // =========================================================

  Future<void> inputManual() async {
    manualController.clear();

    final hasil =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Input Nomor GRN',
          ),

          content: TextField(
            controller:
                manualController,

            autofocus: true,

            textCapitalization:
                TextCapitalization
                    .characters,

            decoration:
                const InputDecoration(
              labelText:
                  'Nomor GRN',
              hintText:
                  'FC260800004',
              border:
                  OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('BATAL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  manualController
                      .text
                      .trim()
                      .toUpperCase(),
                );
              },
              child:
                  const Text('LANJUT'),
            ),
          ],
        );
      },
    );

    if (hasil == null ||
        hasil.isEmpty) {
      return;
    }

    final nomor =
        hasil.toUpperCase().trim();

    if (!RegExp(
      r'^FC[0-9]{9}$',
    ).hasMatch(nomor)) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Format GRN harus seperti FC260800004.',
          ),
          backgroundColor:
              Colors.red,
        ),
      );

      return;
    }

    await konfirmasiGRN(
      nomor,
    );
  }

  // =========================================================
  // HAPUS
  // =========================================================

  Future<void> hapusGRN(
    Grn grn,
  ) async {
    await storage.hapusGrn(
      grn.nomor,
    );

    if (!mounted) return;

    setState(() {
      daftarGRN.removeWhere(
        (item) =>
            item.nomor ==
            grn.nomor,
      );
    });
  }

  // =========================================================
  // BATAL SCAN TERAKHIR
  // =========================================================

  Future<void>
      batalScanTerakhir() async {
    if (daftarGRN.isEmpty) {
      return;
    }

    final terakhir =
        daftarGRN.last;

    final konfirmasi =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Batalkan GRN terakhir?',
          ),

          content: Text(
            terakhir.nomor,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('BATAL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('HAPUS'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    await storage.hapusGrn(
      terakhir.nomor,
    );

    if (!mounted) return;

    setState(() {
      daftarGRN.removeLast();
    });
  }

  String formatJam(
    DateTime waktu,
  ) {
    return '${waktu.hour.toString().padLeft(2, '0')}:'
        '${waktu.minute.toString().padLeft(2, '0')}:'
        '${waktu.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    textRecognizer.close();
    manualController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan GRN',
        ),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.blue
                          .shade50,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.document_scanner,
                          size: 55,
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        const Text(
                          'SCAN GRN',
                          style:
                              TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        const Text(
                          'Foto dokumen GRN untuk membaca '
                          'nomor FCxxxxxxxxx',
                          textAlign:
                              TextAlign
                                  .center,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton
                                  .icon(
                            icon: sedangOCR
                                ? const SizedBox(
                                    width:
                                        20,
                                    height:
                                        20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors
                                              .white,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .camera_alt,
                                  ),

                            label: Text(
                              sedangOCR
                                  ? 'MEMBACA...'
                                  : 'AMBIL FOTO GRN',
                            ),

                            onPressed:
                                sedangOCR
                                    ? null
                                    : ambilFoto,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  OutlinedButton.icon(
                                icon:
                                    const Icon(
                                  Icons
                                      .photo_library,
                                ),
                                label:
                                    const Text(
                                  'PILIH FOTO',
                                ),
                                onPressed:
                                    sedangOCR
                                        ? null
                                        : pilihFoto,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  OutlinedButton.icon(
                                icon:
                                    const Icon(
                                  Icons
                                      .keyboard,
                                ),
                                label:
                                    const Text(
                                  'INPUT MANUAL',
                                ),
                                onPressed:
                                    sedangOCR
                                        ? null
                                        : inputManual,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'GRN Hari Ini',
                          style:
                              TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      CircleAvatar(
                        child: Text(
                          '${daftarGRN.length}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Expanded(
                  child: daftarGRN.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada GRN.',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                          ),
                          itemCount:
                              daftarGRN
                                  .length,
                          itemBuilder:
                              (context,
                                  index) {
                            final grn =
                                daftarGRN[
                                    index];

                            return Card(
                              child:
                                  ListTile(
                                leading:
                                    CircleAvatar(
                                  child:
                                      Text(
                                    '${index + 1}',
                                  ),
                                ),

                                title:
                                    Text(
                                  grn.nomor,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                subtitle:
                                    Text(
                                  'Scan: ${formatJam(
                                    grn.waktuScan,
                                  )}',
                                ),

                                trailing:
                                    IconButton(
                                  icon:
                                      const Icon(
                                    Icons
                                        .delete_outline,
                                  ),
                                  onPressed:
                                      () {
                                    hapusGRN(
                                      grn,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                if (daftarGRN.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    child:
                        OutlinedButton
                            .icon(
                      onPressed:
                          batalScanTerakhir,

                      icon: const Icon(
                        Icons.undo,
                      ),

                      label: const Text(
                        'BATALKAN GRN TERAKHIR',
                      ),
                    ),
                  ),

                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(
                      16,
                    ),
                    child: SizedBox(
                      width:
                          double.infinity,
                      height: 55,
                      child:
                          ElevatedButton
                              .icon(
                        icon: const Icon(
                          Icons.check,
                        ),
                        label: Text(
                          'SELESAI (${daftarGRN.length} GRN)',
                        ),
                        onPressed:
                            daftarGRN
                                    .isEmpty
                                ? null
                                : () {
                                    Navigator
                                        .pop(
                                      context,
                                      true,
                                    );
                                  },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class FinanceScreen
    extends StatefulWidget {
  final List<String> daftarSJ;
  final List<String> daftarGRN;
  final DateTime tanggalMulai;

  const FinanceScreen({
    super.key,
    required this.daftarSJ,
    required this.daftarGRN,
    required this.tanggalMulai,
  });

  @override
  State<FinanceScreen> createState() =>
      _FinanceScreenState();
}

class _FinanceScreenState
    extends State<FinanceScreen> {
  final TextEditingController
      petugasController =
      TextEditingController();

  final TextEditingController
      financeController =
      TextEditingController();

  final SignatureController
      signatureController =
      SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor:
        Colors.white,
  );

  bool sedangMenyimpan = false;

  int get totalDokumen =>
      widget.daftarSJ.length +
      widget.daftarGRN.length;

  @override
  void dispose() {
    petugasController.dispose();
    financeController.dispose();
    signatureController.dispose();

    super.dispose();
  }

  Future<void> simpanLaporan() async {
    final petugas =
        petugasController.text.trim();

    final finance =
        financeController.text.trim();

    if (petugas.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama petugas Logistik belum diisi.',
          ),
        ),
      );
      return;
    }

    if (finance.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama Finance belum diisi.',
          ),
        ),
      );
      return;
    }

    if (signatureController
        .isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanda tangan Finance belum diisi.',
          ),
        ),
      );
      return;
    }

    setState(() {
      sedangMenyimpan = true;
    });

    try {
      final Uint8List?
          signatureBytes =
          await signatureController
              .toPngBytes();

      if (signatureBytes == null) {
        throw Exception(
          'Tanda tangan tidak dapat diproses.',
        );
      }

      final String filePath =
        await PdfService.buatLaporanSJ(
      daftarSJ: widget.daftarSJ,
      daftarGRN: widget.daftarGRN,
      petugas: petugas,
      namaFinance: finance,
      signatureBytes: signatureBytes,
      tanggalMulai:
      widget.tanggalMulai,
      );

      await StorageService()
        .archiveAndClearActive(
        filePath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Laporan berhasil disimpan.',
          ),
          backgroundColor:
              Colors.green,
        ),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 800,
        ),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        filePath,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan laporan: $e',
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sedangMenyimpan = false;
        });
      }
    }
  }

  Widget sectionTitle(
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget daftarDokumen(
    List<String> data,
    String prefix,
  ) {
    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(
        border: Border.all(
          color:
              Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        children: List.generate(
          data.length,
          (index) {
            return ListTile(
              dense: true,
              leading:
                  CircleAvatar(
                radius: 16,
                child: Text(
                  '${index + 1}',
                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                data[index],
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pemeriksaan Finance',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              const Text(
                'Laporan Dokumen Harian',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Total dokumen: $totalDokumen',
                style:
                    const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              if (widget.daftarSJ
                  .isNotEmpty) ...[
                sectionTitle(
                  'SURAT JALAN (${widget.daftarSJ.length})',
                ),

                daftarDokumen(
                  widget.daftarSJ,
                  'SJ',
                ),

                const SizedBox(
                  height: 20,
                ),
              ],

              if (widget.daftarGRN
                  .isNotEmpty) ...[
                sectionTitle(
                  'GRN (${widget.daftarGRN.length})',
                ),

                daftarDokumen(
                  widget.daftarGRN,
                  'GRN',
                ),

                const SizedBox(
                  height: 24,
                ),
              ],

              const Text(
                'Petugas Logistik',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              TextField(
                controller:
                    petugasController,
                textInputAction:
                    TextInputAction
                        .next,
                decoration:
                    const InputDecoration(
                  border:
                      OutlineInputBorder(),
                  hintText:
                      'Nama petugas Logistik',
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'Nama Accounting / Finance',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              TextField(
                controller:
                    financeController,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    const InputDecoration(
                  border:
                      OutlineInputBorder(),
                  hintText:
                      'Nama petugas Finance',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tanda Tangan Finance',
                      style:
                          TextStyle(
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      signatureController
                          .clear();
                    },
                    icon:
                        const Icon(
                      Icons
                          .delete_outline,
                    ),
                    label:
                        const Text(
                      'Hapus',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              Container(
                width:
                    double.infinity,
                height: 220,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  border:
                      Border.all(
                    color:
                        Colors.grey.shade400,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                child: Signature(
                  controller:
                      signatureController,
                  backgroundColor:
                      Colors.white,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Tanda tangan menggunakan jari pada area di atas.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 58,
                child:
                    ElevatedButton
                        .icon(
                  icon: sedangMenyimpan
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .picture_as_pdf,
                        ),
                  label: Text(
                    sedangMenyimpan
                        ? 'MENYIMPAN...'
                        : 'SIMPAN & BUAT PDF',
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  onPressed:
                      sedangMenyimpan
                          ? null
                          : simpanLaporan,
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:public_file_saver/public_file_saver.dart';

class PdfService {
  static Future<String> buatLaporanSJ({
    required List<String> daftarSJ,
    required List<String> daftarGRN,
    required String petugas,
    required String namaFinance,
    required Uint8List signatureBytes,
    required DateTime tanggalMulai,
  }) async {
    // ========================================================
    // LOCALE
    // ========================================================

    await initializeDateFormatting(
      'id_ID',
      null,
    );

    // ========================================================
    // TANGGAL
    // ========================================================

    final now = DateTime.now();

    final tanggalMulaiTampil = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(tanggalMulai);

    final tanggalFinalTampil = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(now);

    final tanggalFile = DateFormat(
      'yyyy-MM-dd',
    ).format(now);

    // ========================================================
    // DOCUMENT
    // ========================================================

    final doc = pw.Document();

    final signatureImage =
        pw.MemoryImage(signatureBytes);

    // ========================================================
    // PAGE
    // ========================================================

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(
          40,
        ),

        build: (context) {
          return [
            // ==================================================
            // HEADER
            // ==================================================

            pw.Text(
              'PT KABELINDO MURNI TBK',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.Text(
              'LOGISTIK',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 25,
            ),

            pw.Center(
              child: pw.Text(
                'LAPORAN SURAT JALAN & GRN HARIAN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
                textAlign:
                    pw.TextAlign.center,
              ),
            ),

            pw.SizedBox(
              height: 25,
            ),

            // ==================================================
            // INFORMASI LAPORAN
            // ==================================================

            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(
                  90,
                ),
                1: const pw.FlexColumnWidth(),
              },

              children: [
                _infoRow(
                  'Mulai',
                  tanggalMulaiTampil,
                ),

                _infoRow(
                  'Final',
                  tanggalFinalTampil,
                ),

                _infoRow(
                  'Petugas',
                  petugas,
                ),

                _infoRow(
                  'Departemen',
                  'LOGISTIK',
                ),
              ],
            ),

            pw.SizedBox(
              height: 25,
            ),

            // ==================================================
            // SURAT JALAN
            // ==================================================

            if (daftarSJ.isNotEmpty) ...[
              pw.Text(
                'SURAT JALAN',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(
                height: 8,
              ),

              _documentTable(
                daftarSJ,
              ),

              pw.SizedBox(
                height: 20,
              ),
            ],

            // ==================================================
            // GRN
            // ==================================================

            if (daftarGRN.isNotEmpty) ...[
              pw.Text(
                'GRN',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(
                height: 8,
              ),

              _documentTable(
                daftarGRN,
              ),

              pw.SizedBox(
                height: 20,
              ),
            ],

            // ==================================================
            // TOTAL
            // ==================================================

            pw.Text(
              'Jumlah Surat Jalan : ${daftarSJ.length}',
              style: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.Text(
              'Jumlah GRN : ${daftarGRN.length}',
              style: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.Text(
              'Total Dokumen : ${daftarSJ.length + daftarGRN.length}',
              style: pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 35,
            ),

            // ==================================================
            // TANDA TANGAN
            // ==================================================

            pw.Text(
              'Mengetahui,',
              style:
                  const pw.TextStyle(
                fontSize: 12,
              ),
            ),

            pw.SizedBox(
              height: 8,
            ),

            pw.Text(
              'ACCOUNTING / FINANCE',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(
              height: 15,
            ),

            pw.Container(
              width: 220,
              height: 100,

              alignment:
                  pw.Alignment.centerLeft,

              child: pw.Image(
                signatureImage,
                fit: pw.BoxFit.contain,
              ),
            ),

            pw.SizedBox(
              height: 8,
            ),

            pw.Container(
              width: 250,

              decoration:
                  const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color:
                        PdfColors.black,
                  ),
                ),
              ),

              child: pw.Padding(
                padding:
                    const pw.EdgeInsets.only(
                  bottom: 3,
                ),

                child: pw.Text(
                  namaFinance,
                  style:
                      const pw.TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
            ),

            pw.SizedBox(
              height: 5,
            ),

            pw.Text(
              'Nama Finance',
              style:
                  const pw.TextStyle(
                fontSize: 9,
              ),
            ),

            pw.SizedBox(
              height: 12,
            ),

            pw.Text(
              'Tanggal Final : $tanggalFinalTampil',
              style:
                  const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ];
        },
      ),
    );

    // ========================================================
    // GENERATE PDF BYTES
    // ========================================================

    final Uint8List pdfBytes =
        Uint8List.fromList(
      await doc.save(),
    );

    // ========================================================
    // SAVE TO DOWNLOAD
    // ========================================================

    final saver =
        PublicFileSaver();

    final String namaFile =
        'Laporan_SJ_GRN_$tanggalFile.pdf';

    final result =
        await saver.saveBytes(
      bytes: pdfBytes,
      fileName: namaFile,
      mimeType: 'application/pdf',
      subDir: 'Laporan SJ',
    );

    // saveBytes() mengembalikan PublicSavedFile?
    if (result == null) {
      throw Exception(
        'Gagal menyimpan PDF ke Download.',
      );
    }

    if (!result.isSuccess) {
      throw Exception(
        'PDF gagal disimpan ke Download.',
      );
    }

    // Android 10+ biasanya mengembalikan URI.
    // Android lama biasanya path.
    // fileName selalu tersedia.
    return result.uri ??
        result.path ??
        result.fileName;
  }

  // ========================================================
  // TABEL INFORMASI
  // ========================================================

  static pw.TableRow _infoRow(
    String label,
    String value,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding:
              const pw.EdgeInsets.symmetric(
            vertical: 3,
          ),

          child: pw.Text(
            '$label :',
            style: pw.TextStyle(
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Padding(
          padding:
              const pw.EdgeInsets.symmetric(
            vertical: 3,
          ),

          child: pw.Text(
            value,
          ),
        ),
      ],
    );
  }

  // ========================================================
  // TABEL DOKUMEN
  // ========================================================

  static pw.Widget _documentTable(
    List<String> data,
  ) {
    return pw.Table(
      border:
          pw.TableBorder.all(
        color:
            PdfColors.grey700,
      ),

      columnWidths: {
        0: const pw.FixedColumnWidth(
          45,
        ),

        1: const pw.FlexColumnWidth(),
      },

      children: [
        // Header
        pw.TableRow(
          decoration:
              const pw.BoxDecoration(
            color:
                PdfColors.grey200,
          ),

          children: [
            _tableCell(
              'No',
              bold: true,
              align:
                  pw.TextAlign.center,
            ),

            _tableCell(
              'Nomor',
              bold: true,
            ),
          ],
        ),

        // Data
        ...List.generate(
          data.length,
          (index) {
            return pw.TableRow(
              children: [
                _tableCell(
                  '${index + 1}',
                  align:
                      pw.TextAlign.center,
                ),

                _tableCell(
                  data[index],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ========================================================
  // TABLE CELL
  // ========================================================

  static pw.Widget _tableCell(
    String text, {
    bool bold = false,
    pw.TextAlign align =
        pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(
        7,
      ),

      child: pw.Text(
        text,

        textAlign:
            align,

        style: pw.TextStyle(
          fontSize: 10,

          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
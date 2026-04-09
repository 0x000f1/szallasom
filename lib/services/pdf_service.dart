import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndShareInvoice({
    required Map<String, dynamic> invoiceData,
    required String sellerName,
    required String sellerAddress,
    required String sellerTaxNum,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // JAVÍTVA
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, // JAVÍTVA
                  children: [
                    pw.Text("SZAMLA (TERVEZET)", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, // JAVÍTVA
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start, // JAVÍTVA
                        children: [
                          pw.Text("Kibocsato:", style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                          pw.Text(sellerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(sellerAddress),
                          pw.Text("Adoszam: $sellerTaxNum"),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start, // JAVÍTVA
                        children: [
                          pw.Text("Vevo:", style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                          pw.Text(invoiceData['name'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(invoiceData['address']),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: ['Megnevezes', 'Idoszak', 'Osszeg'],
                  data: [
                    ['Szallasszolgaltatas', '${invoiceData['checkIn']} - ${invoiceData['checkOut']}', '${invoiceData['price']} Ft'],
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Osszesen: ${invoiceData['price']} Ft", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(), 
      filename: 'szamla_${invoiceData['name']}.pdf'
    );
  }
}
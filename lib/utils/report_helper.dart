import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:laundry_kuy/models/order_model.dart';
import 'package:laundry_kuy/utils/helpers.dart';
import 'package:laundry_kuy/utils/constants.dart';

class ReportHelper {
  static Future<void> printMonthlyReport({
    required int month,
    required int year,
    required List<OrderModel> orders,
    required double totalRevenue,
  }) async {
    try {
      final pdf = pw.Document();
      // Use Indonesian locale for the month name
      final dateStr = DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year, month));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(dateStr),
            pw.SizedBox(height: 24),
            _buildOrderTable(orders),
            pw.SizedBox(height: 20),
            _buildTotalFooter(totalRevenue),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Laporan_LaundryKuy_${month}_${year}.pdf',
      );
    } catch (e) {
      print('PDF Error: $e');
      // On web we can't easily show a snackbar from a static method without context
      // but the exception will at least be caught
    }
  }

  static pw.Widget _buildHeader(String dateStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          AppStrings.appName.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Text(
          'LAPORAN KEUANGAN BULANAN',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 2,
          color: PdfColors.blue900,
          width: double.infinity,
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Periode: $dateStr',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Dicetak pada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildOrderTable(List<OrderModel> orders) {
    final headers = ['No', 'Nama Pelanggan', 'Total Harga'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: List.generate(orders.length, (index) {
        final order = orders[index];
        return [
          (index + 1).toString(),
          order.customerName,
          Helpers.formatRupiah(order.totalPrice),
        ];
      }),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(120),
      },
    );
  }

  static pw.Widget _buildTotalFooter(double totalRevenue) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'TOTAL PENDAPATAN: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.Text(
                Helpers.formatRupiah(totalRevenue),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Terima kasih telah menggunakan ${AppStrings.appName}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              'Laporan Otomatis sistem Laundry.kuy',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}

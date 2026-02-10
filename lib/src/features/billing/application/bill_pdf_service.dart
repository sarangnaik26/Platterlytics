import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../settings/domain/bill_settings_model.dart';
import '../../billing/domain/bill_model.dart';
import '../../../core/utils/formatters.dart';

class BillPdfService {
  Future<void> printBill(
    Bill bill,
    BillSettings settings,
    String Function(DateTime) formatDate,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              if (settings.showOnBill) ...[
                if (settings.showBusinessName)
                  pw.Center(
                    child: pw.Text(
                      settings.businessName.toUpperCase(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                if (settings.showAddress && settings.address.isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      "Address: ${settings.address}",
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                if (settings.showContactInfo && settings.contactInfo.isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      "Contact: ${settings.contactInfo}",
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                pw.SizedBox(height: 10),
              ] else ...[
                pw.Center(
                  child: pw.Text(
                    "Platterlytics",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],

              pw.Divider(),
              pw.Text(
                "Bill #${bill.billId}",
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                "Date: ${formatDate(DateTime.tryParse(bill.date) ?? DateTime.now())} ${bill.time}",
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Divider(),

              // Items Section
              ...bill.items.map((item) {
                final formattedItemPrice = settings.currencyAtEnd
                    ? "${item.totalItemPrice.toStringAsFixed(2)} ${settings.currencySymbol}"
                    : "${settings.currencySymbol} ${item.totalItemPrice.toStringAsFixed(2)}";

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.itemName,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "${formatQuantity(item.quantity)} ${item.unit} x ${settings.currencySymbol}${item.price.toStringAsFixed(2)}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          formattedItemPrice,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                  ],
                );
              }),
              pw.Divider(),

              // Total Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Total",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    settings.currencyAtEnd
                        ? "${bill.totalPrice.toStringAsFixed(2)} ${settings.currencySymbol}"
                        : "${settings.currencySymbol} ${bill.totalPrice.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Footer Note
              if (settings.showOnBill &&
                  settings.showFooterNote &&
                  settings.footerNote.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    settings.footerNote,
                    style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],

              // App Branding
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  "Platterlytics",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Bill-${bill.billId}',
    );
  }
}

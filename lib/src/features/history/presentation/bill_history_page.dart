import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../billing/data/bill_repository.dart';
import '../../billing/domain/bill_model.dart';

// Provider for History
final billHistoryProvider = FutureProvider.autoDispose
    .family<List<Bill>, String?>((ref, date) async {
      final repo = ref.watch(billRepositoryProvider);
      return repo.getBills(date: date);
    });

class BillHistoryPage extends ConsumerStatefulWidget {
  const BillHistoryPage({super.key});

  @override
  ConsumerState<BillHistoryPage> createState() => _BillHistoryPageState();
}

class _BillHistoryPageState extends ConsumerState<BillHistoryPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final filterDate = _selectedDate != null
        ? dateFormat.format(_selectedDate!)
        : null;

    final billsAsync = ref.watch(billHistoryProvider(filterDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill History"),
        actions: [
          IconButton(
            icon: Icon(
              _selectedDate == null ? Icons.filter_alt_off : Icons.filter_alt,
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDate: _selectedDate ?? DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) return const Center(child: Text("No Bills Found"));

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return ListTile(
                leading: CircleAvatar(child: Text(bill.billId.toString())),
                title: Text("Total: ${bill.totalPrice.toStringAsFixed(2)}"),
                subtitle: Text("${bill.date} ${bill.time}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillDetailsPage(bill: bill),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class BillDetailsPage extends StatelessWidget {
  final Bill bill;
  const BillDetailsPage({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bill #${bill.billId}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printBill(bill),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Date: ${bill.date}"),
            subtitle: Text("Time: ${bill.time}"),
            trailing: Text(
              "Total: ${bill.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: bill.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = bill.items[index];
                return ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                    "${item.quantity} x ${item.unit} @ ${item.price}",
                  ),
                  trailing: Text(item.totalItemPrice.toStringAsFixed(2)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printBill(Bill bill) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "Platterlytics",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              pw.Divider(),
              pw.Text("Bill #${bill.billId}"),
              pw.Text("Date: ${bill.date} ${bill.time}"),
              pw.Divider(),
              ...bill.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        "${item.quantity} x ${item.itemName} (${item.unit})",
                      ),
                    ),
                    pw.Text(item.totalItemPrice.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Total",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    bill.totalPrice.toStringAsFixed(2),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "Thank you!",
                  style: const pw.TextStyle(fontSize: 12),
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

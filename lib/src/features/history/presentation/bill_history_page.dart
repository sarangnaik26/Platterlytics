import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../billing/data/bill_repository.dart';
import '../../billing/domain/bill_model.dart';
import '../../billing/application/bill_pdf_service.dart';
import '../../settings/presentation/bill_settings_provider.dart';
import '../../settings/presentation/date_format_provider.dart';
import '../../../core/utils/formatters.dart';

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
    final symbol = ref.watch(currencySymbolProvider);

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
                title: Text(
                  "Total: $symbol${bill.totalPrice.toStringAsFixed(2)}",
                ),
                subtitle: Consumer(
                  builder: (context, ref, _) {
                    final formatDate = ref.watch(formatDateProvider);
                    final bDate =
                        DateTime.tryParse(bill.date) ?? DateTime.now();
                    return Text("${formatDate(bDate)} ${bill.time}");
                  },
                ),
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

class BillDetailsPage extends ConsumerWidget {
  final Bill bill;
  const BillDetailsPage({super.key, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Bill #${bill.billId}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              final formatDate = ref.read(formatDateProvider);
              final settings = ref.read(billSettingsControllerProvider).value;
              if (settings != null) {
                BillPdfService().printBill(bill, settings, formatDate);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Consumer(
              builder: (context, ref, _) {
                final formatDate = ref.watch(formatDateProvider);
                final bDate = DateTime.tryParse(bill.date) ?? DateTime.now();
                return Text("Date: ${formatDate(bDate)}");
              },
            ),
            subtitle: Text("Time: ${bill.time}"),
            trailing: Text(
              "Total: $symbol${bill.totalPrice.toStringAsFixed(2)}",
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
                    "${formatQuantity(item.quantity)} x ${item.unit} @ $symbol${item.price}",
                  ),
                  trailing: Text(
                    "$symbol${item.totalItemPrice.toStringAsFixed(2)}",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

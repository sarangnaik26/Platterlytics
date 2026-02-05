import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/bill_model.dart';
import '../../settings/presentation/bill_settings_provider.dart';
import '../../settings/domain/bill_settings_model.dart';
import '../../settings/presentation/date_format_provider.dart';

class BillSuccessView extends ConsumerStatefulWidget {
  final Bill bill;
  const BillSuccessView({super.key, required this.bill});

  @override
  ConsumerState<BillSuccessView> createState() => _BillSuccessViewState();
}

class _BillSuccessViewState extends ConsumerState<BillSuccessView> {
  final ScreenshotController _screenshotController = ScreenshotController();

  void _shareAsText(Bill bill, BillSettings settings) {
    String text = "";
    if (settings.showOnBill) {
      if (settings.showBusinessName) text += "${settings.businessName}\n";
      if (settings.showAddress) text += "Address: ${settings.address}\n";
      if (settings.showContactInfo) {
        text += "Contact: ${settings.contactInfo}\n";
      }
      text += "\n";
    }
    text += "Bill #${bill.billId}\n";
    final formatDate = ref.read(formatDateProvider);
    final bDate = DateTime.tryParse(bill.date) ?? DateTime.now();
    text += "Date: ${formatDate(bDate)} ${bill.time}\n";
    text += "--------------------------------\n";
    for (var item in bill.items) {
      final formattedPrice = settings.currencyAtEnd
          ? "${item.totalItemPrice.toStringAsFixed(2)} ${settings.currencySymbol}"
          : "${settings.currencySymbol} ${item.totalItemPrice.toStringAsFixed(2)}";
      text +=
          "${item.itemName} (${item.quantity} x ${item.unit}) : $formattedPrice\n";
    }
    text += "--------------------------------\n";
    final formattedTotal = settings.currencyAtEnd
        ? "${bill.totalPrice.toStringAsFixed(2)} ${settings.currencySymbol}"
        : "${settings.currencySymbol} ${bill.totalPrice.toStringAsFixed(2)}";
    text += "Total: $formattedTotal\n";
    if (settings.showOnBill && settings.showFooterNote) {
      text += "\n${settings.footerNote}";
    }

    // ignore: deprecated_member_use
    Share.share(text);
  }

  Future<void> _shareAsImage() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final imagePath = await _screenshotController.captureAndSave(directory);
    if (imagePath != null) {
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'Bill from Platterlytics');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(billSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill Generated"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (settings.showOnBill) ...[
                        if (settings.showBusinessName)
                          Text(
                            settings.businessName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        if (settings.showAddress)
                          Text(
                            "Address: ${settings.address}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        if (settings.showContactInfo)
                          Text(
                            "Contact: ${settings.contactInfo}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        const Divider(height: 24),
                      ],
                      Text(
                        "Bill #${widget.bill.billId}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final formatDate = ref.watch(formatDateProvider);
                          final bDate =
                              DateTime.tryParse(widget.bill.date) ??
                              DateTime.now();
                          return Text(
                            "Date: ${formatDate(bDate)} ${widget.bill.time}",
                            style: const TextStyle(color: Colors.black),
                          );
                        },
                      ),
                      const Divider(height: 24),
                      ...widget.bill.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "${item.itemName} (${item.quantity} x ${item.unit})",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              Consumer(
                                builder: (context, ref, child) {
                                  return Text(
                                    ref.watch(
                                      formatCurrencyProvider(
                                        item.totalItemPrice,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              return Text(
                                ref.watch(
                                  formatCurrencyProvider(
                                    widget.bill.totalPrice,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      if (settings.showOnBill && settings.showFooterNote) ...[
                        const SizedBox(height: 16),
                        Text(
                          settings.footerNote,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: QrImageView(
                          data: _generateQrData(widget.bill, settings),
                          version: QrVersions.auto,
                          size: 150.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Scan to view bill",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareAsText(widget.bill, settings),
                      icon: const Icon(Icons.text_fields),
                      label: const Text("Share as Text"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareAsImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Share as Image"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  String _generateQrData(Bill bill, BillSettings settings) {
    String text = "";

    // Header Section
    if (settings.showOnBill) {
      if (settings.showBusinessName) {
        text += "${settings.businessName.toUpperCase()}\n";
      }
      if (settings.showAddress && settings.address.isNotEmpty) {
        text += "${settings.address}\n";
      }
      if (settings.showContactInfo && settings.contactInfo.isNotEmpty) {
        text += "${settings.contactInfo}\n";
      }
      if (text.isNotEmpty) text += "\n";
    }

    text += "******** BILL RECEIPT ********\n";
    text += "Bill No: ${bill.billId}\n";

    final formatDate = ref.read(formatDateProvider);
    final bDate = DateTime.tryParse(bill.date) ?? DateTime.now();
    text += "Date:    ${formatDate(bDate)} ${bill.time}\n";
    text += "------------------------------\n";

    // Items Section
    for (var item in bill.items) {
      final formattedItemPrice = settings.currencyAtEnd
          ? "${item.totalItemPrice.toStringAsFixed(2)} ${settings.currencySymbol}"
          : "${settings.currencySymbol} ${item.totalItemPrice.toStringAsFixed(2)}";

      final unitPrice = item.price.toStringAsFixed(2);

      text += "${item.itemName}\n";
      text +=
          "  ${item.quantity} ${item.unit} x ${settings.currencySymbol}$unitPrice = $formattedItemPrice\n";
    }
    text += "------------------------------\n";

    // Total Section
    final formattedTotal = settings.currencyAtEnd
        ? "${bill.totalPrice.toStringAsFixed(2)} ${settings.currencySymbol}"
        : "${settings.currencySymbol} ${bill.totalPrice.toStringAsFixed(2)}";

    text += "TOTAL AMOUNT: $formattedTotal\n";
    text += "------------------------------\n";

    // Footer Note
    if (settings.showOnBill &&
        settings.showFooterNote &&
        settings.footerNote.isNotEmpty) {
      text += "\n${settings.footerNote}\n";
    }

    // App Branding (Bottom Right aligned simulation)
    text += "\n\n\n";
    text += "      Generated by Platterlytics";

    return text;
  }
}

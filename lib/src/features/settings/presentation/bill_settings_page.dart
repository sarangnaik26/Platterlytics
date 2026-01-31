import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bill_settings_provider.dart';
import '../../settings/domain/bill_settings_model.dart';

class BillSettingsPage extends ConsumerStatefulWidget {
  const BillSettingsPage({super.key});

  @override
  ConsumerState<BillSettingsPage> createState() => _BillSettingsPageState();
}

class _BillSettingsPageState extends ConsumerState<BillSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _contactInfoController;
  late TextEditingController _footerNoteController;
  String _selectedCurrency = '₹';
  bool _showBusinessName = true;
  bool _showAddress = true;
  bool _showContactInfo = true;
  bool _showFooterNote = true;
  bool _showOnBill = true;
  bool _isInit = false;

  final List<Map<String, String>> _asianCurrencies = [
    {'name': 'India', 'code': 'INR', 'symbol': '₹'},
    {'name': 'Pakistan', 'code': 'PKR', 'symbol': '₨'},
    {'name': 'Bangladesh', 'code': 'BDT', 'symbol': '৳'},
    {'name': 'Sri Lanka', 'code': 'LKR', 'symbol': 'Rs'},
    {'name': 'Nepal', 'code': 'NPR', 'symbol': 'Rs.'},
    {'name': 'Japan', 'code': 'JPY', 'symbol': '¥'},
    {'name': 'China', 'code': 'CNY', 'symbol': '¥'},
    {'name': 'South Korea', 'code': 'KRW', 'symbol': '₩'},
    {'name': 'Singapore', 'code': 'SGD', 'symbol': 'S\$'},
    {'name': 'Malaysia', 'code': 'MYR', 'symbol': 'RM'},
    {'name': 'Thailand', 'code': 'THB', 'symbol': '฿'},
    {'name': 'Indonesia', 'code': 'IDR', 'symbol': 'Rp'},
    {'name': 'Philippines', 'code': 'PHP', 'symbol': '₱'},
    {'name': 'Vietnam', 'code': 'VND', 'symbol': '₫'},
  ];

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _contactInfoController = TextEditingController();
    _footerNoteController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _contactInfoController.dispose();
    _footerNoteController.dispose();
    super.dispose();
  }

  void _loadSettings(BillSettings settings) {
    if (!_isInit) {
      _businessNameController.text = settings.businessName;
      _addressController.text = settings.address;
      _contactInfoController.text = settings.contactInfo;
      _footerNoteController.text = settings.footerNote;
      _selectedCurrency = settings.currencySymbol;
      _showBusinessName = settings.showBusinessName;
      _showAddress = settings.showAddress;
      _showContactInfo = settings.showContactInfo;
      _showFooterNote = settings.showFooterNote;
      _showOnBill = settings.showOnBill;
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(billSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Bill Settings")),
      body: settingsAsync.when(
        data: (settings) {
          _loadSettings(settings);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Currency Settings",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value:
                      _asianCurrencies.any(
                        (c) => c['symbol'] == _selectedCurrency,
                      )
                      ? _selectedCurrency
                      : '₹',
                  decoration: const InputDecoration(
                    labelText: "Select Currency",
                    prefixIcon: Icon(Icons.currency_exchange),
                  ),
                  items: _asianCurrencies.map((c) {
                    return DropdownMenuItem(
                      value: c['symbol'],
                      child: Text(
                        "${c['name']} (${c['code']} - ${c['symbol']})",
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCurrency = val);
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                SwitchListTile(
                  title: const Text("Show on Bill"),
                  subtitle: const Text(
                    "Enable to show these details on generated bills",
                  ),
                  value: _showOnBill,
                  onChanged: (val) {
                    setState(() {
                      _showOnBill = val;
                    });
                  },
                ),
                const Divider(),
                if (_showOnBill) ...[
                  _buildToggleField(
                    label: "Business Name",
                    controller: _businessNameController,
                    value: _showBusinessName,
                    onChanged: (val) => setState(() => _showBusinessName = val),
                    validator: (val) =>
                        _showBusinessName && (val == null || val.isEmpty)
                        ? 'Please enter business name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildToggleField(
                    label: "Address",
                    controller: _addressController,
                    value: _showAddress,
                    onChanged: (val) => setState(() => _showAddress = val),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildToggleField(
                    label: "Contact Info",
                    controller: _contactInfoController,
                    value: _showContactInfo,
                    onChanged: (val) => setState(() => _showContactInfo = val),
                  ),
                  const SizedBox(height: 16),
                  _buildToggleField(
                    label: "Footer Note",
                    controller: _footerNoteController,
                    value: _showFooterNote,
                    onChanged: (val) => setState(() => _showFooterNote = val),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newSettings = BillSettings(
                        businessName: _businessNameController.text,
                        address: _addressController.text,
                        contactInfo: _contactInfoController.text,
                        footerNote: _footerNoteController.text,
                        currencySymbol: _selectedCurrency,
                        showBusinessName: _showBusinessName,
                        showAddress: _showAddress,
                        showContactInfo: _showContactInfo,
                        showFooterNote: _showFooterNote,
                        showOnBill: _showOnBill,
                      );
                      ref
                          .read(billSettingsControllerProvider.notifier)
                          .updateSettings(newSettings);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Settings Saved")),
                      );
                    }
                  },
                  child: const Text("Save Settings"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildToggleField({
    required String label,
    required TextEditingController controller,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      children: [
        SwitchListTile(
          title: Text("Show $label"),
          value: value,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
        ),
        if (value)
          TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            validator: validator,
            maxLines: maxLines,
          ),
      ],
    );
  }
}

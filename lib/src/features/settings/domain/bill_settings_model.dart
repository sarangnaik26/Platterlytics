class BillSettings {
  final String businessName;
  final String address;
  final String contactInfo;
  final String footerNote;
  final String currencySymbol;
  final bool showBusinessName;
  final bool showAddress;
  final bool showContactInfo;
  final bool showFooterNote;
  final bool showOnBill;

  BillSettings({
    this.businessName = '',
    this.address = '',
    this.contactInfo = '',
    this.footerNote = 'Thank you for dining with us!',
    this.currencySymbol = '₹',
    this.showBusinessName = true,
    this.showAddress = true,
    this.showContactInfo = true,
    this.showFooterNote = true,
    this.showOnBill = true,
  });

  BillSettings copyWith({
    String? businessName,
    String? address,
    String? contactInfo,
    String? footerNote,
    String? currencySymbol,
    bool? showBusinessName,
    bool? showAddress,
    bool? showContactInfo,
    bool? showFooterNote,
    bool? showOnBill,
  }) {
    return BillSettings(
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      contactInfo: contactInfo ?? this.contactInfo,
      footerNote: footerNote ?? this.footerNote,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      showBusinessName: showBusinessName ?? this.showBusinessName,
      showAddress: showAddress ?? this.showAddress,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      showFooterNote: showFooterNote ?? this.showFooterNote,
      showOnBill: showOnBill ?? this.showOnBill,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'address': address,
      'contactInfo': contactInfo,
      'footerNote': footerNote,
      'currencySymbol': currencySymbol,
      'showBusinessName': showBusinessName,
      'showAddress': showAddress,
      'showContactInfo': showContactInfo,
      'showFooterNote': showFooterNote,
      'showOnBill': showOnBill,
    };
  }

  factory BillSettings.fromMap(Map<String, dynamic> map) {
    return BillSettings(
      businessName: map['businessName'] ?? '',
      address: map['address'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      footerNote: map['footerNote'] ?? 'Thank you for dining with us!',
      currencySymbol: map['currencySymbol'] ?? '₹',
      showBusinessName: map['showBusinessName'] ?? true,
      showAddress: map['showAddress'] ?? true,
      showContactInfo: map['showContactInfo'] ?? true,
      showFooterNote: map['showFooterNote'] ?? true,
      showOnBill: map['showOnBill'] ?? true,
    );
  }
}

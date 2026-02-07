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
  final bool currencyAtEnd;

  BillSettings({
    this.businessName = '',
    this.address = '',
    this.contactInfo = '',
    this.footerNote = 'Thank you for dining with us!',
    this.currencySymbol = '₹',
    this.showBusinessName = false,
    this.showAddress = false,
    this.showContactInfo = false,
    this.showFooterNote = true,
    this.showOnBill = true,
    this.currencyAtEnd = true,
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
    bool? currencyAtEnd,
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
      currencyAtEnd: currencyAtEnd ?? this.currencyAtEnd,
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
      'currencyAtEnd': currencyAtEnd,
    };
  }

  factory BillSettings.fromMap(Map<String, dynamic> map) {
    return BillSettings(
      businessName: map['businessName'] ?? '',
      address: map['address'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      footerNote: map['footerNote'] ?? 'Thank you for dining with us!',
      currencySymbol: map['currencySymbol'] ?? '₹',
      showBusinessName: map['showBusinessName'] ?? false,
      showAddress: map['showAddress'] ?? false,
      showContactInfo: map['showContactInfo'] ?? false,
      showFooterNote: map['showFooterNote'] ?? true,
      showOnBill: map['showOnBill'] ?? true,
      currencyAtEnd: map['currencyAtEnd'] ?? true,
    );
  }
}

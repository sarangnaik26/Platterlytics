class UserProfile {
  final String ownerName;
  final String businessName;
  final String contactInfo;

  UserProfile({
    this.ownerName = '',
    this.businessName = '',
    this.contactInfo = '',
  });

  UserProfile copyWith({
    String? ownerName,
    String? businessName,
    String? contactInfo,
  }) {
    return UserProfile(
      ownerName: ownerName ?? this.ownerName,
      businessName: businessName ?? this.businessName,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'businessName': businessName,
      'contactInfo': contactInfo,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      ownerName: map['ownerName'] ?? '',
      businessName: map['businessName'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
    );
  }
}

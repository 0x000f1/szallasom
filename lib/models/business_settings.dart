class BusinessSettings {
  final String companyName;
  final String address;
  final String taxNumber;
  final String ntakId;
  final String billingProvider; // pl. "Billingo" vagy "Számlázz.hu"
  final String billingEmail;

  BusinessSettings({
    this.companyName = '',
    this.address = '',
    this.taxNumber = '',
    this.ntakId = '',
    this.billingProvider = 'Billingo',
    this.billingEmail = '',
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'address': address,
    'taxNumber': taxNumber,
    'ntakId': ntakId,
    'billingProvider': billingProvider,
    'billingEmail': billingEmail,
  };

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      ntakId: json['ntakId'] ?? '',
      billingProvider: json['billingProvider'] ?? 'Billingo',
      billingEmail: json['billingEmail'] ?? '',
    );
  }
}
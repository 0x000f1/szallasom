class Apartment {
  final String id;
  final String name;
  final String? bookingIcalUrl; // ÚJ: Booking URL
  final String? airbnbIcalUrl;  // ÚJ: Airbnb URL

  Apartment({
    required this.id, 
    required this.name,
    this.bookingIcalUrl,
    this.airbnbIcalUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name,
    'bookingIcalUrl': bookingIcalUrl,
    'airbnbIcalUrl': airbnbIcalUrl,
  };
  
  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'], 
      name: json['name'],
      bookingIcalUrl: json['bookingIcalUrl'],
      airbnbIcalUrl: json['airbnbIcalUrl'],
    );
  }
}
import 'package:flutter/material.dart';

enum BookingSource { booking, airbnb, manual }

class Booking {
  final String id;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final BookingSource source;

  Booking({
    required this.id,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.source,
  });

  Color get cardColor {
    switch (source) {
      case BookingSource.booking:
        return const Color(0xFFE3F2FD);
      case BookingSource.airbnb:
        return const Color(0xFFFFEBEE);
      case BookingSource.manual:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get textColor {
    switch (source) {
      case BookingSource.booking:
        return const Color(0xFF1565C0);
      case BookingSource.airbnb:
        return const Color(0xFFC62828);
      case BookingSource.manual:
        return const Color(0xFF2E7D32);
    }
  }

  // --- ÚJ: JSON konverzió a lokális mentéshez ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'guestName': guestName,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'source': source.name,
  };

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      guestName: json['guestName'],
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      // Enum visszafejtése String-ből
      source: BookingSource.values.firstWhere(
        (e) => e.name == json['source'], 
        orElse: () => BookingSource.manual,
      ),
    );
  }
}
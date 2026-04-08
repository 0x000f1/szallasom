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
        return const Color(0xFFE3F2FD); // pastel blue
      case BookingSource.airbnb:
        return const Color(0xFFFFEBEE); // pastel red
      case BookingSource.manual:
        return const Color(0xFFE8F5E9); // pastel green
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
}
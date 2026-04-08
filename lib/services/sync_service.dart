import 'package:http/http.dart' as http;
import '../models/booking.dart';

class SyncService {
  
  // Mock adatok generálása átfedésekkel
  Future<List<Booking>> getMockBookings() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Szimulált hálózat
    
    final now = DateTime.now();
    return [
      Booking(
        id: '1',
        guestName: 'Kovács Család',
        checkIn: now.subtract(const Duration(days: 2)),
        checkOut: now.add(const Duration(days: 3)),
        source: BookingSource.booking,
      ),
      Booking(
        id: '2',
        guestName: 'John Doe',
        checkIn: now.add(const Duration(days: 3)), // Ugyanazon a napon érkezik, mint Kovács távozik
        checkOut: now.add(const Duration(days: 7)),
        source: BookingSource.airbnb,
      ),
      Booking(
        id: '3',
        guestName: 'Nagy Péter',
        checkIn: now.add(const Duration(days: 10)),
        checkOut: now.add(const Duration(days: 12)),
        source: BookingSource.manual,
      ),
      // Következő hónap
      Booking(
        id: '4',
        guestName: 'Smith Family',
        checkIn: DateTime(now.year, now.month + 1, 5),
        checkOut: DateTime(now.year, now.month + 1, 10),
        source: BookingSource.booking,
      ),
      Booking(
        id: '5',
        guestName: 'Tóth Anna',
        checkIn: DateTime(now.year, now.month + 1, 9), // Átfedés a Smith családdal
        checkOut: DateTime(now.year, now.month + 1, 14),
        source: BookingSource.airbnb,
      ),
    ];
  }

  // iCal feldolgozó váz
  Future<List<Booking>> fetchAndParseIcal(String url, BookingSource source) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final icalData = response.body;
        // Itt jönne az éles VEVENT parsing.
        // Példa logika (pszeudokód):
        // 1. Split by 'BEGIN:VEVENT'
        // 2. Extract DTSTART, DTEND, SUMMARY
        // 3. Return as List<Booking>
        
        // Egyelőre visszaadjuk a mock adatokat teszteléshez
        return getMockBookings();
      } else {
        throw Exception('Failed to load iCal data');
      }
    } catch (e) {
      throw Exception('Network or parsing error: $e');
    }
  }
}
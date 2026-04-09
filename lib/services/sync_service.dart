import 'package:http/http.dart' as http;
import '../models/booking.dart';

class SyncService {
  
  // --- ÚJ: Valós HTTP szinkronizáló logika ---
  Future<List<Booking>> syncFromUrls({String? bookingUrl, String? airbnbUrl}) async {
    final List<Booking> allBookings = [];

    if (bookingUrl != null && bookingUrl.isNotEmpty) {
      allBookings.addAll(await _downloadAndParse(bookingUrl, BookingSource.booking));
    }
    
    if (airbnbUrl != null && airbnbUrl.isNotEmpty) {
      allBookings.addAll(await _downloadAndParse(airbnbUrl, BookingSource.airbnb));
    }

    return allBookings;
  }

  // HTTP Letöltés és hibakezelés
  Future<List<Booking>> _downloadAndParse(String url, BookingSource source) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return _parseIcal(response.body, source); // Átadjuk a letöltött szöveget a parsernek
      } else {
        print('Hiba a letöltésnél (${source.name}): HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Hálózati vagy feldolgozási hiba (${source.name}): $e');
    }
    return []; // Hiba esetén üres listával térünk vissza, hogy ne omoljon össze az app
  }

  // --- NATÍV iCAL PARSER (Változatlanul hagyva, mert ez már tökéletes) ---
  List<Booking> _parseIcal(String icalData, BookingSource source) {
    final List<Booking> bookings = [];
    final lines = icalData.split('\n');
    
    bool inEvent = false;
    String id = '';
    String summary = '';
    DateTime? checkIn;
    DateTime? checkOut;

    for (var line in lines) {
      line = line.trim();
      
      if (line == 'BEGIN:VEVENT') {
        inEvent = true;
        id = DateTime.now().millisecondsSinceEpoch.toString() + bookings.length.toString();
        summary = 'Ismeretlen Vendég';
        checkIn = null;
        checkOut = null;
      } else if (line == 'END:VEVENT' && inEvent) {
        if (checkIn != null && checkOut != null) {
          bookings.add(Booking(
            id: id,
            guestName: _cleanSummary(summary, source),
            checkIn: checkIn,
            checkOut: checkOut,
            source: source,
          ));
        }
        inEvent = false;
      } else if (inEvent) {
        if (line.startsWith('SUMMARY:')) {
          summary = line.substring(8);
        } else if (line.startsWith('UID:')) {
          id = line.substring(4);
        } else if (line.startsWith('DTSTART')) {
          checkIn = _parseDate(line);
        } else if (line.startsWith('DTEND')) {
          checkOut = _parseDate(line);
        }
      }
    }
    return bookings;
  }

  DateTime? _parseDate(String line) {
    try {
      final parts = line.split(':');
      if (parts.length > 1) {
        String dateStr = parts[1].replaceAll('Z', '').replaceAll('T', '');
        int year = int.parse(dateStr.substring(0, 4));
        int month = int.parse(dateStr.substring(4, 6));
        int day = int.parse(dateStr.substring(6, 8));
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _cleanSummary(String summary, BookingSource source) {
    if (source == BookingSource.booking) {
      return summary.replaceAll('CLOSED - ', '').replaceAll('Booking.com', '').trim();
    } else if (source == BookingSource.airbnb) {
      return summary.replaceAll('Reserved', 'Airbnb Vendég').replaceAll('Not available', 'Lezárva').trim();
    }
    return summary;
  }
}
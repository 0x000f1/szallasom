import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../services/sync_service.dart';

final syncServiceProvider = Provider((ref) => SyncService());

// Aszinkron Notifier az adatok letöltéséhez és tárolásához
class BookingNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    return ref.read(syncServiceProvider).getMockBookings();
  }

  Future<void> syncCalendars() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Itt hívnád meg a fetchAndParseIcal-t a Booking és Airbnb URL-ekkel
      // pl.: final bookingData = await service.fetchAndParseIcal(url1);
      // final airbnbData = await service.fetchAndParseIcal(url2);
      // return [...bookingData, ...airbnbData];
      
      return ref.read(syncServiceProvider).getMockBookings(); // Mock frissítés
    });
  }

  // Többnapos események szűrése egy adott napra
  List<Booking> getBookingsForDay(DateTime day) {
    final bookings = state.value ?? [];
    return bookings.where((b) {
      // A nap pont a checkIn és checkOut közé esik (vagy azzal megegyezik)
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final checkIn = DateTime(b.checkIn.year, b.checkIn.month, b.checkIn.day);
      final checkOut = DateTime(b.checkOut.year, b.checkOut.month, b.checkOut.day);
      
      return normalizedDay.isAfter(checkIn.subtract(const Duration(days: 1))) && 
             normalizedDay.isBefore(checkOut.add(const Duration(days: 1)));
    }).toList();
  }
}

final bookingProvider = AsyncNotifierProvider<BookingNotifier, List<Booking>>(
  () => BookingNotifier(),
);
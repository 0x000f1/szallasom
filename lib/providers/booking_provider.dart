import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/sync_service.dart';
import 'apartment_provider.dart';
import '../../main.dart';

final syncServiceProvider = Provider((ref) => SyncService());

class BookingNotifier extends AsyncNotifier<List<Booking>> {
  static const _manualKey = 'manual_bookings_';

  @override
  Future<List<Booking>> build() async {
    ref.watch(apartmentProvider); // Újratölt, ha apartmant váltunk
    return _fetchAllBookings();
  }

  // ÖSSZESÍTETT LEKÉRDEZÉS (iCal + Manuális)
  Future<List<Booking>> _fetchAllBookings() async {
    final selectedApt = ref.read(apartmentProvider).selectedApartment;
    if (selectedApt == null) return [];

    // 1. Távoli iCal adatok
    final remoteBookings = await ref.read(syncServiceProvider).syncFromUrls(
      bookingUrl: selectedApt.bookingIcalUrl,
      airbnbUrl: selectedApt.airbnbIcalUrl,
    );

    // 2. Helyi manuális adatok betöltése
    final manualBookings = _loadManualFromPrefs(selectedApt.id);

    return [...remoteBookings, ...manualBookings];
  }

  Future<void> syncCalendars() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAllBookings());
  }

  // --- MANUÁLIS FOGLALÁS HOZZÁADÁSA ÉS MENTÉSE ---
  Future<void> addManualBooking(String guestName, DateTime start, DateTime end) async {
    final selectedApt = ref.read(apartmentProvider).selectedApartment;
    if (selectedApt == null) return;

    final newBooking = Booking(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      guestName: guestName,
      checkIn: start,
      checkOut: end,
      source: BookingSource.manual,
    );

    final currentManual = _loadManualFromPrefs(selectedApt.id);
    currentManual.add(newBooking);
    await _saveManualToPrefs(selectedApt.id, currentManual);

    ref.invalidateSelf(); // UI frissítés kikényszerítése
  }

  // --- ÚJ: Manuális foglalás törlése ---
  Future<void> deleteManualBooking(String bookingId) async {
    final selectedApt = ref.read(apartmentProvider).selectedApartment;
    if (selectedApt == null) return;

    final currentManual = _loadManualFromPrefs(selectedApt.id);
    // Kikeressük és eltávolítjuk azt, amelyiknek egyezik az ID-ja
    currentManual.removeWhere((b) => b.id == bookingId);
    
    await _saveManualToPrefs(selectedApt.id, currentManual);
    ref.invalidateSelf(); // UI frissítése
  }

  // Mentésből olvasás (SharedPreferences)
  List<Booking> _loadManualFromPrefs(String aptId) {
    final prefs = ref.read(sharedPrefsProvider);
    final String? data = prefs.getString('$_manualKey$aptId');
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Booking.fromJson(json)).toList();
  }

  // Mentésbe írás
  Future<void> _saveManualToPrefs(String aptId, List<Booking> bookings) async {
    final prefs = ref.read(sharedPrefsProvider);
    final jsonList = bookings.map((b) => b.toJson()).toList();
    await prefs.setString('$_manualKey$aptId', jsonEncode(jsonList));
  }

  List<Booking> getBookingsForDay(DateTime day) {
    final bookings = state.value ?? [];
    return bookings.where((b) {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final checkIn = DateTime(b.checkIn.year, b.checkIn.month, b.checkIn.day);
      final checkOut = DateTime(b.checkOut.year, b.checkOut.month, b.checkOut.day);
      
      return (normalizedDay.isAtSameMomentAs(checkIn) || normalizedDay.isAfter(checkIn)) && 
             (normalizedDay.isAtSameMomentAs(checkOut) || normalizedDay.isBefore(checkOut));
    }).toList();
  }
}

final bookingProvider = AsyncNotifierProvider<BookingNotifier, List<Booking>>(
  () => BookingNotifier(),
);
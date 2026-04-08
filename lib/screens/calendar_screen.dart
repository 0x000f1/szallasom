import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../providers/booking_provider.dart';
import '../providers/apartment_provider.dart'; // Győződj meg róla, hogy ez a fájl is megvan!
import '../models/booking.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // --- Beállítások felcsúszó ablak ---
  void _showSettingsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apartman Beállítások', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: Color(0xFF3F51B5)),
                title: const Text('iCal Linkek (Booking/Airbnb)'),
                subtitle: const Text('Szinkronizációs URL-ek kezelése'),
                onTap: () { Navigator.pop(context); /* TODO: iCal logika */ },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_rounded, color: Color(0xFF3F51B5)),
                title: const Text('NTAK / NAV Integráció'),
                subtitle: const Text('Automatikus adatszolgáltatás beállítása'),
                onTap: () { Navigator.pop(context); /* TODO: NAV logika */ },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.grey),
                title: const Text('Általános Beállítások'),
                onTap: () { Navigator.pop(context); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Új apartman hozzáadása dialog ---
  void _showAddApartmentDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Új apartman', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Pl.: Belvárosi Stúdió',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégse', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(apartmentProvider.notifier).addApartment(textController.text);
              Navigator.pop(context); // Zárja a dialogot
              Navigator.pop(context); // Zárja a bottom sheetet is
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)),
            child: const Text('Hozzáadás', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Apartman választó Bottom Sheet ---
  void _showApartmentSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final aptState = ref.watch(apartmentProvider);
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Apartmanjaim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  if (aptState.apartments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Nincs még apartman hozzáadva.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true, 
                        itemCount: aptState.apartments.length,
                        itemBuilder: (context, index) {
                          final apt = aptState.apartments[index];
                          final isSelected = apt.id == aptState.selectedApartment?.id;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.home_work_rounded, 
                              color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[400]
                            ),
                            title: Text(
                              apt.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF3F51B5) : Colors.black87,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF3F51B5), size: 20),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    ref.read(apartmentProvider.notifier).removeApartment(apt.id);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              ref.read(apartmentProvider.notifier).selectApartment(apt);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                    
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddApartmentDialog(context),
                      icon: const Icon(Icons.add, color: Color(0xFF3F51B5)),
                      label: const Text('Új apartman hozzáadása', style: TextStyle(color: Color(0xFF3F51B5))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3F51B5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Esemény részletei felcsúszó ablak ---
  void _showEventDetails(BuildContext context, Booking booking) {
    final DateFormat detailedTimeFormat = DateFormat('yyyy. MM. dd. HH:mm');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                booking.guestName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: booking.cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  booking.source.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: booking.textColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Időtartam', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${detailedTimeFormat.format(booking.checkIn)}  -  ${detailedTimeFormat.format(booking.checkOut)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Törlés', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text('Számla', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingProvider);
    final selectedDayBookings = ref.read(bookingProvider.notifier).getBookingsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // ITT VOLT A HIBA: Egyetlen letisztult AppBar blokk
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => _showSettingsPanel(context),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFE8EAF6),
              child: Icon(Icons.person, color: Color(0xFF3F51B5)),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => _showApartmentSelector(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ref.watch(apartmentProvider).selectedApartment?.name ?? 'Nincs apartman', 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(bookingProvider.notifier).syncCalendars();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: bookingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hiba történt: $err')),
        data: (bookings) => Column(
          children: [
            _buildCalendar(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft, 
                child: Text(
                  "Kiválasztott nap eseményei", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            Expanded(
              child: _buildEventList(selectedDayBookings),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5), 
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      child: TableCalendar<Booking>(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) => ref.read(bookingProvider.notifier).getBookingsForDay(day),
        
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox();

            final sortedEvents = List<Booking>.from(events)
              ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

            return Positioned(
              bottom: 2, 
              left: 0,
              right: 0,
              child: Row(
                children: sortedEvents.map((booking) {
                  final isStart = isSameDay(day, booking.checkIn);
                  final isEnd = isSameDay(day, booking.checkOut);

                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(
                        left: isStart ? 6 : 0,
                        right: isEnd ? 6 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: booking.textColor.withOpacity(0.85),
                        borderRadius: BorderRadius.horizontal(
                          left: isStart ? const Radius.circular(4) : Radius.zero,
                          right: isEnd ? const Radius.circular(4) : Radius.zero,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),

        calendarStyle: const CalendarStyle(
          cellMargin: EdgeInsets.only(top: 4, bottom: 14, left: 4, right: 4),
          todayDecoration: BoxDecoration(color: Color(0xFFC5CAE9), shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Color(0xFF3F51B5), shape: BoxShape.circle),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, 
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildEventList(List<Booking> events) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'Nincs érkező vendég ezen a napon.', 
          style: TextStyle(color: Colors.grey[500])
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final booking = events[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final DateFormat timeFormat = DateFormat('MMM dd, HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDetails(context, booking),
          borderRadius: BorderRadius.circular(16.0),
          child: Ink(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: booking.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.guestName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: booking.textColor,
                  ),
                ),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: booking.textColor.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      '${timeFormat.format(booking.checkIn)} - ${timeFormat.format(booking.checkOut)}',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: booking.textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    booking.source.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: booking.textColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
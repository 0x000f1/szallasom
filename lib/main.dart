import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: CalendarPage(),
));

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // here comes the iCal sync with various sites
  late final Map<DateTime, List<String>> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // random generated test event for today
    final today = DateTime.now();
    final normalizedToday = DateTime.utc(today.year, today.month, today.day);
    
    _events = {
      normalizedToday: ['Booking.com - Kovacs Elek'],
      // test: another test for tomorrow
      normalizedToday.add(const Duration(days: 1)): ['Airbnb - Szabo Eva'],
    };
  }

  // gets the events formalized
  List<String> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // interacted day events (list)
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Apartman Naptár', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // calendar card design
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
              ],
            ),
            child: TableCalendar<String>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              // KIVÁLASZTÁS LOGIKÁJA
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update calendar header
                });
              },
              // STÍLUS
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: Color(0xFFC5CAE9), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Color(0xFF3F51B5), shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Color(0xFF7986CB), shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              // small dots under days (reservation indicator)
              eventLoader: _getEventsForDay,
            ),
          ),

          // event list header
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
          
          // dynamic event list
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      "Nincs érkező vendég ezen a napon.",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      // fill with [data, name] values
                      final parts = selectedEvents[index].split(' - ');
                      final source = parts[0];
                      final name = parts[1];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.door_front_door, color: Color(0xFF3F51B5)),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(source, style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
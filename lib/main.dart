import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/calendar_screen.dart'; 

// Létrehozunk egy globális providert a SharedPreferences-nek
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializáljuk a lokális tárolót az app indulása előtt
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Injektáljuk a betöltött preferenciákat a Riverpod-ba
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const ApartmentSaaSApp(),
    ),
  );
}

class ApartmentSaaSApp extends StatelessWidget {
  const ApartmentSaaSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apartment Manager SaaS',
      debugShowCheckedModeBanner: false, // Eltüntetjük a piros debug szalagot
      theme: ThemeData(
        // A Material 3 és a színpaletta beállítása a letisztult UI-hoz
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0), // A lila/kék gomb és fókusz szín a képről
          surface: Colors.white, // Fehér, letisztult hátterek
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        
        // Ha később egyedi betűtípust (pl. Google Fonts) használsz, 
        // itt érdemes globálisan megadni:
        // fontFamily: 'Inter', 
      ),
      // A kezdőképernyőnk a naptár lesz
      home: const CalendarScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importáljuk a külön fájlba kiszervezett főképernyőt.
// Ügyelj rá, hogy a mappa struktúrádnak megfelelő legyen az útvonal!
import 'screens/calendar_screen.dart'; 

void main() {
  // A ProviderScope a Riverpod lelke. Ez fogja össze az összes 
  // állapotot (Provider-t) az alkalmazásodban. E nélkül nem fog futni.
  runApp(const ProviderScope(child: ApartmentSaaSApp()));
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
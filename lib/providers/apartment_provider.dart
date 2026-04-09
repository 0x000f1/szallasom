import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apartment.dart';
import '../../main.dart'; // A sharedPrefsProvider miatt

class ApartmentState {
  final List<Apartment> apartments;
  final Apartment? selectedApartment;

  ApartmentState({required this.apartments, this.selectedApartment});

  ApartmentState copyWith({List<Apartment>? apartments, Apartment? selectedApartment}) {
    return ApartmentState(
      apartments: apartments ?? this.apartments,
      selectedApartment: selectedApartment ?? this.selectedApartment,
    );
  }
}

class ApartmentNotifier extends Notifier<ApartmentState> {
  static const _storageKey = 'saved_apartments';
  late SharedPreferences _prefs;

  @override
  ApartmentState build() {
    _prefs = ref.watch(sharedPrefsProvider);
    return _loadFromPrefs();
  }

  // --- Betöltés ---
  ApartmentState _loadFromPrefs() {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final apartments = jsonList.map((json) => Apartment.fromJson(json)).toList();
      
      return ApartmentState(
        apartments: apartments, 
        selectedApartment: apartments.isNotEmpty ? apartments.first : null
      );
    }
    return ApartmentState(apartments: []);
  }

  // --- Mentés ---
  Future<void> _saveToPrefs(List<Apartment> apartments) async {
    final jsonList = apartments.map((a) => a.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  void selectApartment(Apartment apartment) {
    state = state.copyWith(selectedApartment: apartment);
  }

  void addApartment(String name) {
    if (name.trim().isEmpty) return;
    final newApt = Apartment(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    
    final newList = [...state.apartments, newApt];
    _saveToPrefs(newList); // MENTÉS
    
    state = state.copyWith(apartments: newList, selectedApartment: newApt);
  }

  void removeApartment(String id) {
    final newList = state.apartments.where((a) => a.id != id).toList();
    _saveToPrefs(newList); // MENTÉS
    
    Apartment? newSelected = state.selectedApartment;
    if (state.selectedApartment?.id == id) {
      newSelected = newList.isNotEmpty ? newList.first : null;
    }
    state = ApartmentState(apartments: newList, selectedApartment: newSelected);
  }

  void updateApartmentUrls(String id, {String? bookingUrl, String? airbnbUrl}) {
    final aptIndex = state.apartments.indexWhere((a) => a.id == id);
    if (aptIndex == -1) return;

    final apt = state.apartments[aptIndex];
    
    // Létrehozunk egy frissített apartman objektumot a régi névvel, de az új URL-ekkel
    final updatedApt = Apartment(
      id: apt.id,
      name: apt.name,
      bookingIcalUrl: bookingUrl,
      airbnbIcalUrl: airbnbUrl,
    );

    // Kicseréljük a listában
    final newList = [...state.apartments];
    newList[aptIndex] = updatedApt;
    
    _saveToPrefs(newList); // MENTÉS LOKÁLISAN

    // Ha épp a kiválasztott apartmant szerkesztettük, frissítjük a nézetet is
    Apartment? newSelected = state.selectedApartment;
    if (state.selectedApartment?.id == id) {
      newSelected = updatedApt;
    }

    state = ApartmentState(apartments: newList, selectedApartment: newSelected);
  }
}

final apartmentProvider = NotifierProvider<ApartmentNotifier, ApartmentState>(() => ApartmentNotifier());
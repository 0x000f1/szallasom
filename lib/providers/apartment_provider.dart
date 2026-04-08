import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/apartment.dart';

class ApartmentState {
  final List<Apartment> apartments;
  final Apartment? selectedApartment;

  ApartmentState({required this.apartments, this.selectedApartment});

  ApartmentState copyWith({List<Apartment>? apartments, Apartment? selectedApartment}) {
    return ApartmentState(
      apartments: apartments ?? this.apartments,
      selectedApartment: selectedApartment ?? this.selectedApartment, // Ha null-t adunk, megtartja az eredetit
    );
  }
}

class ApartmentNotifier extends Notifier<ApartmentState> {
  @override
  ApartmentState build() {
    // Kezdeti Mock adatok
    final initialList = [
      Apartment(id: '1', name: 'Apartman 1'),
      Apartment(id: '2', name: 'Balatoni Nyaraló'),
    ];
    return ApartmentState(apartments: initialList, selectedApartment: initialList.first);
  }

  void selectApartment(Apartment apartment) {
    state = state.copyWith(selectedApartment: apartment);
    // TODO: Itt később be lehet hívni a bookingProvider frissítését az új apartman ID-ja alapján!
  }

  void addApartment(String name) {
    if (name.trim().isEmpty) return;
    final newApt = Apartment(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    state = state.copyWith(
      apartments: [...state.apartments, newApt],
      selectedApartment: newApt, // Rögtön ki is választjuk az újat
    );
  }

  void removeApartment(String id) {
    final newList = state.apartments.where((a) => a.id != id).toList();
    
    // Ha azt az apartmant töröltük, ami épp ki volt választva, ugorjunk egy másikra
    Apartment? newSelected = state.selectedApartment;
    if (state.selectedApartment?.id == id) {
      newSelected = newList.isNotEmpty ? newList.first : null;
    }
    
    // Itt direkt egy teljesen új objektumot adunk vissza, hogy a UI biztosan frissüljön,
    // még akkor is, ha a newSelected véletlenül null lett.
    state = ApartmentState(apartments: newList, selectedApartment: newSelected);
  }
}

final apartmentProvider = NotifierProvider<ApartmentNotifier, ApartmentState>(() {
  return ApartmentNotifier();
});
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_settings.dart';
import '../../main.dart'; // A sharedPrefsProvider miatt

class BusinessNotifier extends Notifier<BusinessSettings> {
  static const _key = 'business_data';

  @override
  BusinessSettings build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final raw = prefs.getString(_key);
    if (raw != null) return BusinessSettings.fromJson(jsonDecode(raw));
    return BusinessSettings();
  }

  Future<void> saveSettings(BusinessSettings settings) async {
    state = settings;
    await ref.read(sharedPrefsProvider).setString(_key, jsonEncode(settings.toJson()));
  }

  void updateProvider(String provider) {
    state = BusinessSettings(
      companyName: state.companyName,
      address: state.address,
      taxNumber: state.taxNumber,
      ntakId: state.ntakId,
      billingProvider: provider,
      billingEmail: state.billingEmail,
    );
  }
}

final businessProvider = NotifierProvider<BusinessNotifier, BusinessSettings>(() => BusinessNotifier());
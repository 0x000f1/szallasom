import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

class IntegrationNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  Future<void> saveApiKey(String provider, String key) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'api_key_$provider', value: key);
    state = {...state, provider: key};
  }

  Future<String?> getApiKey(String provider) async {
    return await ref.read(secureStorageProvider).read(key: 'api_key_$provider');
  }
}

final integrationProvider = NotifierProvider<IntegrationNotifier, Map<String, String>>(
  () => IntegrationNotifier(),
);
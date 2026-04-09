import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_provider.dart';
import '../providers/integration_provider.dart';
import '../models/business_settings.dart';

class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  late TextEditingController _nameCtrl, _addrCtrl, _taxCtrl, _ntakCtrl, _apiCtrl;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(businessProvider);
    _nameCtrl = TextEditingController(text: settings.companyName);
    _addrCtrl = TextEditingController(text: settings.address);
    _taxCtrl = TextEditingController(text: settings.taxNumber);
    _ntakCtrl = TextEditingController(text: settings.ntakId);
    _apiCtrl = TextEditingController();
    
    // API kulcs betöltése secure storage-ból
    _loadApiKey(settings.billingProvider);
  }

  Future<void> _loadApiKey(String provider) async {
    final key = await ref.read(integrationProvider.notifier).getApiKey(provider);
    if (key != null) setState(() => _apiCtrl.text = key);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(businessProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Adózás és Integrációk', style: TextStyle(fontWeight: FontWeight.bold)),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Számlázó kiválasztása', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Billingo', label: Text('Billingo')),
              ButtonSegment(value: 'Számlázz.hu', label: Text('Számlázz.hu')),
            ],
            selected: {settings.billingProvider},
            onSelectionChanged: (val) {
              ref.read(businessProvider.notifier).updateProvider(val.first);
              _loadApiKey(val.first);
            },
          ),
          const SizedBox(height: 32),
          _buildField('Vállalkozás neve', _nameCtrl, Icons.business),
          _buildField('Székhely cím', _addrCtrl, Icons.location_on),
          _buildField('Adószám', _taxCtrl, Icons.tag),
          _buildField('NTAK Azonosító', _ntakCtrl, Icons.vpn_key),
          const Divider(height: 48),
          const Text('API Integráció', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _apiCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '${settings.billingProvider} API Kulcs',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3F51B5)),
              filled: true, fillColor: const Color(0xFFF8F9FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final newSettings = BusinessSettings(
                  companyName: _nameCtrl.text,
                  address: _addrCtrl.text,
                  taxNumber: _taxCtrl.text,
                  ntakId: _ntakCtrl.text,
                  billingProvider: settings.billingProvider,
                );
                await ref.read(businessProvider.notifier).saveSettings(newSettings);
                await ref.read(integrationProvider.notifier).saveApiKey(settings.billingProvider, _apiCtrl.text);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Beállítások sikeresen mentve!'), backgroundColor: Colors.green)
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('MINDEN MENTÉSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
          filled: true, fillColor: const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
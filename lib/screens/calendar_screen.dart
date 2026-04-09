import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../providers/booking_provider.dart';
import '../providers/apartment_provider.dart';
import '../providers/business_provider.dart'; 
import '../models/booking.dart';
import '../models/apartment.dart';
import '../services/pdf_service.dart'; 
import 'tax_settings_screen.dart'; 

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

  // --- SAAS STÍLUSÚ iCal BEÁLLÍTÁSOK ---
  void _showIcalSettings(BuildContext context, Apartment apartment) {
    final bookingCtrl = TextEditingController(text: apartment.bookingIcalUrl);
    final airbnbCtrl = TextEditingController(text: apartment.airbnbIcalUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text('${apartment.name} Linkjei', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Másold ide a platformok export linkjeit.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: bookingCtrl,
              decoration: InputDecoration(
                labelText: 'Booking.com URL',
                filled: true, fillColor: const Color(0xFFF8F9FD),
                prefixIcon: const Icon(Icons.domain, color: Color(0xFF1565C0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: airbnbCtrl,
              decoration: InputDecoration(
                labelText: 'Airbnb URL',
                filled: true, fillColor: const Color(0xFFF8F9FD),
                prefixIcon: const Icon(Icons.home, color: Color(0xFFC62828)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(apartmentProvider.notifier).updateApartmentUrls(
                    apartment.id, bookingUrl: bookingCtrl.text, airbnbUrl: airbnbCtrl.text,
                  );
                  ref.read(bookingProvider.notifier).syncCalendars();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Mentés és Szinkronizálás', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- EREDETI Beállítások Panel ---
  void _showSettingsPanel(BuildContext context) {
    final selectedApt = ref.read(apartmentProvider).selectedApartment;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
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
                onTap: () { 
                  Navigator.pop(context); 
                  if (selectedApt != null) {
                    _showIcalSettings(context, selectedApt);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Válassz apartmant!')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_rounded, color: Color(0xFF3F51B5)),
                title: const Text('Adózás és Integrációk'), 
                subtitle: const Text('Számlázó és NTAK beállítások'), 
                onTap: () { 
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TaxSettingsScreen())); 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- EREDETI Apartman választó Bottom Sheet ---
  void _showApartmentSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
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
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text('Nincs apartman.', style: TextStyle(color: Colors.grey)))
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
                            leading: Icon(Icons.home_work_rounded, color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[400]),
                            title: Text(apt.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF3F51B5) : Colors.black87)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF3F51B5), size: 20),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => ref.read(apartmentProvider.notifier).removeApartment(apt.id),
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
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddApartmentDialog(context);
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF3F51B5)),
                      label: const Text('Új apartman hozzáadása', style: TextStyle(color: Color(0xFF3F51B5))),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF3F51B5)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  void _showAddApartmentDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Új apartman', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(controller: textController, decoration: const InputDecoration(hintText: 'Pl.: Belvárosi Stúdió', border: OutlineInputBorder()), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mégse', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              ref.read(apartmentProvider.notifier).addApartment(textController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)),
            child: const Text('Hozzáadás', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBillingForm(BuildContext context, Booking booking) {
    final nameCtrl = TextEditingController(text: booking.guestName);
    final emailCtrl = TextEditingController();
    final zipCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    
    bool sendToNtak = true; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setPanelState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 16
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Számlázás és NTAK', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
                        child: const Text('API Kész', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Állíts ki hivatalos számlát a vendégnek.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),

                  TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Vevő (Vendég) neve', filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'E-mail cím', filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(flex: 1, child: TextField(controller: zipCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Irsz.', filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: TextField(controller: cityCtrl, decoration: InputDecoration(labelText: 'Város', filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: addressCtrl, decoration: InputDecoration(labelText: 'Utca, házszám', filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),

                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Végösszeg (HUF)', 
                      filled: true, fillColor: const Color(0xFFE8F5E9), 
                      prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF2E7D32)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Automatikus NTAK adatszolgáltatás', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('A számlával együtt beküldjük az adatokat.', style: TextStyle(fontSize: 12)),
                      activeColor: const Color(0xFF3F51B5),
                      value: sendToNtak,
                      onChanged: (bool value) {
                        setPanelState(() { sendToNtak = value; });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final invoiceData = {
                          'name': nameCtrl.text.isEmpty ? 'Ismeretlen Vevő' : nameCtrl.text,
                          'address': '${zipCtrl.text} ${cityCtrl.text}, ${addressCtrl.text}'.trim(),
                          'price': priceCtrl.text.isEmpty ? '0' : priceCtrl.text,
                          'ntak': sendToNtak,
                          'checkIn': DateFormat('yyyy.MM.dd').format(booking.checkIn),
                          'checkOut': DateFormat('yyyy.MM.dd').format(booking.checkOut),
                        };
                        Navigator.pop(context);
                        _showInvoicePreview(context, invoiceData);
                      },
                      icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white),
                      label: const Text('Tervezet Megtekintése', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  // --- 2. HAGYOMÁNYOS SZÁMLA ELŐNÉZET ---
  void _showInvoicePreview(BuildContext context, Map<String, dynamic> data) {
    // Betöltjük az aktuális beállításokat
    final biz = ref.read(businessProvider);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ELŐNÉZET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(4)),
                    child: const Text('NEM HITELES', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const Divider(color: Colors.black, thickness: 2),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kibocsátó:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        // --- JAVÍTVA: Dinamikus kibocsátó adatok beállítása ---
                        Text(biz.companyName.isEmpty ? 'Nincs kitöltve' : biz.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(biz.address.isEmpty ? 'Nincs kitöltve' : biz.address, style: const TextStyle(fontSize: 12)),
                        Text(biz.taxNumber.isEmpty ? 'Nincs kitöltve' : 'Adószám: ${biz.taxNumber}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vevő:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(data['address'].toString().isEmpty ? 'Cím nincs megadva' : data['address'], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.black54),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('Szálláshely-szolgáltatás\n(${data['checkIn']} - ${data['checkOut']})', style: const TextStyle(fontSize: 13))),
                  Text('${data['price']} Ft', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.black54),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FIZETENDŐ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${data['price']} Ft', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              
              // MŰVELETI GOMBOK
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Számla jóváhagyva és elküldve!'), backgroundColor: Colors.green));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Jóváhagyás és Beküldés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await PdfService.generateAndShareInvoice(
                          invoiceData: data,
                          sellerName: biz.companyName.isEmpty ? 'Nincs kitöltve' : biz.companyName,
                          sellerAddress: biz.address.isEmpty ? 'Nincs kitöltve' : biz.address,
                          sellerTaxNum: biz.taxNumber.isEmpty ? 'Nincs kitöltve' : biz.taxNumber,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('Mentés PDF-ként'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black87, side: const BorderSide(color: Colors.black26), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Mégse', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  // --- EREDETI Esemény részletei (Számla/Törlés) ---
  void _showEventDetails(BuildContext context, Booking booking) {
    final DateFormat detailedTimeFormat = DateFormat('yyyy. MM. dd. HH:mm');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              Text(booking.guestName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(color: booking.cardColor, borderRadius: BorderRadius.circular(12.0)),
                child: Text(booking.source.name.toUpperCase(), style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: booking.textColor)),
              ),
              const SizedBox(height: 24),
              const Text('Időtartam', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text('${detailedTimeFormat.format(booking.checkIn)}  -  ${detailedTimeFormat.format(booking.checkOut)}', style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (booking.source != BookingSource.manual) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('A külső platformos (Booking/Airbnb) foglalásokat az adott platformon kell törölni!'))
                          );
                          return;
                        }

                        // Megerősítő ablak manuális foglalásnál
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Foglalás törlése'),
                            content: const Text('Biztosan törölni szeretnéd ezt a foglalást? Ez a művelet nem visszavonható.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context), // Mégse
                                child: const Text('Mégse', style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(bookingProvider.notifier).deleteManualBooking(booking.id);
                                  Navigator.pop(context); // Bezárja a dialogot
                                  Navigator.pop(context); // Bezárja a részletek panelt is
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foglalás törölve.')));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Törlés', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Törlés', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { 
                        Navigator.pop(context); // Először bezárjuk az esemény részleteit
                        _showBillingForm(context, booking); // Majd megnyitjuk a számlázót!
                      },
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text('Számla', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  // --- ÚJ: Manuális Foglalás Hozzáadása Panel ---
  void _showAddManualBooking(BuildContext context) {
    final nameCtrl = TextEditingController();
    DateTime rangeStart = _selectedDay ?? DateTime.now();
    DateTime rangeEnd = rangeStart.add(const Duration(days: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder( 
        builder: (context, setPanelState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 16
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              const Text('Új Manuális Foglalás', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Vendég neve',
                  filled: true, fillColor: const Color(0xFFF8F9FD),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range, color: Color(0xFF3F51B5)),
                title: Text("${DateFormat('yyyy. MM. dd.').format(rangeStart)}  -  ${DateFormat('MM. dd.').format(rangeEnd)}"),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: DateTimeRange(start: rangeStart, end: rangeEnd),
                    );
                    if (picked != null) {
                      setPanelState(() {
                        rangeStart = picked.start;
                        rangeEnd = picked.end;
                      });
                    }
                  },
                  child: const Text('Módosítás'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      ref.read(bookingProvider.notifier).addManualBooking(nameCtrl.text, rangeStart, rangeEnd);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Rögzítés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
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
    final aptState = ref.watch(apartmentProvider);
    final selectedDayBookings = ref.read(bookingProvider.notifier).getBookingsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // --- EREDETI Szép AppBar ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        // --- JAVÍTVA: Profilkép igazítása pontosan a Calendar mellé ---
        leadingWidth: 56, 
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => _showSettingsPanel(context),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(Icons.person, color: Color(0xFF3F51B5)),
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => _showApartmentSelector(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                aptState.selectedApartment?.name ?? 'Nincs apartman', 
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
            onPressed: () => ref.read(bookingProvider.notifier).syncCalendars(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: bookingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hiba: $err')),
        data: (bookings) => Column(
          children: [
            _buildCalendar(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft, 
                child: Text("Kiválasztott nap eseményei", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ),
            ),
            Expanded(child: _buildEventList(selectedDayBookings)),
          ],
        ),
      ),
      // --- EREDETI + GOMB ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5), 
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddManualBooking(context),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: TableCalendar<Booking>(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
        },
        eventLoader: (day) => ref.read(bookingProvider.notifier).getBookingsForDay(day),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox();
            final sortedEvents = List<Booking>.from(events)..sort((a, b) => a.checkIn.compareTo(b.checkIn));
            return Positioned(
              bottom: 2, left: 0, right: 0,
              child: Row(
                children: sortedEvents.map((booking) {
                  final isStart = isSameDay(day, booking.checkIn);
                  final isEnd = isSameDay(day, booking.checkOut);
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(left: isStart ? 6 : 0, right: isEnd ? 6 : 0),
                      decoration: BoxDecoration(
                        color: booking.textColor.withOpacity(0.85),
                        borderRadius: BorderRadius.horizontal(left: isStart ? const Radius.circular(4) : Radius.zero, right: isEnd ? const Radius.circular(4) : Radius.zero),
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
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      ),
    );
  }

  Widget _buildEventList(List<Booking> events) {
    if (events.isEmpty) {
      return Center(child: Text('Nincs érkező vendég ezen a napon.', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final booking = events[index];
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.guestName, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: booking.textColor)),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: booking.textColor.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text('${timeFormat.format(booking.checkIn)} - ${timeFormat.format(booking.checkOut)}', style: TextStyle(fontSize: 13.0, color: booking.textColor.withOpacity(0.8))),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12.0)),
                      child: Text(booking.source.name.toUpperCase(), style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: booking.textColor)),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
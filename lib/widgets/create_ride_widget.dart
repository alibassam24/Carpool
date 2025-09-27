import 'package:carpool_connect/models/ride_model.dart';
import 'package:carpool_connect/services/ride_service.dart';
import 'package:carpool_connect/controllers/ride_controller.dart';
import 'package:carpool_connect/screens/carpooler/map_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateRideWidget extends StatefulWidget {
  final String currentUserId;
  
  final void Function(Ride createdRide)? onCreated;

  const CreateRideWidget({
    super.key,
    required this.currentUserId,
    this.onCreated,
  });

  @override
  State<CreateRideWidget> createState() => _CreateRideWidgetState();
}

class _CreateRideWidgetState extends State<CreateRideWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesCtl = TextEditingController();
  final _priceCtl = TextEditingController();
  final RideController rideController = Get.find<RideController>();

  DateTime? _selectedDateTime;
  int _seats = 1;
  String _genderPref = 'any';
  bool _isSubmitting = false;

  // store text + coordinates
  String? _originText;
  double? _originLat;
  double? _originLng;

  String? _destText;
  double? _destLat;
  double? _destLng;

  late final AnimationController _animController;
  late final Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _notesCtl.dispose();
    _priceCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickLocation(bool isOrigin) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: isOrigin ? "Pick Origin" : "Pick Destination",
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      if (isOrigin) {
        _originText = result['name'] ?? "${result['lat']}, ${result['lng']}";
        _originLat = result['lat'];
        _originLng = result['lng'];
      } else {
        _destText = result['name'] ?? "${result['lat']}, ${result['lng']}";
        _destLat = result['lat'];
        _destLng = result['lng'];
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedDateTime == null) {
      Get.snackbar("Validation", "Please select a date & time");
      return;
    }
    if (_originText == null || _destText == null) {
      Get.snackbar("Validation", "Please select both origin and destination");
      return;
    }
    if (_seats < 1 || _seats > 10) {
      Get.snackbar("Validation", "Seats must be between 1 and 10");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = double.tryParse(_priceCtl.text.trim());
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final ride = Ride(
        //id: 0, // Supabase will assign
        carpoolerId: userId!,
        origin: _originText!,
        destination: _destText!,
        originLat: _originLat,

        originLng: _originLng,
        destinationLat: _destLat,
        destinationLng: _destLng,
        when: _selectedDateTime!,
        seats: _seats,
        price: price,
        genderPreference: _genderPref,
        notes: _notesCtl.text.trim().isEmpty ? null : _notesCtl.text.trim(),
      );

      final result = await RideService().createRide(ride);

      // ✅ handle Result<T>
      result.when(
        ok: (rideObj) {
          rideController.addRide(rideObj);
          widget.onCreated?.call(rideObj);
          Navigator.of(context).pop();
          Get.snackbar("Success", "Ride created successfully ✅",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF255A45),
              colorText: Colors.white);
        },
        err: (f) {
          Get.snackbar("Error", f.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade50,
              colorText: Colors.black87);
        },
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF255A45)),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandPrimary = Color(0xFF255A45);

    return SlideTransition(
      position: _offsetAnim,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -2))],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Create Carpool Ride 🚗",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brandPrimary)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.location_on, color: brandPrimary),
                            title: Text(_originText ?? "Select Origin"),
                            onTap: () => _pickLocation(true),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.flag, color: brandPrimary),
                            title: Text(_destText ?? "Select Destination"),
                            onTap: () => _pickLocation(false),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.access_time, color: brandPrimary),
                            title: Text(_selectedDateTime == null
                                ? "Choose Date & Time"
                                : _selectedDateTime!.toLocal().toString()),
                            onTap: _pickDateTime,
                          ),
                          const SizedBox(height: 12),
                          // seats
                          Row(
                            children: [
                              Expanded(
                                child: InputDecorator(
                                  decoration: _inputDecoration("Seats", Icons.event_seat),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: brandPrimary),
                                        onPressed: () {
                                          if (_seats > 1) setState(() => _seats--);
                                        },
                                      ),
                                      Text("$_seats"),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: brandPrimary),
                                        onPressed: () {
                                          if (_seats < 10) setState(() => _seats++);
                                        },
                                      ),
                                      const Spacer(),
                                      const Text("Max 10"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _priceCtl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("Suggested Price (optional)", Icons.attach_money),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _genderPref,
                            decoration: _inputDecoration("Gender Preference", Icons.person_outline),
                            items: const [
                              DropdownMenuItem(value: "any", child: Text("No preference")),
                              DropdownMenuItem(value: "male", child: Text("Male only")),
                              DropdownMenuItem(value: "female", child: Text("Female only")),
                            ],
                            onChanged: (v) => setState(() => _genderPref = v ?? "No preference"),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesCtl,
                            maxLines: 3,
                            decoration: _inputDecoration("Notes (optional)", Icons.note_outlined)
                                .copyWith(hintText: "Any details for passengers"),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text("Post Ride", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

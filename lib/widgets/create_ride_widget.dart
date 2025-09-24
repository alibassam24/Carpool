import 'package:carpool_connect/models/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ride_service.dart';
import '../controllers/ride_controller.dart';

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
  final _originCtl = TextEditingController();
  final _destinationCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  final _priceCtl = TextEditingController();
  final RideController rideController = Get.find<RideController>();

  DateTime? _selectedDateTime;
  int _seats = 1;
  String _genderPref = 'No preference';
  bool _isSubmitting = false;

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
    _originCtl.dispose();
    _destinationCtl.dispose();
    _notesCtl.dispose();
    _priceCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    try {
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
    } catch (e) {
      debugPrint("❌ Date/Time picker failed: $e");
      Get.snackbar("Error", "Failed to pick date & time");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      Get.snackbar("Validation", "Please select a date & time");
      return;
    }

    if (_seats < 1 || _seats > 10) {
      Get.snackbar("Validation", "Seats must be between 1 and 10");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = double.tryParse(_priceCtl.text.trim());
      if (_priceCtl.text.trim().isNotEmpty && price == null) {
        throw "Invalid price entered";
      }

      final ride = RideService.buildRide(
        createdBy: widget.currentUserId,
        origin: _originCtl.text.trim(),
        destination: _destinationCtl.text.trim(),
        when: _selectedDateTime!,
        seats: _seats,
        price: price,
        genderPreference: _genderPref,
        notes: _notesCtl.text.trim(),
      );

      final created = await RideService.createRide(ride);

      // instant UI update
      rideController.addRide(created);
      widget.onCreated?.call(created);

      if (!mounted) return;
      Get.snackbar(
        "Success",
        "Ride created successfully ✅",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF255A45),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );

      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint("❌ Create ride failed: $e\n$st");
      if (!mounted) return;
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.black87,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
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
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Create Carpool Ride 🚗",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: brandPrimary,
                      ),
                    ),
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
                          TextFormField(
                            controller: _originCtl,
                            decoration:
                                _inputDecoration("Origin", Icons.location_on),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? "Origin required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _destinationCtl,
                            decoration:
                                _inputDecoration("Destination", Icons.flag),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? "Destination required" : null,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDateTime,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: _inputDecoration(
                                  "Date & Time",
                                  Icons.access_time,
                                ).copyWith(
                                  hintText: _selectedDateTime == null
                                      ? "Choose date & time"
                                      : "${_selectedDateTime!.toLocal()}",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InputDecorator(
                                  decoration:
                                      _inputDecoration("Seats", Icons.event_seat),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (_seats > 1) {
                                            setState(() => _seats--);
                                          }
                                        },
                                        icon: const Icon(Icons.remove_circle_outline,
                                            color: brandPrimary),
                                      ),
                                      Text("$_seats",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      IconButton(
                                        onPressed: () {
                                          if (_seats < 10) {
                                            setState(() => _seats++);
                                          }
                                        },
                                        icon: const Icon(Icons.add_circle_outline,
                                            color: brandPrimary),
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
                            decoration: _inputDecoration(
                              "Suggested Price (optional)",
                              Icons.attach_money,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _genderPref,
                            decoration: _inputDecoration(
                                "Gender preference", Icons.person_outline),
                            items: const [
                              DropdownMenuItem(
                                  value: "No preference",
                                  child: Text("No preference")),
                              DropdownMenuItem(
                                  value: "Male only", child: Text("Male only")),
                              DropdownMenuItem(
                                  value: "Female only",
                                  child: Text("Female only")),
                            ],
                            onChanged: (v) =>
                                setState(() => _genderPref = v ?? "No preference"),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesCtl,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              "Notes (optional)",
                              Icons.note_outlined,
                            ).copyWith(
                              hintText: "Any details for passengers",
                            ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                    shadowColor: brandPrimary.withOpacity(0.4),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Post Ride",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

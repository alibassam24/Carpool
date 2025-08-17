// lib/widgets/create_ride_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ride_service.dart';
import '../services/user_service.dart';
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

class _CreateRideWidgetState extends State<CreateRideWidget> with SingleTickerProviderStateMixin {
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

  // small entrance animation
  late final AnimationController _animController;
  late final Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!mounted) return;
    setState(() => _selectedDateTime = combined);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      Get.snackbar('Validation', 'Please select date & time for the ride');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = double.tryParse(_priceCtl.text.trim());
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

// Add ride to controller list so UI updates instantly
      rideController.addRide(created);


      // keep Get.snackbar style consistent with your app
      Get.snackbar('Success', 'Ride posted',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF255A45), colorText: Colors.white);

      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('Create ride failed: $e\n$st');
      if (!mounted) return;
      Get.snackbar('Error', 'Failed to create ride');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandPrimary = const Color(0xFF255A45);
    return SlideTransition(
      position: _offsetAnim,
      child: FractionallySizedBox(
        heightFactor: 0.86,
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create Carpool', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _originCtl,
                          decoration: const InputDecoration(labelText: 'Origin', prefixIcon: Icon(Icons.location_on_outlined)),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Origin required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _destinationCtl,
                          decoration: const InputDecoration(labelText: 'Destination', prefixIcon: Icon(Icons.flag_outlined)),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Destination required' : null,
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickDateTime,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Date & Time',
                                prefixIcon: const Icon(Icons.access_time),
                                hintText: _selectedDateTime == null ? 'Choose date & time' : _selectedDateTime!.toLocal().toString(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Seats'),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_seats > 1) if (mounted) setState(() => _seats--);
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    Text('$_seats', style: const TextStyle(fontSize: 16)),
                                    IconButton(
                                      onPressed: () {
                                        if (_seats < 10) if (mounted) setState(() => _seats++);
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                    const Spacer(),
                                    const Text('Max 10'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _priceCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Suggested Price (optional)', prefixIcon: Icon(Icons.attach_money)),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _genderPref,
                          decoration: const InputDecoration(labelText: 'Gender preference'),
                          items: const [
                            DropdownMenuItem(value: 'No preference', child: Text('No preference')),
                            DropdownMenuItem(value: 'Male only', child: Text('Male only')),
                            DropdownMenuItem(value: 'Female only', child: Text('Female only')),
                          ],
                          onChanged: (v) => setState(() => _genderPref = v ?? 'No preference'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _notesCtl,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'Leave additional info'),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Post Ride', style: TextStyle(fontSize: 16)),
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
}

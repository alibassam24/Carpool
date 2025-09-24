import 'dart:math';
import 'package:carpool_connect/screens/rider/rider_home_screen.dart';
import 'package:carpool_connect/screens/carpooler/carpooler_home_screen.dart';
import 'package:carpool_connect/screens/carpooler/carpooler_signup.dart';
import 'package:carpool_connect/screens/carpooler/verification_pending_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final box = GetStorage();

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen>
    with TickerProviderStateMixin {
  String? _selectedRole;
  bool _isLoading = false;

  late final AnimationController _carpoolerController;
  late final AnimationController _riderController;
  late final AnimationController _fadeController;

  late final Animation<double> _carpoolerRotation;
  late final Animation<double> _riderRotation;
  late final Animation<double> _fadeIn;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _carpoolerController =
        AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _riderController =
        AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeController =
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeIn =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _carpoolerRotation =
        Tween<double>(begin: 0, end: 2 * pi).animate(CurvedAnimation(parent: _carpoolerController, curve: Curves.easeInOut));
    _riderRotation =
        Tween<double>(begin: 0, end: 2 * pi).animate(CurvedAnimation(parent: _riderController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _carpoolerController.dispose();
    _riderController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);

    try {
      box.write('userRole', _selectedRole);

      if (_selectedRole == "rider") {
        Get.offAll(() => const RiderHomeScreen());
        return;
      }

      // Carpooler logic
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar("Error", "No logged in user found");
        return;
      }

      // Check if carpooler profile exists
      final carpoolerProfile =
          await supabase.from('carpooler_profiles').select().eq('id', userId).maybeSingle();

      if (carpoolerProfile == null) {
        // Not a carpooler yet → extended signup
        Get.offAll(() => const ExtendedCarpoolerSignupScreen());
        return;
      }

      // Profile exists → check documents
      final driverDocs =
          await supabase.from('driver_documents').select().eq('user_id', userId).maybeSingle();

      if (driverDocs == null || driverDocs['status'] == 'pending') {
        Get.offAll(() => const VerificationPendingScreen());
        return;
      }

      if (driverDocs['status'] == 'rejected') {
        Get.snackbar("Rejected", "Your documents were rejected. Please re-upload.");
        Get.offAll(() => const ExtendedCarpoolerSignupScreen());
        return;
      }

      if (driverDocs['status'] == 'approved') {
        Get.offAll(() => const CarpoolerHomeScreen());
        return;
      }

      // Default fallback
      Get.snackbar("Error", "Unexpected status. Please contact support.");
    } catch (e, st) {
      debugPrint("❌ Role selection error: $e\n$st");
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
    required AnimationController controller,
    required Animation<double> rotation,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        if (_selectedRole != role) {
          setState(() => _selectedRole = role);
          controller..reset()..forward();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([controller, _fadeController]),
        builder: (context, child) {
          final rotationAngle = isSelected ? rotation.value : 0.0;
          return Opacity(
            opacity: _fadeIn.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotationAngle),
              child: child,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF255A45).withOpacity(0.1)
                : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF255A45) : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF255A45).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Hero(
                tag: role,
                child: Icon(icon, size: 48, color: const Color(0xFF255A45)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF255A45),
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Carpool Connect 👋",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF255A45)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "How would you like to use the app?",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        title: "Carpooler",
                        subtitle: "Offer Rides & earn",
                        icon: Icons.drive_eta_rounded,
                        role: "carpooler",
                        controller: _carpoolerController,
                        rotation: _carpoolerRotation,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRoleCard(
                        title: "Passenger",
                        subtitle: "Find rides nearby",
                        icon: Icons.person_outline,
                        role: "rider",
                        controller: _riderController,
                        rotation: _riderRotation,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF255A45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Continue",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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

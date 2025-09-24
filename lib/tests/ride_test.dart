import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/ride_controller.dart';
import '../screens/rider/rider_home_screen.dart';
import '../screens/auth/choose_role_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "YOUR_SUPABASE_URL",
    anonKey: "YOUR_SUPABASE_ANON_KEY",
  );

  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ride Test',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (res.session != null) {
        Get.offAll(() => const ChooseRoleScreen());
      } else {
        setState(() => _error = "Invalid login credentials");
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 20),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF255A45)),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

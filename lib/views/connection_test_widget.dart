import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  String status = "⏳ Testing connection...";

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final supabase = Supabase.instance.client;
    try {
      // Try fetching 1 user row (adjust table if needed)
      final response = await supabase.from('users').select().limit(1);
      setState(() {
        status = "✅ Connected to Supabase! Response: $response";
      });
    } catch (e) {
      setState(() {
        status = "❌ Connection failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supabase Connection Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

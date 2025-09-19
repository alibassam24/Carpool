import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentController extends GetxController {
  final supabase = Supabase.instance.client;

  Future<int?> createPayment(int rideId, String payer, double amount) async {
    final res = await supabase.rpc('create_payment', params: {
      'ride_id': rideId,
      'payer': payer,
      'amount': amount,
    });
    return res;
  }
}

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class ChatController extends GetxController {
  final supabase = Supabase.instance.client;
  var messages = [].obs;

  Future<void> sendMessage(int rideId, String sender, String receiver, String msg) async {
    await supabase.rpc('send_message', params: {
      'ride_id': rideId,
      'sender': sender,
      'receiver': receiver,
      'msg': msg,
    });
  }

  Future<void> fetchMessages(int rideId) async {
    final res = await supabase.rpc('get_messages', params: {
      'ride_id': rideId,
    });
    messages.value = res;
  }
}

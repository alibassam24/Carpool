class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  ChatService._internal();

  final List<Map<String, dynamic>> chats = [];

  void startChatWith(String name, {bool isDriver = true}) {
    try {
      final existing = chats.firstWhere((chat) => chat['name'] == name, orElse: () => {});
      if (existing.isNotEmpty) return;

      chats.add({
        'name': name,
        'lastMessage': 'You started a chat',
        'time': 'Now',
        'unread': 0,
        'userType': isDriver ? 'Driver' : 'Passenger',
        'status': 'online',
        'archived': false,
      });
    } catch (e) {
      print('Error starting chat: $e');
    }
  }

  List<Map<String, dynamic>> getAllChats() => chats;
}

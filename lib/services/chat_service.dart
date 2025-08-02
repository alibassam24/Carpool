// lib/services/chat_service.dart

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });
}

class ChatService {
  static final List<ChatMessage> _messages = [];

  static List<ChatMessage> getMessagesFor(String userId1, String userId2) {
    return _messages
        .where((m) =>
            (m.senderId == userId1 && m.receiverId == userId2) ||
            (m.senderId == userId2 && m.receiverId == userId1))
        .toList();
  }

  static void sendMessage(String fromId, String toId, String message) {
    _messages.add(ChatMessage(
      senderId: fromId,
      receiverId: toId,
      message: message,
      timestamp: DateTime.now(),
    ));
  }

  static List<String> getChatUsers(String currentUserId) {
    final Set<String> chatUserIds = {};
    for (var msg in _messages) {
      if (msg.senderId == currentUserId) chatUserIds.add(msg.receiverId);
      if (msg.receiverId == currentUserId) chatUserIds.add(msg.senderId);
    }
    return chatUserIds.toList();
  }
}

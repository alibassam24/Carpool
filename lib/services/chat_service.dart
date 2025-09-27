/* // lib/services/chat_service.dart

import 'package:carpool_connect/services/user_service.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isSystem; // 👈 NEW


  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isSystem = false, //
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

  static void sendMessage(String fromId, String toId, String message, {bool isSystem=false}) {
    _messages.add(ChatMessage(
      senderId: fromId,
      receiverId: toId,
      message: message,
      timestamp: DateTime.now(),
      isSystem: isSystem,
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

  /// Ensures a chat session exists between two users,
  /// by inserting a dummy message only if no messages exist yet.
  
static void startChatIfNeeded(String user1Id, String user2Id) {
  final existingMessages = getMessagesFor(user1Id, user2Id);

  if (existingMessages.isEmpty) {
    final user1 = UserService.dummyUsers.firstWhere(
      (u) => u.id == user1Id,
      orElse: () => DummyUser(
        id: user1Id,
        name: 'Unknown',
        role: 'User',
        email: '',
        password: '',
      ),
    );

    sendMessage(
  user1Id,
  user2Id,
  "${user1.name} initiated the chat",
  isSystem: true, // 👈 SYSTEM MESSAGE
);
  }
}


 /*  static void startChatIfNeeded(String user1Id, String user2Id) {
  final existingMessages = ChatService.getMessagesFor(user1Id, user2Id);

  if (existingMessages.isEmpty) {
    final user1Name = UserService().dummyUsers.firstWhere((u) => u.id == user1Id, orElse: () => DummyUser(
              id: user1Id,
              name: 'Unknown',
              role: 'User',
              email: '',
              password: '',
            ))
        .name;

    ChatService.sendMessage(
      user1Id,
      user2Id,
      "$user1Name initiated the chat",
    );
  }
}
 */

  /* static void startChatIfNeeded(String userId1, String userId2) {
    bool exists = _messages.any((m) =>
        (m.senderId == userId1 && m.receiverId == userId2) ||
        (m.senderId == userId2 && m.receiverId == userId1));

    if (!exists) {
      // Add a placeholder empty message to initiate the chat session
      _messages.add(ChatMessage(
        senderId: userId1,
        receiverId: userId2,
        message: '',
        timestamp: DateTime.now(),
      ));
    }
  } */
}
 */
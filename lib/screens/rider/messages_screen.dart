/* import 'package:carpool_connect/screens/rider/chat_screen.dart';
import 'package:carpool_connect/services/chat_service.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import 'messages_screen.dart';
//import '../../models/user.dart'; // assuming you have a User model

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<String> chatUserIds = [];
  Map<String, bool> archivedStatus = {}; // userId -> archived

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    setState(() {
      chatUserIds = ChatService.getChatUsers(UserService.currentUser.id);
    });
  }

  void _deleteChat(String userId) {
    setState(() {
      chatUserIds.remove(userId);
    });
  }

  void _archiveChat(String userId) {
    setState(() {
      archivedStatus[userId] = true;
    });
  }

  void _unarchiveChat(String userId) {
    setState(() {
      archivedStatus[userId] = false;
    });
  }

  void _markAsRead(String userId) {
    // Placeholder for real unread logic
  }

  @override
  Widget build(BuildContext context) {
    final activeChats = chatUserIds.where((id) => archivedStatus[id] != true).toList();
    final archivedChats = chatUserIds.where((id) => archivedStatus[id] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (archivedChats.isNotEmpty)
            ListTile(
              contentPadding: const EdgeInsets.only(bottom: 8),
              leading: const Icon(Icons.archive, color: Colors.grey),
              title: const Text("Archived Chats", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: archivedChats.map((id) => _buildChatCard(id)).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ...activeChats.map((id) => _buildChatCard(id)),
        ],
      ),
    );
  }

  Widget _buildChatCard(String userId) {
    final user = UserService.dummyUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () => DummyUser(
    id: userId,
    name: "Unknown",
    role: "User",
    email: "",
    password: "",
  ),
    );

    final messages = ChatService.getMessagesFor(UserService.currentUser.id, userId);
    final lastMessage = messages.isNotEmpty ? messages.last.message : "(No messages)";
    final lastTime = messages.isNotEmpty ? _formatTime(messages.last.timestamp) : "";

    return Card(
      color: const Color(0xFFEAF1ED),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                currentUserId: UserService.currentUser.id,
                otherUserId: user.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF255A45),
                    child: Text(
                      user.name[0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getOnlineStatus(user.id) ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(lastTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: const Color(0xFFE8F5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'delete':
                        _deleteChat(userId);
                        break;
                      case 'archive':
                        _archiveChat(userId);
                        break;
                      case 'unarchive':
                        _unarchiveChat(userId);
                        break;
                      case 'mark_read':
                        _markAsRead(userId);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (archivedStatus[userId] != true)
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Archive'),
                          ],
                        ),
                      ),
                    if (archivedStatus[userId] == true)
                      const PopupMenuItem(
                        value: 'unarchive',
                        child: Row(
                          children: [
                            Icon(Icons.unarchive_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Unarchive'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Mark as Read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else if (now.difference(time).inDays == 1) {
      return "Yesterday";
    } else {
      return "${time.day}/${time.month}";
    }
  }

  bool _getOnlineStatus(String userId) {
    return userId.hashCode % 2 == 0; // mock logic
  }
}
 */
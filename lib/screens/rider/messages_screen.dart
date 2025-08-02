import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> chats = [
    {
      'name': 'Ali Khan',
      'lastMessage': 'Let’s meet at 5 PM?',
      'time': '2:30 PM',
      'unread': 2,
      'userType': 'Driver',
      'status': 'online',
      'archived': false,
    },
    {
      'name': 'Sara Malik',
      'lastMessage': 'Ride confirmed!',
      'time': '1:12 PM',
      'unread': 0,
      'userType': 'Passenger',
      'status': 'offline',
      'archived': false,
    },
    {
      'name': 'Driver Javed',
      'lastMessage': 'I’m nearby!',
      'time': 'Yesterday',
      'unread': 3,
      'userType': 'Driver',
      'status': 'online',
      'archived': true,
    },
  ];

  void _deleteChat(int index) {
    setState(() {
      chats.removeAt(index);
    });
  }

  void _archiveChat(int index) {
    setState(() {
      chats[index]['archived'] = true;
    });
  }

  void _unarchiveChat(int index) {
    setState(() {
      chats[index]['archived'] = false;
    });
  }

  void _markAsRead(int index) {
    setState(() {
      chats[index]['unread'] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final archived = chats.where((chat) => chat['archived'] == true).toList();
    final active = chats.where((chat) => chat['archived'] == false).toList();

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
          if (archived.isNotEmpty)
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
                        children: archived
                            .asMap()
                            .entries
                            .map((entry) => _buildChatCard(entry.value, chats.indexOf(entry.value)))
                            .toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ...active.asMap().entries.map(
            (entry) => _buildChatCard(entry.value, chats.indexOf(entry.value)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat, int index) {
    return Card(
      color: const Color(0xFFEAF1ED), //color 
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    chat['name'][0],
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
                      color: chat['status'] == 'online' ? Colors.green : Colors.grey,
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
                      Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(chat['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['lastMessage'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['userType'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
   if (chat['unread'] > 0)
  Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.red.shade700,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      chat['unread'].toString(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  ),
    Theme(
  data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
      color: Color(0xFFE8F5E9), // Light green background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),),
      //cardColor: Color(0xFFE8F5E9),
      //cardColor: Color(0xFFEAF1ED), 
      //cardColor: Color(0xFFF0F0EC), // custom background color
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  ),
  child: PopupMenuButton<String>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    onSelected: (value) {
      switch (value) {
        case 'delete':
          _deleteChat(index);
          break;
        case 'archive':
          _archiveChat(index);
          break;
        case 'unarchive':
          _unarchiveChat(index);
          break;
        case 'mark_read':
          _markAsRead(index);
          break;
      }
    },
    itemBuilder: (context) => [
      if (!chat['archived'])
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
      if (chat['archived'])
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
     ]
),

          ],
        ),
      ),
    );
  }
}

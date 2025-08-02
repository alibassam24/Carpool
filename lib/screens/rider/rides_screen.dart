import 'package:flutter/material.dart';
import '/services/chat_service.dart';

List<Map<String, dynamic>> chats = ChatService().getAllChats();
class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final List<String> _rides = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // ✅ Delay data fetch after first frame (to prevent build error)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRides();
    });

    _scrollController.addListener(_onScroll);
  }

  /// 🧠 Loads mock rides data with pagination support
  Future<void> _loadRides({bool refresh = false}) async {
    if (_isLoadingMore) return;

    if (refresh) {
      setState(() {
        _page = 1;
        _rides.clear();
        _hasMore = true;
      });
    }

    setState(() => _isLoadingMore = true);

    // Simulate API/network delay
    await Future.delayed(const Duration(seconds: 2));

    if (_page > 3) {
      // No more pages
      setState(() {
        _hasMore = false;
        _isLoadingMore = false;
      });
      return;
    }

    // 🧪 Mock ride data
    List<String> newRides = List.generate(
      10,
      (index) => "Ride ${((_page - 1) * 10) + index + 1}",
    );

    setState(() {
      _rides.addAll(newRides);
      _isLoadingMore = false;
      _page++;
    });
  }

  /// 📦 Automatically load more rides when user scrolls near bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadRides();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 🔍 Shows search modal bottom sheet with white background
  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Search Rides",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSearchField("From", Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildSearchField("To", Icons.location_on),
              const SizedBox(height: 12),
              _buildSearchField("Time (optional)", Icons.access_time),
              const SizedBox(height: 12),
              _buildSearchField("Max Price (optional)", Icons.attach_money),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Add actual search filter logic here
                },
                icon: const Icon(Icons.search),
                label: const Text("Find Rides"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔤 Reusable input field used inside search modal
  Widget _buildSearchField(String label, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Available Rides"),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadRides(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _rides.length + (_hasMore ? 1 : 0),

itemBuilder: (context, index) {
  if (index < _rides.length) {
    final rideTitle = _rides[index];
    final driverName = "Driver ${index + 1}"; // Simulated driver name

    return Card(
      color: const Color(0xFFE6F2EF),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_car, color: Color(0xFF255A45)),
              title: Text(rideTitle),
              subtitle: const Text("10:30 AM • Rs 300"),
              trailing: ElevatedButton(
                onPressed: () {
                  // Book ride (future logic)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                ),
                child: const Text("Book", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    try {
                      ChatService().startChatWith(driverName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Chat started with $driverName")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to start chat: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF255A45),
                    side: const BorderSide(color: Color(0xFF255A45)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Chat"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Join request sent")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255A45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text("Request"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } else {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
},
// item builder
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSearchBottomSheet(context),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search),
        label: const Text("Search"),
      ),
    );
  }
}

//theme cards dynamically
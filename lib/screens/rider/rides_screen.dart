import 'package:carpool_connect/screens/rider/chat_screen.dart';
import 'package:carpool_connect/services/user_service.dart';
import 'package:flutter/material.dart';
import '/services/chat_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final supabase = Supabase.instance.client;

  final List<Map<String, dynamic>> _rides = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  // cache driver profiles to reduce round-trips
  final Map<String, Map<String, dynamic>> _profileCache = {};

  // search filters
  String? _searchOrigin;
  String? _searchDestination;
  double? _maxPrice;

  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRides());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- Helpers ----------

  String _fmtDate(dynamic dt) {
    try {
      DateTime d;
      if (dt is DateTime) {
        d = dt.toLocal();
      } else if (dt is String && dt.isNotEmpty) {
        d = DateTime.parse(dt).toLocal();
      } else {
        return 'Unknown';
      }
      String two(int v) => v.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<Map<String, dynamic>?> _fetchDriverProfile(String driverId) async {
    if (_profileCache.containsKey(driverId)) return _profileCache[driverId];
    try {
      final res = await supabase
          .from('profiles')
          .select('id, name, email')
          .eq('id', driverId)
          .maybeSingle();
      if (res != null) _profileCache[driverId] = Map<String, dynamic>.from(res);
      return res;
    } catch (e) {
      debugPrint('❌ fetch profile error: $e');
      return null;
    }
  }

  // ---------- Data ----------

  Future<void> _loadRides({bool refresh = false}) async {
    if (_isLoadingMore) return;

    if (refresh) {
      if (!mounted) return;
      setState(() {
        _page = 1;
        _rides.clear();
        _hasMore = true;
      });
    }

    if (!_hasMore) return;

    if (!mounted) return;
    setState(() => _isLoadingMore = true);

    try {
      final from = (_page - 1) * _pageSize;
      final to = from + _pageSize - 1;

      // base query
      var query = supabase
          .from('rides')
          .select('id, carpooler_id, origin_text, destination_text, date_time, price');
        //  .order('date_time', ascending: true)
        // .range(from, to);

      // filters (use .filter for max compatibility)
      if (_searchOrigin != null && _searchOrigin!.isNotEmpty) {
        query = query.filter('origin_text', 'ilike', '%${_searchOrigin!}%');
      }
      if (_searchDestination != null && _searchDestination!.isNotEmpty) {
        query = query.filter('destination_text', 'ilike', '%${_searchDestination!}%');
      }
      if (_maxPrice != null) {
        // if your column is numeric, passing a double is fine
        query = query.filter('price', 'lte', _maxPrice);
      }
      
      final res = await query
          .order('date_time', ascending: true)
          .range(from, to);

      final List data = (res as List?) ?? [];
      final fetched = data.map<Map<String, dynamic>>((r) {
        final m = Map<String, dynamic>.from(r as Map);
        return {
          'id': m['id'],
          'createdBy': m['carpooler_id'],
          'title': '${m['origin_text'] ?? ''} → ${m['destination_text'] ?? ''}',
          'time': _fmtDate(m['date_time']),
          'price': m['price'] == null ? 'Free' : 'Rs ${m['price']}',
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _rides.addAll(fetched);
        _page++;
        _isLoadingMore = false;
        if (fetched.length < _pageSize) _hasMore = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      Get.snackbar('Error', e.message);
    } catch (e, st) {
      debugPrint('❌ loadRides error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      Get.snackbar('Error', 'Failed to load rides. Please try again.');
    }
  }

  Future<void> _sendJoinRequest(int rideId, String driverId) async {
    try {
      final currentUser = UserService.currentUser; // your app’s current user
      if (currentUser == null) {
        Get.snackbar('Error', 'You must be logged in.');
        return;
      }

      await supabase.from('ride_requests').insert({
        'ride_id': rideId,           // bigint
        'rider_id': currentUser.id,  // uuid
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Success', 'Join request sent.');
    } on PostgrestException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send join request.');
    }
  }

  // ---------- UI ----------

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadRides();
    }
  }

  void _showSearchBottomSheet(BuildContext context) {
    final originCtl = TextEditingController(text: _searchOrigin);
    final destCtl = TextEditingController(text: _searchDestination);
    final priceCtl =
        TextEditingController(text: _maxPrice != null ? '$_maxPrice' : '');

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
              const Text('Search Rides',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: originCtl,
                decoration: _inputDecoration('From', Icons.location_on_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destCtl,
                decoration: _inputDecoration('To', Icons.location_on),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Max Price (optional)', Icons.attach_money),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _searchOrigin = originCtl.text.trim().isEmpty ? null : originCtl.text.trim();
                    _searchDestination =
                        destCtl.text.trim().isEmpty ? null : destCtl.text.trim();
                    _maxPrice = priceCtl.text.trim().isEmpty
                        ? null
                        : double.tryParse(priceCtl.text.trim());
                  });
                  _loadRides(refresh: true);
                },
                icon: const Icon(Icons.search),
                label: const Text('Find Rides'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255A45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Available Rides'),
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
              final ride = _rides[index];
              final createdBy = ride['createdBy']?.toString() ?? '';

              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchDriverProfile(createdBy),
                builder: (context, snap) {
                  final driver = snap.data;
                  final driverName = (driver != null && driver['name'] != null)
                      ? driver['name'] as String
                      : 'Unknown Driver';

                  // ensure int ride id
                  final int rideId = (ride['id'] is int)
                      ? ride['id'] as int
                      : int.tryParse('${ride['id']}') ?? 0;

                  return Card(
                    color: const Color(0xFFE6F2EF),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.directions_car,
                                color: Color(0xFF255A45)),
                            title: Text(driverName),
                            subtitle: Text('${ride['time']} • ${ride['price']}'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: driver == null
                                    ? null
                                    : () {
                                        try {
                                          final currentUser = UserService.currentUser;
                                          if (currentUser == null) {
                                            Get.snackbar('Error', 'You must be logged in.');
                                            return;
                                          }
                                          final currentUserId = currentUser.id;
                                          final otherUserId = driver['id'] as String;

                                          //ChatService.startChatIfNeeded(
                                           //  currentUserId, otherUserId);

                                         /*  Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                currentUserId: currentUserId,
                                                otherUserId: otherUserId,
                                              ),
                                            ),
                                          ); */

                                          Get.snackbar('Success',
                                              'Chat started with $driverName');
                                        } catch (e) {
                                          Get.snackbar('Failed to start chat', '$e');
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF255A45),
                                  side: const BorderSide(color: Color(0xFF255A45)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Chat'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: (driver == null || rideId == 0)
                                    ? null
                                    : () => _sendJoinRequest(rideId, driver['id'] as String),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF255A45),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                                icon: const Icon(Icons.send),
                                label: const Text('Join'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSearchBottomSheet(context),
        backgroundColor: const Color(0xFF255A45),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search),
        label: const Text('Search'),
      ),
    );
  }
}

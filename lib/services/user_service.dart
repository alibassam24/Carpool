// lib/services/user_service.dart

class DummyUser {
  final String id;
  final String name;
  final String role; // 'Rider' or 'Carpooler'
  final String email;
  final String password;

  DummyUser({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.password,
  });
}

class UserService {
  static DummyUser? _currentUser;

  static DummyUser get currentUser => _currentUser!;

  static List<DummyUser> dummyUsers = [
  DummyUser(
    id: '1',
    name: 'Ali Rider',
    role: 'Rider',
    email: 'rider@example.com',
    password: 'rider123',
  ),
  DummyUser(
    id: '2',
    name: 'Ahmed Driver',
    role: 'Carpooler',
    email: 'driver@example.com',
    password: 'driver123',
  ),
];
  static DummyUser? authenticate(String email, String password) {
  try {
    return dummyUsers.firstWhere(
      (u) => u.email == email && u.password == password,
    );
  } catch (_) {
    return null;
  }
}
  static void login(DummyUser user) {
    _currentUser = user;
  }


  static void logout() {
    _currentUser = null;
  }

  static bool isLoggedIn() {
    return _currentUser != null;
  }
}

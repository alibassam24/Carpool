import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoggedIn = false.obs;
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    user.value = supabase.auth.currentUser;
    isLoggedIn.value = user.value != null;

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      user.value = session?.user;
      isLoggedIn.value = session != null;
    });
  }

  Future<void> signUp(String email, String password) async {
    final res = await supabase.auth.signUp(email: email, password: password);
    if (res.user != null) {
      Get.snackbar("Success", "Check your email for verification");
    }
  }

  Future<void> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user != null) {
      Get.offAllNamed("/home"); // redirect to home
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed("/login");
  }
}

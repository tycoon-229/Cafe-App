import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final supabase = Supabase.instance.client;

  Future<void> login({
    required String email,
    required String password,
    required Function(String message) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      onSuccess("Đăng nhập thành công");
    } on AuthException catch (e) {
      onError(e.message);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required Function(String message) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.flutter://login-callback',
      );

      final user = response.user;

      if (user != null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': email,
          'username': username,
        });
      }

      onSuccess("Đăng ký thành công");
    } on AuthException catch (e) {
      onError(e.message);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
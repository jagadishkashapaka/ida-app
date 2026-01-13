import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  Future<bool> login(String email, String password) async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    // For demo purposes, we accept any input
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

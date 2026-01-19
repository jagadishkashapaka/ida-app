import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void login() => state = true;
  void logout() => state = false;
}

final isAdminProvider = NotifierProvider<AdminNotifier, bool>(AdminNotifier.new);

class AdminAuthService {
  static bool login(String username, String password) {
    return username == 'tpchero' && password == 'tpc@12';
  }
}

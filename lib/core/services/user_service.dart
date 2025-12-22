import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserRead? _currentUser;

  UserRead? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;

  // Логика: если у пользователя нет email, считаем его Гостем (согласно вашей схеме GuestUpgrade)
  bool get isGuest => _currentUser?.email == null;

  void setUser(UserRead user) {
    _currentUser = user;
    notifyListeners(); // <-- Уведомляем весь UI об изменениях
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}

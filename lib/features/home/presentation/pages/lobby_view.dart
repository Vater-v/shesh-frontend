import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/user_service.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  String _username = UserService().currentUser?.login ?? "Загрузка...";
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (!UserService().hasUser) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _apiService.getMe();
      UserService().setUser(user);
      if (mounted && user.login != null) {
        setState(() {
          _username = user.login!;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _username = "Гость");
      }
    }
  }

  void _onNotificationsTap() {
    // TODO: Открыть экран уведомлений
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Нет новых уведомлений")),
    );
  }

  void _onSettingsTap() {
    // TODO: Открыть настройки или диалог выхода
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Настройки")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Верхняя панель
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Приветствие
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Добро пожаловать,",
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Кнопки действий (Уведомления и Настройки)
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: _onNotificationsTap,
                      theme: theme,
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.settings_outlined, // Кнопка настроек
                      onTap: _onSettingsTap,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),

            // Пустое пространство (экран чист)
            const Spacer(),

            // Заглушка, чтобы экран не казался сломанным
            Center(
              child: Icon(
                  Icons.grid_view_rounded,
                  size: 64,
                  color: Colors.white.withOpacity(0.05)
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для создания кнопок в едином стиле
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 22, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}

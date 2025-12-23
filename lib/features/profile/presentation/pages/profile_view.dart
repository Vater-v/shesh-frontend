import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/user_service.dart';
import 'package:shesh/features/onboarding/presentation/pages/onboarding_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Состояние для блокировки кнопки выхода
  bool _isLoggingOut = false;

  // Диалог сохранения гостя с локальным состоянием загрузки
  Future<void> _showUpgradeDialog() async {
    final loginCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    // Переменная для отслеживания загрузки внутри диалога
    bool isDialogLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Запрещаем закрытие тапом мимо во время процесса
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text("Сохранить прогресс", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Придумайте логин и пароль, чтобы не потерять статистику при выходе.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: loginCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Логин",
                    labelStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Пароль",
                    labelStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                // Блокируем кнопку отмены во время загрузки
                onPressed: isDialogLoading ? null : () => Navigator.pop(ctx),
                child: const Text("Отмена"),
              ),
              ElevatedButton(
                // Если идет загрузка - кнопка неактивна
                onPressed: isDialogLoading
                    ? null
                    : () async {
                  // Обновляем состояние ТОЛЬКО диалога
                  setDialogState(() => isDialogLoading = true);

                  try {
                    final newUser = await ApiService().upgradeGuest(loginCtrl.text, passCtrl.text);
                    UserService().setUser(newUser); // Обновляем данные пользователя

                    if (mounted) {
                      Navigator.pop(ctx); // Закрываем диалог
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Аккаунт успешно сохранен!"), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Ошибка: $e"), backgroundColor: Colors.red),
                      );
                      // Сбрасываем загрузку при ошибке, чтобы можно было попробовать снова
                      setDialogState(() => isDialogLoading = false);
                    }
                  }
                },
                // Меняем текст на индикатор загрузки
                child: isDialogLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
                    : const Text("Сохранить"),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Блокируем интерфейс
    setState(() => _isLoggingOut = true);

    try {
      await ApiService().logout();
    } catch (e) {
      // Игнорируем ошибки сети при выходе, все равно удаляем токен локально
      debugPrint("Logout error: $e");
    } finally {
      UserService().clear(); // Чистим кэш пользователя

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserService(),
      builder: (context, _) {
        final user = UserService().currentUser;
        final isGuest = UserService().isGuest;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 20)
                          ]
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF2C2C2C),
                        child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    if (!isGuest)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 20, color: Colors.black),
                      )
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                    user?.login ?? "Гость",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                ),

                // Бейдж статуса
                if (isGuest)
                  GestureDetector(
                    onTap: _showUpgradeDialog,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withOpacity(0.5))
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text("Аккаунт не сохранен", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Pro Player", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),

                const SizedBox(height: 40),

                if (isGuest)
                  _buildSettingsItem(Icons.save_as, "Сохранить аккаунт", onTap: _showUpgradeDialog),

                _buildSettingsItem(Icons.settings, "Настройки игры"),
                _buildSettingsItem(Icons.language, "Язык"),
                _buildSettingsItem(Icons.help_outline, "Помощь"),
                const Divider(color: Colors.white10, height: 30),

                // Пункт выхода с индикацией загрузки
                _buildSettingsItem(
                    Icons.logout,
                    _isLoggingOut ? "Выход..." : "Выйти",
                    isDestructive: true,
                    onTap: _isLoggingOut ? null : () => _logout(context),
                    trailing: _isLoggingOut
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                        : null
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white),
      ),
      title: Text(title, style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w500
      )),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
      onTap: onTap,
      enabled: onTap != null, // Визуально отключает нажатие, если null
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

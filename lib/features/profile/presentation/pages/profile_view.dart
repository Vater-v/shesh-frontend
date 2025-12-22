import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/features/onboarding/presentation/pages/onboarding_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2C2C2C),
                    child: Icon(Icons.person, size: 60, color: Color(0xFFD4AF37)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 20, color: Colors.black),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text("Игрок", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text("Новичок", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 40),

            _buildSettingsItem(Icons.settings, "Настройки игры"),
            _buildSettingsItem(Icons.language, "Язык"),
            _buildSettingsItem(Icons.help_outline, "Помощь"),
            const Divider(color: Colors.white10, height: 30),
            _buildSettingsItem(Icons.logout, "Выйти", isDestructive: true, onTap: () => _logout(context)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

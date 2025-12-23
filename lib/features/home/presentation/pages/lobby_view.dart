import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/user_service.dart';

// Модель для элемента списка (можно вынести в отдельный файл models/lobby_module.dart)
class LobbyModule {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  bool isEnabled;

  LobbyModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.isEnabled = false,
  });
}

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  final ApiService _apiService = ApiService();
  String _username = UserService().currentUser?.login ?? "Загрузка...";

  // Имитация данных баланса (пока нет в API)
  final int _fuelBalance = 1450;

  // Состояние списка модулей
  final List<LobbyModule> _modules = [
    LobbyModule(
      id: '1',
      title: 'Aim Assist',
      subtitle: 'Автоматическая наводка на цель',
      icon: Icons.gps_fixed,
      iconColor: Colors.redAccent,
      isEnabled: true,
    ),
    LobbyModule(
      id: '2',
      title: 'Wallhack',
      subtitle: 'Видимость сквозь препятствия',
      icon: Icons.visibility,
      iconColor: Colors.cyanAccent,
      isEnabled: false,
    ),
    LobbyModule(
      id: '3',
      title: 'Skin Changer',
      subtitle: 'Визуальная замена моделей',
      icon: Icons.palette,
      iconColor: Colors.purpleAccent,
      isEnabled: true,
    ),
    LobbyModule(
      id: '4',
      title: 'Bunny Hop',
      subtitle: 'Автоматическая распрыжка',
      icon: Icons.directions_run,
      iconColor: Colors.orangeAccent,
      isEnabled: false,
    ),
  ];

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

  void _onToggleModule(int index, bool value) {
    setState(() {
      _modules[index].isEnabled = value;
    });
    // Тут можно отправить запрос на API для сохранения состояния
  }

  @override
  Widget build(BuildContext context) {
    // Отступ снизу, чтобы контент не перекрывался нижним меню (NavBar)
    const double bottomNavBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.transparent, // Фон берется из HomeLayout
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 1. Верхняя панель пользователя
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _UserHeader(
                username: _username,
                isGuest: UserService().isGuest,
                onSettingsTap: () => _showSnackBar("Настройки"),
                onNotificationsTap: () => _showSnackBar("Уведомления"),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Баланс Fuel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _FuelCard(balance: _fuelBalance),
            ),

            const SizedBox(height: 24),

            // 3. Панель с элементами (Scrollable)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E), // Темный фон панели
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, bottomNavBarHeight),
                    itemCount: _modules.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 24),
                    itemBuilder: (context, index) {
                      return _ModuleItem(
                        module: _modules[index],
                        onChanged: (val) => _onToggleModule(index, val),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// --- Компоненты UI (Private Widgets) ---

class _UserHeader extends StatelessWidget {
  final String username;
  final bool isGuest;
  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;

  const _UserHeader({
    required this.username,
    required this.isGuest,
    required this.onSettingsTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Аватар
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            image: const DecorationImage(
              // Плейсхолдер аватара
              image: AssetImage('assets/images/avatar_placeholder.png'),
              // Если нет ассета, используем иконку ниже в child,
              // но для примера оставим структуру
            ),
            color: const Color(0xFF2C2C2C),
          ),
          child: const Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 12),

        // Ник и Статус
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    isGuest ? Icons.account_circle_outlined : Icons.verified,
                    size: 12,
                    color: isGuest ? Colors.grey : const Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGuest ? "Гость" : "Premium",
                    style: TextStyle(
                      fontSize: 12,
                      color: isGuest ? Colors.grey : const Color(0xFFD4AF37),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Кнопки действий
        _ActionButton(icon: Icons.notifications_none_rounded, onTap: onNotificationsTap),
        const SizedBox(width: 8),
        _ActionButton(icon: Icons.settings_outlined, onTap: onSettingsTap),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _FuelCard extends StatelessWidget {
  final int balance;

  const _FuelCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.2),
            Colors.black.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFD4AF37), size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FUEL BALANCE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4AF37).withOpacity(0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    balance.toString(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'monospace', // Моноширинный шрифт для цифр
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              elevation: 4,
            ),
            child: const Icon(Icons.add, size: 20),
          )
        ],
      ),
    );
  }
}

class _ModuleItem extends StatelessWidget {
  final LobbyModule module;
  final ValueChanged<bool> onChanged;

  const _ModuleItem({required this.module, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: module.isEnabled
              ? const Color(0xFFD4AF37).withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Картинка/Иконка элемента
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: module.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(module.icon, color: module.iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Заголовок и подзаголовок
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: module.isEnabled ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Тумблер
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: module.isEnabled,
                onChanged: onChanged,
                activeColor: const Color(0xFFD4AF37),
                activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

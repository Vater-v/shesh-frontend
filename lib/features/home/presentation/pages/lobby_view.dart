import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/user_service.dart';
import 'package:device_apps_plus/device_apps_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// Импорт для управления оверлеем
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class LobbyModule {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? packageName;
  final bool isSoon;
  bool isEnabled;
  bool isInstalled;

  LobbyModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.packageName,
    this.isSoon = false,
    this.isEnabled = false,
    this.isInstalled = false,
  });
}

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  String _username = UserService().currentUser?.login ?? "Загрузка...";
  final int _fuelBalance = 1450;

  late List<LobbyModule> _modules;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!UserService().hasUser) {
      _loadUserProfile();
    }
    _initModules();
    _checkAllPackagesStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPackagesStatus();
    }
  }

  void _initModules() {
    _modules = [
      LobbyModule(
        id: '1',
        title: 'PPNards',
        subtitle: 'Классические нарды',
        icon: Icons.games_outlined,
        iconColor: const Color(0xFFD4AF37),
        packageName: 'com.ObviousChoice.PPBackgammon',
        isEnabled: false,
      ),
      LobbyModule(
        id: '2',
        title: 'Backgammon',
        subtitle: 'Скоро',
        icon: Icons.hourglass_empty_rounded,
        iconColor: Colors.grey,
        isSoon: true,
      ),
      LobbyModule(
        id: '3',
        title: 'Poker',
        subtitle: 'Скоро',
        icon: Icons.lock_outline_rounded,
        iconColor: Colors.white12,
        isSoon: true,
      ),
      LobbyModule(
        id: '4',
        title: 'Durak',
        subtitle: 'Скоро',
        icon: Icons.lock_outline_rounded,
        iconColor: Colors.white12,
        isSoon: true,
      ),
    ];
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

  Future<void> _checkAllPackagesStatus() async {
    if (!Platform.isAndroid) return;

    for (var module in _modules) {
      if (module.packageName != null) {
        try {
          bool installed = await DeviceAppsPlus().isAppInstalled(module.packageName!);
          module.isInstalled = installed;
        } catch (e) {
          debugPrint("Ошибка проверки пакета ${module.packageName}: $e");
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingStatus = false;
      });
    }
  }

  // --- ЛОГИКА ОВЕРЛЕЯ ---
  Future<void> _onToggleModule(int index, bool value) async {
    if (_modules[index].isSoon) return;

    // Если пытаемся включить модуль - проверяем права
    if (value) {
      final bool status = await FlutterOverlayWindow.isPermissionGranted();
      if (!status) {
        // Запрашиваем права
        final bool? boolResult = await FlutterOverlayWindow.requestPermission();
        if (boolResult != true) {
          _showSnack("Необходимо разрешение для отображения поверх окон");
          return; // Не включаем тумблер, если прав нет
        }
      }
    }

    setState(() {
      for (int i = 0; i < _modules.length; i++) {
        if (i == index) {
          _modules[i].isEnabled = value;
        } else {
          _modules[i].isEnabled = false;
        }
      }
    });

    // Управление отображением оверлея
    try {
      if (value) {
        // Если уже активен, не переоткрываем (или можно закрыть и открыть новый)
        if (await FlutterOverlayWindow.isActive()) return;

        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Shesh Helper",
          overlayContent: "Helper active",
          flag: OverlayFlag.defaultFlag,
          alignment: OverlayAlignment.centerLeft,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: 300, // Высота области оверлея (лучше делать компактным)
          width: 300,
        );
      } else {
        // Если выключили - закрываем
        await FlutterOverlayWindow.closeOverlay();
      }
    } catch (e) {
      debugPrint("Overlay error: $e");
    }
  }

  Future<void> _launchGame(String packageName) async {
    if (Platform.isAndroid) {
      try {
        await DeviceAppsPlus().openApp(packageName);
      } catch (e) {
        _showSnack("Не удалось запустить приложение");
      }
    } else {
      _showSnack("Запуск работает только на Android");
    }
  }

  Future<void> _downloadGame(String packageName) async {
    final url = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnack("Не удалось открыть магазин");
      }
    } catch (e) {
      _showSnack("Ошибка при открытии ссылки");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double bottomNavBarHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _UserHeader(
                username: _username,
                isGuest: UserService().isGuest,
                onSettingsTap: () => _showSnack("Настройки"),
                onNotificationsTap: () => _showSnack("Уведомления"),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _FuelCard(balance: _fuelBalance),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, -5))
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
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildModuleCard(_modules[index], index);
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

  Widget _buildModuleCard(LobbyModule module, int index) {
    final bool isActive = module.isEnabled;
    final bool isSoon = module.isSoon;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFD4AF37).withOpacity(0.05)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFFD4AF37).withOpacity(0.6)
              : Colors.white.withOpacity(0.05),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ] : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSoon
                        ? Colors.black26
                        : module.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                      module.icon,
                      color: isSoon ? Colors.white24 : module.iconColor,
                      size: 26
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            module.title.isEmpty ? "Unknown" : module.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isSoon
                                  ? Colors.white38
                                  : (isActive ? Colors.white : Colors.white70),
                            ),
                          ),
                          if (module.isInstalled && !isSoon) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle, color: Colors.green, size: 14),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSoon
                              ? const Color(0xFFD4AF37).withOpacity(0.7)
                              : Colors.white38,
                          fontWeight: isSoon ? FontWeight.w500 : FontWeight.normal,
                          fontStyle: isSoon ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSoon)
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: isActive,
                      onChanged: (val) => _onToggleModule(index, val),
                      activeColor: Colors.black,
                      activeTrackColor: const Color(0xFFD4AF37),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.white10,
                    ),
                  )
                else
                  Icon(Icons.lock, color: Colors.white.withOpacity(0.1), size: 20),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isActive
                ? Column(
              children: [
                Divider(height: 1, color: const Color(0xFFD4AF37).withOpacity(0.2)),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: module.isInstalled
                      ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchGame(module.packageName!),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text("ИГРАТЬ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadGame(module.packageName!),
                      icon: const Icon(Icons.download_rounded, size: 24),
                      label: const Text("СКАЧАТЬ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Приватные виджеты (_UserHeader, _ActionButton, _FuelCard) остаются без изменений
// скопируйте их из старого файла, если нужно, или они подтянутся, если они в том же файле
// (Я их не включал сюда повторно для краткости, так как они не менялись, но они должны быть в файле).
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
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/images/avatar_placeholder.png'),
              fit: BoxFit.cover,
            ),
            color: const Color(0xFF2C2C2C),
          ),
          child: const Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                      fontFamily: 'monospace',
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

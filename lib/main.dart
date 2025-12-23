import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shesh/core/services/local_storage_service.dart';
import 'package:shesh/core/theme/app_theme.dart';
import 'package:shesh/features/splash/presentation/splash_screen.dart';
// Импорт виджета оверлея
import 'package:shesh/features/home/presentation/widgets/overlay_widget.dart';

// Точка входа для оверлея (запускается Android-ом в отдельном процессе)
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyOverlayWidget(),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHESH',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

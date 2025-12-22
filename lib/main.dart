import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shesh/core/services/local_storage_service.dart';
import 'package:shesh/core/theme/app_theme.dart';
import 'package:shesh/features/splash/presentation/splash_screen.dart';

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
      title: 'Shesh Backgammon',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,

      // Используем тему из вашего файла core/theme/app_theme.dart
      darkTheme: AppTheme.darkTheme,

      // Теперь всегда стартуем со сплэш-экрана,
      // который сам решит, куда направить пользователя
      home: const SplashScreen(),
    );
  }
}

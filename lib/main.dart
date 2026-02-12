import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/settings/presentation/settings_providers.dart';
import 'src/features/home/presentation/main_screen.dart';

import 'src/features/billing/application/bill_cleanup_service.dart';

// Initialization provider
final appStartupProvider = FutureProvider<void>((ref) async {
  // Run bill cleanup on startup
  await ref.read(billCleanupServiceProvider).runCleanup();
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize app startup logic
    ref.watch(appStartupProvider);

    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      title: 'Platterlytics',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.value ?? ThemeMode.system,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

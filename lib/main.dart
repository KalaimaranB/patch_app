import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rylgzpjewjamxkvhtbos.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ5bGd6cGpld2phbXhrdmh0Ym9zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMjc0MjIsImV4cCI6MjA3ODcwMzQyMn0.745s4ReQzvcUdeGJQgo-O8EsCuq6jNjq9qMOoqj0bQ4',
  );

  runApp(const ProviderScope(child: PatchApp()));
}

class PatchApp extends ConsumerWidget {
  const PatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Patch Medical',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

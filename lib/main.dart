import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(AudioPlayerService(), StorageService()),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(StorageService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(StorageService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        final accent = theme.dynamicTheme ? theme.accent : AppColors.primary;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: HomeScreen(),
        );
      },
    );
  }
}

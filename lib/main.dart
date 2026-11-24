import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'accounts_page.dart';
import 'settings.dart';
import 'app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await loadAppearance();
  runApp(const IptvApp());
}

class IptvApp extends StatelessWidget {
  const IptvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, _) => ValueListenableBuilder<Color>(
        valueListenable: accentNotifier,
        builder: (_, accent, _) => MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: _buildTheme(accent, Brightness.light),
          darkTheme: _buildTheme(accent, Brightness.dark),
          home: const AccountsPage(),
        ),
      ),
    );
  }
}

ThemeData _buildTheme(Color seed, Brightness b) {
  final dark = b == Brightness.dark;
  final bg = dark ? const Color(0xFF0E1014) : const Color(0xFFF6F7F9);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b)
      .copyWith(surface: dark ? const Color(0xFF161A21) : Colors.white);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    listTileTheme: ListTileThemeData(
      selectedTileColor: scheme.primary.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: bg,
      indicatorColor: scheme.primary.withValues(alpha: 0.2),
    ),
  );
}
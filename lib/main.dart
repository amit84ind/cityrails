import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/db_helper.dart';
import 'screens/home_screen.dart';
import 'theme/tiranga_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Android status bar and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SQLite Local Database
  try {
    await DBHelper.instance.database;
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  runApp(const CityRailsApp());
}

class CityRailsApp extends StatelessWidget {
  const CityRailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityRails - Mumbai Local Train & Transit',
      debugShowCheckedModeBanner: false,
      theme: TirangaTheme.darkTirangaTheme,
      home: const HomeScreen(),
    );
  }
}

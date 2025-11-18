import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'models/schedule_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'screens/focus_mode_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_application_2/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/setting_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
      ],
      child: const ScheduleApp(),
    ),
  );
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hệ thống sắp xếp lịch trình',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        primaryColor: themeProvider.selectedColor,
        cardColor: Colors.white,
        canvasColor: themeProvider.selectedBackgroundColor,
        colorScheme: ColorScheme.light(
           primary: themeProvider.selectedColor,
           secondary: themeProvider.selectedColor.withOpacity(0.7),
           surface: Colors.white,
           background: Colors.blue.shade50,
           error: Colors.red,
           onPrimary: Colors.white,
           onSecondary: Colors.black,
           onSurface: Colors.black87,
           onBackground: Colors.black87,
           onError: Colors.white,
           brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark,
        primaryColor: themeProvider.selectedColor,
        cardColor: Colors.grey.shade900,
        canvasColor: themeProvider.selectedBackgroundColor,
        colorScheme: ColorScheme.dark(
           primary: themeProvider.selectedColor,
           secondary: themeProvider.selectedColor.withOpacity(0.7),
           surface: Colors.grey.shade900,
           background: Colors.black,
           error: Colors.redAccent,
           onPrimary: Colors.white,
           onSecondary: Colors.white70,
           onSurface: Colors.white70,
           onBackground: Colors.white70,
           onError: Colors.black,
           brightness: Brightness.dark,
         ),
      ),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
      locale: const Locale('vi', 'VN'),
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/setting': (context) => const SettingScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/badges': (context) => const BadgesSection(),
        '/profile': (context) => const ProfileScreen(),
        '/workspace': (context) => const WorkspaceScreen(),
        '/focus': (context) => const FocusModeScreen(),
      },
    );
  }
}

void testDatabaseConnection() async {
}

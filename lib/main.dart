import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/program_screen.dart';
import 'screens/intervenants_screen.dart';
import 'screens/sponsors_screen.dart';
import 'screens/partners_screen.dart';
import 'screens/videos_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFRAN 2025',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
      routes: {
        '/home': (context) => const MainScreen(initialIndex: 0),
        '/program': (context) => const MainScreen(initialIndex: 1),
        '/speakers': (context) => const MainScreen(initialIndex: 2),
        '/sponsors': (context) => const MainScreen(initialIndex: 3),
        '/partners': (context) => const MainScreen(initialIndex: 4),
        '/videos': (context) => const MainScreen(initialIndex: 5),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProgramScreen(),
    IntervenantsScreen(),
    SponsorsScreen(),
    PartnersScreen(),
    VideosScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Program',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Speakers',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Sponsors',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake),
            label: 'Partners',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
        ],
      ),
    );
  }
}

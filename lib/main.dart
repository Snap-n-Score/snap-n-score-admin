import 'package:flutter/material.dart';
import 'package:snap_n_score_admin/ScreenChoice.dart';
import 'package:snap_n_score_admin/HomePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.teal.shade900,
  ),
);
void main() async {
  await Supabase.initialize(
    url: 'https://dpbchvnpfkjvkjagaqnh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYmNodm5wZmtqdmtqYWdhcW5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEzOTk0OTYsImV4cCI6MjAyNjk3NTQ5Nn0.NSvPVIKngCAEP-YM19KHFwtqsni1YFa-QcAZhCdLrbM',
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final supabase = Supabase.instance.client;

class _MyAppState extends State<MyApp> {
  Widget _currentScreen = const ScreenChoice();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _redirectUser();
  }

  void _redirectUser() {
    final user = supabase.auth.currentSession;
    if (user != null) {
      setState(() {
        _currentScreen = const HomePage();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: _currentScreen,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoreboard_app/HomePage.dart';
import 'package:scoreboard_app/LoginPage.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ldbkhcfhumtyvlqjndcl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYmtoY2ZodW10eXZscWpuZGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4MDg3NTgsImV4cCI6MjA2OTM4NDc1OH0.vfjLpTax82Xu9zR6UvmBkfiPUXdPMJ2drN_02ks8gv0',
  );
  runApp(MyApp());
}

// Sets up main app widget with a ChangeNotifierProvider and custom theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scoreboard',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 211, 148, 53),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFA726), brightness: Brightness.light
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black, 
            selectionColor: Colors.black26, 
            selectionHandleColor: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.black), 
            labelStyle: TextStyle(color: Colors.black), 
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

// AuthWrapper widget that checks auth state and navigates to appropriate page
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (supabase.auth.currentUser == null) {
          return LoginPage();
        }
        return HomePage();
      },
    );
  }
}

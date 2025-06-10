import 'package:fit2eat/app/app_theme.dart';
import 'package:fit2eat/app/wrapper.dart'; // Import the Wrapper
import 'package:fit2eat/features/auth/data/services/auth_service.dart';
import 'package:fit2eat/features/auth/presentation/screens/auth_screen.dart';
import 'package:fit2eat/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fit2eat/features/history/data/services/firestore_service.dart'; // Import FirestoreService
import 'package:fit2eat/features/history/presentation/screens/history_screen.dart';
import 'package:fit2eat/features/home/presentation/screens/home_screen.dart';
import 'package:fit2eat/features/scanner/data/services/analysis_service.dart'; // Import AnalysisService
import 'package:fit2eat/features/scanner/presentation/screens/result_screen.dart';
import 'package:fit2eat/features/scanner/presentation/viewmodels/scanner_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(FirebaseAuth.instance);
    final firestoreService = FirestoreService(); // Create instance
    final analysisService = AnalysisService();   // Create instance

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService), // Provide FirestoreService
        Provider<AnalysisService>.value(value: analysisService),   // Provide AnalysisService
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(authService: authService),
        ),
        ChangeNotifierProvider<ScannerViewModel>(
          create: (context) => ScannerViewModel(
            analysisService: analysisService,
            firestoreService: firestoreService,
            authService: authService, // Pass authService here
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Fit2Eat',
        theme: AppTheme.lightTheme,
        // home: const Wrapper(), // We'll use initialRoute and routes instead
        initialRoute: Wrapper.routeName, // Or '/auth' if Wrapper handles initial redirection logic
        routes: {
          Wrapper.routeName: (context) => const Wrapper(),
          AuthScreen.routeName: (context) => const AuthScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          ResultScreen.routeName: (context) => const ResultScreen(scanResult: null), // Placeholder, actual result passed via arguments
          HistoryScreen.routeName: (context) => const HistoryScreen(),
        },
      ),
    );
  }
}
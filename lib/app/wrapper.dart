import 'package:fit2eat/features/auth/presentation/screens/auth_screen.dart';
import 'package:fit2eat/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fit2eat/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class Wrapper extends StatelessWidget {
  static const String routeName = '/'; // Add this line for the wrapper itself
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the authentication state changes stream
    return StreamBuilder<User?>( // Use StreamBuilder
      stream: Provider.of<AuthViewModel>(context).authStateChanges, // Listen to authStateChanges stream
      builder: (context, snapshot) {
        // Check connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the stream to emit its first value
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Get the user from the snapshot
        final user = snapshot.data;

        if (user != null) {
          // User is signed in, return HomeScreen directly
          return const HomeScreen();
        } else {
          // User is not signed in, return AuthScreen directly
          return const AuthScreen();
        }
      },
    );
  }
}
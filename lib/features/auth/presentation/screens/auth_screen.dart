import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:fit2eat/features/auth/presentation/viewmodels/auth_viewmodel.dart'; // Import AuthViewModel

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth'; // Add this line
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // To toggle between Login and Sign Up

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async { // Made _submit async
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Access the AuthViewModel
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      try {
        if (_isLogin) {
          await authViewModel.signIn(email, password);
        } else {
          await authViewModel.signUp(email, password);
        }
        // Navigation will be handled by the Wrapper based on auth state changes
        // If there's an error, AuthViewModel's errorMessage will be set
        if (mounted && authViewModel.errorMessage != null) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authViewModel.errorMessage!)),
          );
        }
      } catch (e) {
        // This catch block might be redundant if AuthViewModel handles errors and sets errorMessage
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access AuthViewModel to show loading state or error messages
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                // Show a loading indicator if authViewModel.isLoading is true
                authViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(_isLogin ? 'Login' : 'Sign Up'),
                      ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: authViewModel.isLoading ? null : () { // Disable button when loading
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
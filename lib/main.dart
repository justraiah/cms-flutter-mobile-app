import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const CapstoneClinicApp());
}

class CapstoneClinicApp extends StatelessWidget {
  const CapstoneClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colegio de Montalban Clinic',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _studentNumberController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    final studentNumber =
        _studentNumberController.text.trim();

    final password =
        _passwordController.text;

    if (studentNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student Number and password are required.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post(
        '/mobile/auth/login',
        body: {
          'studentNumber': studentNumber,
          'password': password,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token'];

        print('LOGIN SUCCESS');
        print('JWT: $token');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
          ),
        );
      } else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Status: ${response.statusCode}\n${response.body}',
      ),
      duration: const Duration(seconds: 8),
    ),
  );
}
    } catch (e) {
      print('LOGIN ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to connect to the clinic server.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_hospital,
                  size: 80,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Colegio de Montalban Clinic',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Student Health Portal',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _studentNumberController,
                  decoration: InputDecoration(
                    labelText: 'Student Number',
                    hintText: 'e.g. 26-00000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

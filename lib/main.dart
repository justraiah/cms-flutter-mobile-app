import 'dart:convert';
import 'package:flutter/material.dart';
import 'Services/api_service.dart';
import 'screens/medical_records_screen.dart';
import 'screens/vital_signs_screen.dart';

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
  final fullName = data['fullName'];
  final studentNumber = data['studentNumber'];

  print('LOGIN SUCCESS');
  print('JWT received.');

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DashboardScreen(
        fullName: fullName,
        studentNumber: studentNumber,
        token: token,
      ),
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
class DashboardScreen extends StatelessWidget {
  final String fullName;
  final String studentNumber;
  final String token;

  const DashboardScreen({
    super.key,
    required this.fullName,
    required this.studentNumber,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day, $fullName 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Student Number: $studentNumber',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Clinic Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _DashboardCard(
                icon: Icons.medical_information,
                title: 'Medical Records',
                subtitle: 'View your medical information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalRecordsScreen(
                        token: token,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _DashboardCard(
                icon: Icons.monitor_heart,
                title: 'Vital Signs',
                subtitle: 'View your recorded vital signs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VitalSignsScreen(
                        token: token,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _DashboardCard(
                icon: Icons.campaign,
                title: 'Clinic Announcements',
                subtitle: 'View the latest clinic announcements',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlaceholderScreen(
                        title: 'Clinic Announcements',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          child: Icon(icon),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: onTap,
      ),
    );
  }
}
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This section will be connected to the clinic API next.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

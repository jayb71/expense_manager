import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_manager/main.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

// Future _signIn() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final response = await supabase.auth.signUp(email: email, password: password);
//     if (response.error != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response.error!.message),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }

  Future _signIn() async {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          SupaEmailAuth(
            redirectTo: kIsWeb ? null : 'io.mydomain.myapp://callback',
            onSignInComplete: (response) {},
            onSignUpComplete: (response) {},
            metadataFields: [
              MetaDataField(
                prefixIcon: const Icon(Icons.person),
                label: 'Username',
                key: 'username',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter something';
                  }
                  return null;
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

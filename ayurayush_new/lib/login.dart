import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_config.dart';
import 'user_session.dart';
import 'styles.dart';

class LoginPageContent extends StatefulWidget {
  @override
  _LoginPageContentState createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<LoginPageContent> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (_usernameController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _error = 'Both fields are required.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await http.post(
      Uri.parse(AppConfig.apiBaseUrl + '/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
      }),
    );

    setState(() {
      _loading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final username = data['username'] ?? _usernameController.text.trim();
      final userId = data['userId'];
      final token = data['token'];
      int parsedUserId = 0;
      if (userId != null) {
        if (userId is int) {
          parsedUserId = userId;
        } else if (userId is String) {
          parsedUserId = int.tryParse(userId) ?? 0;
        } else if (userId is double) {
          parsedUserId = userId.toInt();
        }
        await UserSession.saveUserSession(username, parsedUserId);
      }
      if (token != null) {
        await UserSession.saveToken(token);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful!')));
      Navigator.pop(context, username);
    } else {
      setState(() {
        _error = 'Login failed. Please check your credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username or email address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4A2C2A), width: 2),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4A2C2A), width: 2),
            ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 16),
        if (_error != null)
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A2C2A),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: _loading 
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
             
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF4A2C2A),
            ),
            child: Text(
              'Lost your password?',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
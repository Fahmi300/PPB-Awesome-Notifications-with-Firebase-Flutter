import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_project_firebase_auth/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });


    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await NotificationService.createNotification(
        id: 2,
        title: 'Logging in...',
        body: 'Waiting',
        summary: 'Please wait while we verify your credentials.',
        notificationLayout: NotificationLayout.ProgressBar,
      );
      await Future.delayed(const Duration(seconds: 1));
      NotificationService.dismiss(2);
      await NotificationService.createNotification(
        id: 3,
        title: 'Login Account',
        body: 'Successfully Login',
        summary: 'Welcome back!',
      );
      navigateHome();
    } on FirebaseAuthException catch (e) {
      await NotificationService.createNotification(
        id: 5,
        title: 'Wrong Email or Password',
        body: 'Want Create Email First?',
        payload: {'navigate': 'true'},
        actionButtons: [
          NotificationActionButton(
            key: 'action_button',
            label: 'Create',
            actionType: ActionType.Default,
          )
        ],
      );
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 48),
              Icon(Icons.lock_outline, size: 100, color: Colors.blue[200]),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(label: Text('Email')),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
              ),
              const SizedBox(height: 24),
              _errorCode != ""
                  ? Column(
                  children: [Text(_errorCode), const SizedBox(height: 24)])
                  : const SizedBox(height: 0),
              OutlinedButton(
                onPressed: signIn,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: navigateRegister,
                    child: const Text('Register'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
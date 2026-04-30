import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../quit_selection_screen.dart';
import '../services/crave_auth_session.dart';
import '../theme/craveshield_colors.dart';
import '../widgets/craveshield_back_button.dart';
import '../widgets/craveshield_button.dart';
import '../widgets/craveshield_screen.dart';
import '../widgets/craveshield_text_field.dart';
import 'register_screen.dart';

class CraveLoginScreen extends StatefulWidget {
  const CraveLoginScreen({super.key});

  static const routeName = 'craveLogin';
  static const routePath = '/crave-login';

  @override
  State<CraveLoginScreen> createState() => _CraveLoginScreenState();
}

class _CraveLoginScreenState extends State<CraveLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _emailError = email.isEmpty
          ? 'Enter your email.'
          : !_isValidEmail(email)
              ? 'Enter a valid email address.'
              : null;
      _passwordError = password.isEmpty
          ? 'Enter your password.'
          : password.length < 8
              ? 'Use at least 8 characters.'
              : null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _signIn() async {
    if (_isLoading || !_validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await CraveAuthSession.saveSession(email: _emailController.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuitSelectionScreen()),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CraveShieldScreen(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CraveShieldBackButton(),
            const SizedBox(height: 40),
            Center(
              child: SvgPicture.asset(
                'assets/images/craveshield_logo.svg',
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in and continue your journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 42),
            CraveShieldTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) {
                  setState(() => _emailError = null);
                }
              },
            ),
            const SizedBox(height: 14),
            CraveShieldTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_rounded,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              errorText: _passwordError,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
              suffix: IconButton(
                color: CraveShieldColors.blue,
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: Colors.white,
                  checkColor: CraveShieldColors.blue,
                  side: const BorderSide(color: Colors.white, width: 1.6),
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                ),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Forgot Password coming soon.'),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            CraveShieldButton(
              text: _isLoading ? 'Signing In...' : 'Sign In',
              onPressed: _isLoading ? null : _signIn,
            ),
            const SizedBox(height: 12),
            CraveShieldButton(
              text: 'Create New Account',
              outlined: true,
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        CraveRegisterScreen.routePath,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

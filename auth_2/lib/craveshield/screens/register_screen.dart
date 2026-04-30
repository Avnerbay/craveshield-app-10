import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../quit_selection_screen.dart';
import '../services/crave_auth_session.dart';
import '../theme/craveshield_colors.dart';
import '../widgets/craveshield_back_button.dart';
import '../widgets/craveshield_screen.dart';
import 'login_screen.dart';

class CraveRegisterScreen extends StatefulWidget {
  const CraveRegisterScreen({super.key});

  static const routeName = 'craveRegister';
  static const routePath = '/crave-register';

  @override
  State<CraveRegisterScreen> createState() => _CraveRegisterScreenState();
}

class _CraveRegisterScreenState extends State<CraveRegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AnimationController _introController;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  bool get _canSubmit {
    return !_isLoading &&
        _nameController.text.trim().isNotEmpty &&
        _isValidEmail(_emailController.text.trim()) &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _confirmPasswordController.text;
  }

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Enter your name.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Enter your email.';
    }
    if (!_isValidEmail(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Enter a password.';
    }
    if ((value ?? '').length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirm your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords must match.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await CraveAuthSession.saveSession(
        name: _nameController.text,
        email: _emailController.text,
      );
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
      child: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _IntroFade(
                                controller: _introController,
                                intervalStart: 0,
                                child: const _RegisterBrandMark(),
                              ),
                              const SizedBox(height: 18),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .08,
                                child: const Text(
                                  'Create Your Shield',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.4,
                                    height: 1.05,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .14,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Build your personal shield and take control when cravings hit.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.35,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .22,
                                child: _PremiumInputField(
                                  controller: _nameController,
                                  label: 'Name',
                                  icon: Icons.person_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: _validateName,
                                  onChanged: (_) => _refresh(),
                                ),
                              ),
                              const SizedBox(height: 15),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .28,
                                child: _PremiumInputField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: _validateEmail,
                                  onChanged: (_) => _refresh(),
                                ),
                              ),
                              const SizedBox(height: 15),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .34,
                                child: _PremiumInputField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_rounded,
                                  obscureText: _hidePassword,
                                  textInputAction: TextInputAction.next,
                                  validator: _validatePassword,
                                  onChanged: (_) => _refresh(),
                                  suffix: IconButton(
                                    color: CraveShieldColors.navy,
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(
                                              () => _hidePassword =
                                                  !_hidePassword,
                                            );
                                          },
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .40,
                                child: _PremiumInputField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password',
                                  icon: Icons.verified_user_rounded,
                                  obscureText: _hideConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  validator: _validateConfirmPassword,
                                  onChanged: (_) => _refresh(),
                                  onFieldSubmitted: (_) => _submit(),
                                  suffix: IconButton(
                                    color: CraveShieldColors.navy,
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(
                                              () => _hideConfirmPassword =
                                                  !_hideConfirmPassword,
                                            );
                                          },
                                    icon: Icon(
                                      _hideConfirmPassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .48,
                                child: _GradientShieldButton(
                                  text: 'CREATE MY SHIELD',
                                  enabled: _canSubmit,
                                  isLoading: _isLoading,
                                  onPressed: _submit,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _IntroFade(
                                controller: _introController,
                                intervalStart: .54,
                                child: _OutlineShieldButton(
                                  text: 'I ALREADY HAVE AN ACCOUNT',
                                  enabled: !_isLoading,
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed(CraveLoginScreen.routePath),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const CraveShieldBackButton(),
        ],
      ),
    );
  }
}

class _RegisterBrandMark extends StatelessWidget {
  const _RegisterBrandMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 112,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: .25),
              blurRadius: 18,
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/images/craveshield_logo.svg',
          width: 56,
          height: 56,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PremiumInputField extends StatelessWidget {
  const _PremiumInputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(28);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: CraveShieldColors.blue,
      style: const TextStyle(
        color: CraveShieldColors.ink,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF536D91),
          fontWeight: FontWeight.w800,
        ),
        errorStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        prefixIcon: Icon(icon, color: CraveShieldColors.navy),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: .78),
            width: 1.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Color(0xFF4DEFFF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Color(0xFFFFD1D1),
            width: 1.4,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Color(0xFF4EFF7A),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _GradientShieldButton extends StatefulWidget {
  const _GradientShieldButton({
    required this.text,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final bool enabled;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  State<_GradientShieldButton> createState() => _GradientShieldButtonState();
}

class _GradientShieldButtonState extends State<_GradientShieldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.enabled && !widget.isLoading;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed && isActive ? .985 : 1,
      child: Opacity(
        opacity: isActive ? 1 : .62,
        child: GestureDetector(
          onTapDown: isActive ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: isActive
              ? (_) {
                  setState(() => _pressed = false);
                  widget.onPressed();
                }
              : null,
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF4DEFFF).withValues(alpha: .95),
                width: 1.2,
              ),
              gradient: LinearGradient(
                colors: isActive
                    ? const [
                        Color(0xFF12D9FF),
                        Color(0xFF1677FF),
                        Color(0xFF0D4EA8),
                      ]
                    : [
                        Colors.white.withValues(alpha: .24),
                        Colors.white.withValues(alpha: .14),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4DEFFF).withValues(alpha: .36),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: const Offset(0, 9),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OutlineShieldButton extends StatefulWidget {
  const _OutlineShieldButton({
    required this.text,
    required this.enabled,
    required this.onPressed,
  });

  final String text;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_OutlineShieldButton> createState() => _OutlineShieldButtonState();
}

class _OutlineShieldButtonState extends State<_OutlineShieldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: !widget.enabled
          ? .62
          : _pressed
              ? .72
              : 1,
      child: GestureDetector(
        onTapDown:
            widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed();
              }
            : null,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: .78),
              width: 1.2,
            ),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .65,
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroFade extends StatelessWidget {
  const _IntroFade({
    required this.controller,
    required this.intervalStart,
    required this.child,
  });

  final AnimationController controller;
  final double intervalStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(intervalStart, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

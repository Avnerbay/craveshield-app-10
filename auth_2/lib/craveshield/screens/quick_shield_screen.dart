import 'package:flutter/material.dart';

class QuickShieldScreen extends StatelessWidget {
  const QuickShieldScreen({super.key});
  static const routeName = 'craveQuickShieldScreen';
  static const routePath = '/crave-quick-shield';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03122D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text('QuickShieldScreen - Coming Soon',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

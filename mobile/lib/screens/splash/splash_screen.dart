import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text('روشتة AI', style: theme.textTheme.displayMedium),
            const SizedBox(height: 6),
            Text('مساعد الصيدلية الذكي', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
          ],
        ),
      ),
    );
  }
}

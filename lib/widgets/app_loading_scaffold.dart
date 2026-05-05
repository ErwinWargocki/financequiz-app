import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLoadingScaffold extends StatelessWidget {
  const AppLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.palette(context).bg,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
}

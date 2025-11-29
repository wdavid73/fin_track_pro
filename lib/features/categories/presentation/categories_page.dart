import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Center(
        child: Text('Categories', style: theme.textTheme.headlineMedium),
      ),
    );
  }
}

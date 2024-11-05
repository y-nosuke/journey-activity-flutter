import 'package:flutter/material.dart';

class RouteListScreen extends StatelessWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('経路一覧'),
      ),
      body:
          const Center(child: Text('経路一覧画面', style: TextStyle(fontSize: 32.0))),
    );
  }
}

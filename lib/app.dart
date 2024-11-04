import 'package:flutter/material.dart';

import 'map.dart';
import 'route_list.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  static const _screens = [MapScreen(), RouteListScreen()];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          indicatorColor: Colors.amber,
          selectedIndex: _selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
            NavigationDestination(
                icon: Icon(Icons.route_outlined), label: 'Route'),
          ],
        ));
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text('Realizar Ventas'),
        ),
      ),
    );
  }
}

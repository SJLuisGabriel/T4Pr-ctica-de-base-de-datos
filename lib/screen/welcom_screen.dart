import 'package:flutter/material.dart';

class WelcomScreen extends StatelessWidget {
  const WelcomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Tarea 4: Práctica de base de datos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Ir a la Pantalla de Inicio'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Creada por:',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Luis Gabriel Sanchez Jungo',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Y',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Ricardo Miguel Garcia Noguez',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

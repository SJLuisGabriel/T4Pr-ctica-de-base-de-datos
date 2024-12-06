import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

class SuscripcionesScreen extends StatefulWidget {
  const SuscripcionesScreen({super.key});

  @override
  State<SuscripcionesScreen> createState() => _SuscripcionesScreenState();
}

class _SuscripcionesScreenState extends State<SuscripcionesScreen> {
  String? selectedPlan;

  final String clientId =
      'AQwKZxhHKjUrvxL3pBrLR6MJRxUGT_z60RnXQMRcz7aWjthHWYuC3ykEd_c1oE-hOlC-v_bIRBf9zupl';
  final String secretKey =
      'EOe6UPhOZe8wRBMQSzhx-2yE2UTIkWm8tayd9IjIDPRQA8Dr6wwBfuTB-ND2P9fsI0VUERFA5jUydyRy';
  final String returnURL = "https://www.example.com/success";
  final String cancelURL = "https://www.example.com/cancel";

  // Método para procesar el pago con PayPal
  void _processPayPalPayment() {
    if (selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un plan.'),
        ),
      );
      return;
    }

    // Configura la transacción basada en el plan seleccionado
    String totalAmount = '10';
    String description = '';

    switch (selectedPlan) {
      case 'Básico':
        totalAmount = '9.99';
        description = 'Plan Básico';
        break;
      case 'Premium':
        totalAmount = '19.99';
        description = 'Plan Premium';
        break;
      case 'Empresarial':
        totalAmount = '49.99';
        description = 'Plan Empresarial';
        break;
    }

    // Iniciar el flujo de pago con PayPal
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckout(
        sandboxMode: true,
        clientId: clientId,
        secretKey: secretKey,
        returnURL: returnURL,
        cancelURL: cancelURL,
        transactions: [
          {
            "amount": {
              "total": totalAmount,
              "currency": "USD",
              "details": {
                "subtotal": totalAmount,
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": description,
            "item_list": {
              "items": [
                {
                  "name": description,
                  "quantity": 1,
                  "price": totalAmount,
                  "currency": "USD"
                },
              ],
            }
          }
        ],
        note: "Si tienes alguna duda, contáctanos.",
        onSuccess: (Map params) async {
          print("Pago exitoso: $params");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Pago realizado con éxito!')),
          );
        },
        onError: (error) {
          print("Error: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hubo un error con el pago.')),
          );
        },
        onCancel: () {
          print('Pago cancelado');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El pago fue cancelado.')),
          );
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suscripciones"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona tu plan de suscripción:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: 'Plan Básico',
              subtitle: '\$9.99/mes',
              value: 'Básico',
            ),
            _buildPlanCard(
              title: 'Plan Premium',
              subtitle: '\$19.99/mes',
              value: 'Premium',
            ),
            _buildPlanCard(
              title: 'Plan Empresarial',
              subtitle: '\$49.99/mes',
              value: 'Empresarial',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _processPayPalPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Pagar con PayPal'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        value: value,
        groupValue: selectedPlan,
        onChanged: (value) {
          setState(() {
            selectedPlan = value;
          });
        },
        activeColor: Colors.blueAccent,
      ),
    );
  }
}

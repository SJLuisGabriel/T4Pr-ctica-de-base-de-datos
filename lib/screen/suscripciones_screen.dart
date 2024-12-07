import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:t4bd/screen/services/paymentWeb.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SuscripcionesScreen extends StatefulWidget {
  const SuscripcionesScreen({super.key});

  @override
  State<SuscripcionesScreen> createState() => _SuscripcionesScreenState();
}

class _SuscripcionesScreenState extends State<SuscripcionesScreen> {
  String? selectedPlan;
  String result = "";

  final String clientId =
      'AQwKZxhHKjUrvxL3pBrLR6MJRxUGT_z60RnXQMRcz7aWjthHWYuC3ykEd_c1oE-hOlC-v_bIRBf9zupl';
  final String secretKey =
      'EOe6UPhOZe8wRBMQSzhx-2yE2UTIkWm8tayd9IjIDPRQA8Dr6wwBfuTB-ND2P9fsI0VUERFA5jUydyRy';

  Future<String> _getAccessToken() async {
    final url = Uri.parse("https://api-m.sandbox.paypal.com/v1/oauth2/token");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$secretKey'))}',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Error al obtener token de acceso: ${response.body}');
    }
  }

  Future<void> _createPayPalPayment(
      String accessToken, String totalAmount, String description) async {
    final url =
        Uri.parse("https://api-m.sandbox.paypal.com/v1/payments/payment");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "intent": "sale",
        "payer": {"payment_method": "paypal"},
        "transactions": [
          {
            "amount": {"total": totalAmount, "currency": "USD"},
            "description": description,
          }
        ],
        "redirect_urls": {
          "return_url": "https://example.com/success",
          "cancel_url": "https://example.com/cancel",
        }
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final approvalUrl = data['links']
          .firstWhere((link) => link['rel'] == 'approval_url')['href'];

      // Redirigir al navegador para completar el pago
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebView(
            approvalUrl: approvalUrl,
            onPaymentSuccess: () => _showPaymentResult("success"),
            onPaymentCancel: () => _showPaymentResult("cancel"),
          ),
        ),
      );
    } else {
      throw Exception('Error al crear pago: ${response.body}');
    }
  }

  void _processPayment() async {
    if (selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un plan.')),
      );
      return;
    }

    // Configurar el plan seleccionado
    String totalAmount = '10';
    String description = '';

    switch (selectedPlan) {
      case 'Básico':
        totalAmount = '9.99';
        description = 'Plan Semanal';
        break;
      case 'Premium':
        totalAmount = '19.99';
        description = 'Plan Mensual';
        break;
      case 'Empresarial':
        totalAmount = '49.99';
        description = 'Plan Anual';
        break;
    }

    try {
      final accessToken = await _getAccessToken();
      await _createPayPalPayment(accessToken, totalAmount, description);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error procesando el pago.')),
      );
    }
  }

  void _showPaymentResult(String result) {
    String title = result == "success" ? "Pago Exitoso" : "Pago Cancelado";
    String message = result == "success"
        ? "Tu pago se ha realizado exitosamente."
        : "El pago fue cancelado. Intenta nuevamente.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result == "success" ? Colors.green : Colors.red,
      ),
    );
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
              title: 'Plan Semanal',
              subtitle: '\$9.99/mes',
              value: 'Básico',
            ),
            _buildPlanCard(
              title: 'Plan Mensual',
              subtitle: '\$19.99/mes',
              value: 'Premium',
            ),
            _buildPlanCard(
              title: 'Plan Anual',
              subtitle: '\$49.99/mes',
              value: 'Empresarial',
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _processPayment,
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

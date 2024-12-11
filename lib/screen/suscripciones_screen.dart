import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:t4bd/api/firebase_api.dart';
import 'package:t4bd/firebase/usuarios_firebase.dart';
import 'package:t4bd/screen/services/paymentWeb.dart';
import 'package:t4bd/settings/ThemeProvider.dart';
import 'package:t4bd/settings/user_data_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SuscripcionesScreen extends StatefulWidget {
  const SuscripcionesScreen({super.key});

  @override
  State<SuscripcionesScreen> createState() => _SuscripcionesScreenState();
}

class _SuscripcionesScreenState extends State<SuscripcionesScreen> {
  final FirebaseApi _firebaseApi = FirebaseApi();

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

  Future<void> _updateSubscription() async {
    // Actualizar la suscripción en el provider
    Provider.of<UserDataProvider>(context, listen: false)
        .setSuscripcion(selectedPlan!);

    // Luego, actualizamos la suscripción en Firestore
    final firebaseService = FirebaseService();
    final correo = Provider.of<UserDataProvider>(context, listen: false).correo;
    final updatedData = {'suscripcion': selectedPlan};

    await firebaseService.updateUserByEmail(correo, updatedData);
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
            onPaymentSuccess: () async {
              // Actualizar suscripción
              await _updateSubscription();

              // Mostrar resultado del pago
              _showPaymentResult("success");

              // Enviar notificación
              await _firebaseApi.showNotification(
                "Pago Exitoso",
                "Realizaste tu pago correctamente.",
              );
            },
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
    final firebaseService = FirebaseService();

    try {
      final accessToken = await _getAccessToken();
      await _createPayPalPayment(accessToken, totalAmount, description);

      // Actualizar la suscripción en Firestore
      final correo =
          Provider.of<UserDataProvider>(context, listen: false).correo;
      final updatedData = {
        'suscripcion': selectedPlan,
      };
      await firebaseService.updateUserByEmail(correo, updatedData);
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
    final suscripcion = Provider.of<UserDataProvider>(context).suscripcion;

    bool isEmpresarial = true;
    bool isBasico = true;
    bool isMensual = true;

    if (suscripcion == "ninguna") {
      isEmpresarial = true;
      isBasico = true;
      isMensual = true;
    } else if (suscripcion == "Empresarial") {
      isEmpresarial = false;
      isBasico = true;
      isMensual = true;
    } else if (suscripcion == "Básico") {
      isEmpresarial = true;
      isBasico = false;
      isMensual = true;
    } else if (suscripcion == "Premium") {
      isEmpresarial = true;
      isBasico = true;
      isMensual = false;
    } else {
      isEmpresarial = true;
      isBasico = true;
      isMensual = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            return Text(
              'Suscripciones',
              style: TextStyle(
                fontFamily: themeProvider.currentFont,
              ),
            );
          },
        ),
        centerTitle: true,
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
            if (suscripcion == 'Básico')
              const Text(
                "Actualmente tienes este plan",
                style: TextStyle(color: Colors.red),
              ),
            _buildPlanCard(
                title: 'Plan Semanal',
                subtitle: '\$9.99/semana',
                value: 'Básico',
                isDisabled: isBasico),
            if (suscripcion == 'Premium')
              const Text(
                "Actualmente tienes este plan",
                style: TextStyle(color: Colors.red),
              ),
            _buildPlanCard(
                title: 'Plan Mensual',
                subtitle: '\$19.99/mes',
                value: 'Premium',
                isDisabled: isMensual),
            if (suscripcion == 'Empresarial')
              const Text(
                "Actualmente tienes este plan",
                style: TextStyle(color: Colors.red),
              ),
            _buildPlanCard(
                title: 'Plan Anual',
                subtitle: '\$49.99/año',
                value: 'Empresarial',
                isDisabled: isEmpresarial),
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
    required bool isDisabled,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDisabled
                ? Colors.black
                : Colors.grey, // Cambia el color si está deshabilitado
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDisabled
                ? Colors.black
                : Colors.grey, // Cambia el color si está deshabilitado
          ),
        ),
        value: value,
        groupValue: selectedPlan,
        onChanged: isDisabled
            ? (value) {
                setState(() {
                  selectedPlan = value;
                });
              }
            : null, // Deshabilita la interacción si isDisabled es false
        activeColor: Colors.blueAccent,
      ),
    );
  }
}

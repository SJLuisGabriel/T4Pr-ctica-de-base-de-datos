import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String approvalUrl;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentCancel;

  const PaymentWebView({
    Key? key,
    required this.approvalUrl,
    required this.onPaymentSuccess,
    required this.onPaymentCancel,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Verificar URLs específicas para éxito o cancelación
            if (url.contains("success")) {
              widget.onPaymentSuccess();
              Navigator.pop(context);
            } else if (url.contains("cancel")) {
              widget.onPaymentCancel();
              Navigator.pop(context);
            }
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false; // Detener indicador de carga cuando termine
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar pago'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentCancel(); // Enviar mensaje de cancelación
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(), // Indicador de carga
            ),
        ],
      ),
    );
  }
}

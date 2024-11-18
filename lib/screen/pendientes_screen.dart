import 'package:flutter/material.dart';

class PendientesScreen extends StatefulWidget {
  const PendientesScreen({super.key});

  @override
  State<PendientesScreen> createState() => _PendientesScreenState();
}

class _PendientesScreenState extends State<PendientesScreen> {
  final String ventaTitle = 'Venta Pendiente';
  final List<Map<String, dynamic>> pendientes = [];

  @override
  void initState() {
    super.initState();
    pendientes.addAll([
      {
        'title': ventaTitle,
        'name': 'Carlos Rodríguez',
        'date': '01/11/2024',
        'description': 'Venta de productos pendientes A',
        'status': 'Por Cumplir',
        'contact': 'Carlos Rodríguez',
        'items': ['Producto A1', 'Producto A2', 'Producto A3'],
      },
      {
        'title': ventaTitle,
        'name': 'Laura Martínez',
        'date': '02/11/2024',
        'description': 'Venta de productos pendientes B',
        'status': 'En Proceso',
        'contact': 'Laura Martínez',
        'items': ['Producto B1', 'Producto B2'],
      },
    ]);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'En Proceso':
        return Colors.yellow[600]!;
      case 'Por Cumplir':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Función para mostrar el modal de detalles de la venta
  void _showPendingDetails(Map<String, dynamic> venta, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalle de Venta Pendiente'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${venta['name']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Fecha: ${venta['date']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Contacto: ${venta['contact']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Descripción: ${venta['description']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Estado: ${venta['status']}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('Productos Pendientes:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...venta['items']
                          .map((item) => Text('- $item',
                              style: const TextStyle(fontSize: 14)))
                          .toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Pendientes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pendientes.length,
        itemBuilder: (context, index) {
          final venta = pendientes[index];
          Color color = getStatusColor(venta['status']);
          return GestureDetector(
            onTap: () => _showPendingDetails(venta, index),
            child: SaleCard(
              title: '${venta['title']}: ${venta['date']}',
              description: venta['description'],
              status: venta['status'],
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class SaleCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final Color color;

  const SaleCard({
    Key? key,
    required this.title,
    required this.description,
    required this.status,
    required this.color,
  }) : super(key: key);

  // Función para obtener el icono según el estado
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'En Proceso':
        return Icons.hourglass_empty;
      case 'Por Cumplir':
        return Icons.cancel;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),
                  Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              getStatusIcon(status),
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

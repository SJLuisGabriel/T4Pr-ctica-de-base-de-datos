import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorialPedidosScreen extends StatefulWidget {
  const HistorialPedidosScreen({Key? key}) : super(key: key);

  @override
  State<HistorialPedidosScreen> createState() => _HistorialPedidosScreenState();
}

class _HistorialPedidosScreenState extends State<HistorialPedidosScreen> {
  final List<Map<String, dynamic>> pedidos = [];
   final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Formato deseado

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  Future<void> _fetchPedidos() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('pedidos').get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final productosSnapshot =
            await doc.reference.collection('productos_pedido').get();
        final productos = productosSnapshot.docs
            .map((productoDoc) => productoDoc.data())
            .toList();

        pedidos.add({
          'titulo': data['titulo'] ?? 'Sin título',
          'estatus': data['estatus'] ?? 'Desconocido',
          'fecha_agendada': (data['fecha_agendada'] as Timestamp?) != null
              ? dateFormat
                  .format((data['fecha_agendada'] as Timestamp).toDate())
              : 'Sin fecha',
          'descripcion': data['descripcion'] ?? 'Sin descripción',
          'productos': productos,
        });
      }

      setState(() {});
    } catch (e) {
      print('Error fetching pedidos: $e');
    }
  }

  Color? getStatusColor(String status) {
    switch (status) {
      case 'Completado':
        return Colors.green[700];
      case 'Pendiente':
        return Colors.yellow[600]!;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showPedidoDetails(Map<String, dynamic> pedido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            pedido['titulo'],
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Fecha: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(pedido['fecha_agendada'],
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Estatus: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(pedido['estatus'],
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Descripción: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(pedido['descripcion'],
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Productos:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...pedido['productos'].map<Widget>(
                    (producto) => Text(
                      '- ${producto['nombre']} (Cantidad: ${producto['cantidad']}, Precio: \$${producto['precio']})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Histórico de pedidos'),
      ),
      body: pedidos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final color = getStatusColor(pedido['estatus']);

                return GestureDetector(
                  onTap: () => _showPedidoDetails(pedido),
                  child: Card(
                    color: color?.withOpacity(0.1),
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
                                  pedido['titulo'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(pedido['descripcion']),
                                const SizedBox(height: 8),
                                Text(
                                  pedido['estatus'],
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.description,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

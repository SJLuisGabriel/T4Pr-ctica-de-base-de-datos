import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:t4bd/screen/detalle_pedido_screen.dart';

class PendientesScreen extends StatelessWidget {
  const PendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lista de Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('estatus', isEqualTo: 'Pendiente')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar pedidos: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay pedidos pendientes.'),
            );
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedidoDoc = pedidos[index];
              final pedido = pedidoDoc.data() as Map<String, dynamic>;
              final titulo = pedido['titulo'] ?? 'Sin título';
              final estatus = pedido['estatus'] ?? 'Desconocido';
              final descripcion = pedido['descripcion'] ?? 'Sin descripción';
              final fechaAgendada = pedido['fecha_agendada'] as Timestamp?;

              // Convertir marca de tiempo a formato legible
              final fechaFormatted = fechaAgendada != null
                  ? DateFormat('dd/MM/yyyy').format(fechaAgendada.toDate())
                  : 'Sin fecha';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estatus: $estatus'),
                      Text('Descripción: $descripcion'),
                      Text('Fecha Agendada: $fechaFormatted'),
                    ],
                  ),
                  leading: const Icon(Icons.assignment),
                  onTap: () {
                    // Navegar a la pantalla de detalles del pedido
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetallePedidoScreen(pedidoId: pedidoDoc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

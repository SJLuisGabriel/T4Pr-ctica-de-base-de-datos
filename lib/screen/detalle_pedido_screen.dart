import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetallePedidoScreen extends StatefulWidget {
  final String pedidoId;

  const DetallePedidoScreen({super.key, required this.pedidoId});

  @override
  _DetallePedidoScreenState createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  String? selectedEstatus;
  final List<String> estatusOptions = ['Pendiente', 'Cancelado', 'Completado'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalle del Pedido'),
      ),
      body: Column(
        children: [
          // Estatus Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .doc(widget.pedidoId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar pedido: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('El pedido no existe.'),
                  );
                }

                final pedido = snapshot.data!.data() as Map<String, dynamic>;
                final estatusActual = pedido['estatus'] ?? 'Pendiente';

                // Asegurarse de que el valor inicial sea válido
                if (selectedEstatus == null ||
                    !estatusOptions.contains(estatusActual)) {
                  selectedEstatus = estatusActual;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estatus del Pedido:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      dropdownColor: const Color.fromARGB(255, 0, 129, 114),
                      borderRadius: BorderRadius.circular(8),
                      menuWidth: 152,
                      value: selectedEstatus,
                      onChanged: (value) {
                        setState(() {
                          selectedEstatus = value!;
                        });

                        // Actualizar el estatus en Firestore
                        FirebaseFirestore.instance
                            .collection('pedidos')
                            .doc(widget.pedidoId)
                            .update({'estatus': value});
                      },
                      items: estatusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            color: Color.fromARGB(255, 0, 105, 92),
            thickness: 5,
          ),
          // Lista de productos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .doc(widget.pedidoId)
                  .collection('productos_pedido')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar productos: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay productos en este pedido.'),
                  );
                }

                final productos = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto =
                        productos[index].data() as Map<String, dynamic>;
                    final nombre = producto['nombre'] ?? 'Sin nombre';
                    final categoria = producto['categoria'] ?? 'Sin categoría';
                    final cantidad = producto['cantidad'] ?? 0;
                    final precio = producto['precio'] ?? 0.0;
                    final imagen = producto['imagen'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: imagen.isNotEmpty
                            ? Image.network(
                                imagen,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(
                          nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Categoría: $categoria'),
                            Text('Cantidad: $cantidad'),
                            Text('Precio: \$${precio.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

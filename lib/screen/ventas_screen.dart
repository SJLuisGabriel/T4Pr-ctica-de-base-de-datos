import 'package:flutter/material.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  // Variables para las propiedades de las ventas
  final String ventaTitle = 'Venta Del Dia';
  final String descripcionVentaA = 'Venta de productos A';
  final String estadoVentaA = 'En Proceso';
  final String contactoVentaA = 'Juan Pérez';
  final String nombreVentaA = 'Juan Pérez';
  final String fechaVentaA = '01/11/2024';
  final List<String> itemsVentaA = [
    'Producto A1',
    'Producto A2',
    'Producto A3'
  ];

  final String descripcionVentaB = 'Venta de productos B';
  final String estadoVentaB = 'Cumplida';
  final String contactoVentaB = 'María López';
  final String nombreVentaB = 'María López';
  final String fechaVentaB = '02/11/2024';
  final List<String> itemsVentaB = ['Producto B1', 'Producto B2'];

  final String descripcionVentaC = 'Venta de productos C';
  final String estadoVentaC = 'Por Cumplir';
  final String contactoVentaC = 'Luis García';
  final String nombreVentaC = 'Luis García';
  final String fechaVentaC = '03/11/2024';
  final List<String> itemsVentaC = [
    'Producto C1',
    'Producto C2',
    'Producto C3'
  ];

  // Listado de ventas (ejemplo estático)
  final List<Map<String, dynamic>> ventas = [];

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de ventas con las variables
    ventas.addAll([
      {
        'title': ventaTitle,
        'name': nombreVentaA,
        'date': fechaVentaA,
        'description': descripcionVentaA,
        'status': estadoVentaA,
        'contact': contactoVentaA,
        'items': itemsVentaA,
      },
      {
        'title': ventaTitle,
        'name': nombreVentaB,
        'date': fechaVentaB,
        'description': descripcionVentaB,
        'status': estadoVentaB,
        'contact': contactoVentaB,
        'items': itemsVentaB,
      },
      {
        'title': ventaTitle,
        'name': nombreVentaC,
        'date': fechaVentaC,
        'description': descripcionVentaC,
        'status': estadoVentaC,
        'contact': contactoVentaC,
        'items': itemsVentaC,
      },
    ]);
  }

  // Función que retorna el color basado en el estado
  Color getStatusColor(String status) {
    switch (status) {
      case 'Cumplida':
        return Colors.green;
      case 'En Proceso':
        return Colors.yellow[600]!;
      case 'Por Cumplir':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Función Para Mostrar El Modal
  void _showSaleDetails(Map<String, dynamic> venta, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalle De Venta'),
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
                      const Text('Productos Comprados:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...venta['items']
                          .map((item) => Text('- $item',
                              style: const TextStyle(fontSize: 14)))
                          .toList(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            // Cambiar el estado de la venta
                            if (venta['status'] == 'En Proceso') {
                              venta['status'] = 'Cumplida';
                            } else if (venta['status'] == 'Por Cumplir') {
                              venta['status'] = 'En Proceso';
                            } else if (venta['status'] == 'Cumplida') {
                              venta['status'] = 'Por Cumplir';
                            }
                          });

                          // Actualizar el estado de la venta en la lista principal
                          setState(() {
                            // Cambia el estado en la lista principal
                            if (ventas[index]['status'] == 'En Proceso') {
                              ventas[index]['status'] = 'Cumplida';
                            } else if (ventas[index]['status'] ==
                                'Por Cumplir') {
                              ventas[index]['status'] = 'En Proceso';
                            } else if (ventas[index]['status'] == 'Cumplida') {
                              ventas[index]['status'] = 'Por Cumplir';
                            }
                          });
                        },
                        child: const Text('Cambiar Estado'),
                      ),
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
        title: const Text('Listado de Ventas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: ventas.length,
        itemBuilder: (context, index) {
          final venta = ventas[index];
          Color color = getStatusColor(
              venta['status']); // Obtener el color según el estado
          return GestureDetector(
            onTap: () => _showSaleDetails(venta, index),
            child: SaleCard(
              title: venta['title'] + ': ${venta['date']}',
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
      case 'Cumplida':
        return Icons.check_circle; // Icono de venta cumplida
      case 'En Proceso':
        return Icons.hourglass_empty; // Icono de venta en proceso
      case 'Por Cumplir':
        return Icons.cancel; // Icono de venta por cumplir
      default:
        return Icons
            .error; // Icono por defecto en caso de un estado no reconocido
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

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  int itemsInCart = 0; // Cantidad Total De Artículos En El Carrito
  String selectedCategory = ''; // Categoría Seleccionada Actualmente
  List<String> products = []; // Lista De Productos Filtrados Por Categoría
  Map<String, int> cartItems =
      {}; // Mapa Que Almacena Los Productos Y Su Cantidad
  List<String> categories = [
    'Anillos',
    'Pulseras',
    'Collares'
  ]; // Categorías Disponibles
  Map<String, List<String>> productList = {
    // Mapa Que Contiene Los Productos Por Categoría
    'Anillos': ['Anillo de Plata', 'Anillo de Oro Laminado'],
    'Pulseras': ['Pulsera de Plata', 'Pulsera de Oro Laminado'],
    'Collares': ['Collar de Plata', 'Collar de Oro Laminado'],
  };

  String customerName = ''; // Nombre Del Cliente
  String customerContact = ''; // Contacto Del Cliente
  DateTime? selectedDate; // Fecha seleccionada

  // Función Para Agregar Un Producto Al Carrito
  void addToCart(String product) {
    setState(() {
      itemsInCart++;
      if (cartItems.containsKey(product)) {
        cartItems[product] = cartItems[product]! + 1;
      } else {
        cartItems[product] = 1;
      }
    });
  }

  // Función Para Remover Un Producto Del Carrito
  void removeFromCart(String product) {
    setState(() {
      if (cartItems.containsKey(product)) {
        itemsInCart--;
        if (cartItems[product] == 1) {
          cartItems.remove(product);
        } else {
          cartItems[product] = cartItems[product]! - 1;
        }
      }
    });
  }

  // Función Para Mostrar El Modal Del Carrito Con Los Productos
  void showCartModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Productos en el Carrito'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: cartItems.entries.map((entry) {
                    return ListTile(
                      title: Text('${entry.key} x${entry.value}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setModalState(() {
                            removeFromCart(entry.key);
                          });
                        },
                      ),
                    );
                  }).toList(),
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

  // Función Para Seleccionar La Fecha
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nueva Venta'),
        actions: [
          badges.Badge(
            badgeContent: Text(
              itemsInCart.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: showCartModal, // Muestra El Modal Del Carrito
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Cliente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  customerName = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  customerContact = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Contacto del Cliente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  customerName = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fecha de Venta:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: selectedDate == null
                          ? 'Seleccionar Fecha'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text('Seleccionar Categoría de Producto'),
                value: selectedCategory.isEmpty ? null : selectedCategory,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCategory = newValue;
                      products = productList[selectedCategory] ?? [];
                    });
                  }
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (products.isNotEmpty) ...[
                const Text(
                  'Seleccionar Producto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(products[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            addToCart(products[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Venta registrada para $customerName el ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
                    ),
                  );
                },
                child: const Text('Registrar Venta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

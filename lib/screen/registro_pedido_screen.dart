import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class RegistroPedidoScreen extends StatefulWidget {
  const RegistroPedidoScreen({super.key});

  @override
  State<RegistroPedidoScreen> createState() => _RegistroPedidoScreenState();
}

class _RegistroPedidoScreenState extends State<RegistroPedidoScreen> {
  int itemsInCart = 0;
  String selectedCategory = '';
  Map<String, int> cartItems = {};

  final List<String> categories = ['Anillos', 'Pulseras', 'Collares', 'Aretes'];
  Map<String, List<Map<String, dynamic>>> productList = {};

  @override
  void initState() {
    super.initState();
    fetchProducts();
    if (categories.isNotEmpty) {
      selectedCategory = categories[0];
    }
  }

  Future<void> fetchProducts() async {
    try {
      Map<String, List<Map<String, dynamic>>> fetchedProductList = {};

      for (final category in categories) {
        final productsSnapshot = await FirebaseFirestore.instance
            .collection('productos')
            .where('categoria', isEqualTo: category)
            .get();

        fetchedProductList[category] = productsSnapshot.docs.map((doc) {
          return {
            ...doc.data(),
            'id': doc.id,
          };
        }).toList();
      }

      setState(() {
        productList = fetchedProductList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  void addToCart(String product) {
    setState(() {
      itemsInCart++;
      cartItems[product] = (cartItems[product] ?? 0) + 1;
    });
  }

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

  void showCartModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Productos en el Carrito'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: cartItems.entries.map((entry) {
                return ListTile(
                  title: Text('${entry.key} x${entry.value}'),
                  leading: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => removeFromCart(entry.key)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => addToCart(entry.key)),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
        title: const Text('Registrar Pedido'),
        actions: [
          badges.Badge(
            badgeContent: Text(
              itemsInCart.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: showCartModal,
            ),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryCarousel(),
                const SizedBox(height: 10),
                _buildProductGrid(),
              ],
            ),
    );
  }

  Widget _buildCategoryCarousel() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: selectedCategory == category ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedCategory == category ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2.3 / 4, // Ajustar relación de aspecto para imágenes más grandes
        ),
        itemCount: productList[selectedCategory]?.length ?? 0,
        itemBuilder: (context, index) {
          final product = productList[selectedCategory]![index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 25, // Hacer que la imagen ocupe más espacio
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product['imagen_url'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['nombre'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Precio: \$${product['precio']}'),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () => addToCart(product['nombre']),
              child: const Text('Agregar al Carrito'),
            ),
          ),
        ],
      ),
    );
  }
}


  // int itemsInCart = 0; // Cantidad Total De Artículos En El Carrito
  // String selectedCategory = ''; // Categoría Seleccionada Actualmente
  // List<String> products = []; // Lista De Productos Filtrados Por Categoría
  // Map<String, int> cartItems =
  //     {}; // Mapa Que Almacena Los Productos Y Su Cantidad
  // List<String> categories = [
  //   'Anillos',
  //   'Pulseras',
  //   'Collares'
  // ]; // Categorías Disponibles
  // Map<String, List<String>> productList = {
  //   // Mapa Que Contiene Los Productos Por Categoría
  //   'Anillos': ['Anillo de Plata', 'Anillo de Oro Laminado'],
  //   'Pulseras': ['Pulsera de Plata', 'Pulsera de Oro Laminado'],
  //   'Collares': ['Collar de Plata', 'Collar de Oro Laminado'],
  // };

  // String customerName = ''; // Nombre Del Cliente
  // String customerContact = ''; // Contacto Del Cliente
  // DateTime? selectedDate; // Fecha seleccionada

  // // Función Para Agregar Un Producto Al Carrito
  // void addToCart(String product) {
  //   setState(() {
  //     itemsInCart++;
  //     if (cartItems.containsKey(product)) {
  //       cartItems[product] = cartItems[product]! + 1;
  //     } else {
  //       cartItems[product] = 1;
  //     }
  //   });
  // }

  // // Función Para Remover Un Producto Del Carrito
  // void removeFromCart(String product) {
  //   setState(() {
  //     if (cartItems.containsKey(product)) {
  //       itemsInCart--;
  //       if (cartItems[product] == 1) {
  //         cartItems.remove(product);
  //       } else {
  //         cartItems[product] = cartItems[product]! - 1;
  //       }
  //     }
  //   });
  // }

  // // Función Para Mostrar El Modal Del Carrito Con Los Productos
  // void showCartModal() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Productos en el Carrito'),
  //         content: StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setModalState) {
  //             return SizedBox(
  //               width: double.maxFinite,
  //               child: ListView(
  //                 shrinkWrap: true,
  //                 children: cartItems.entries.map((entry) {
  //                   return ListTile(
  //                     title: Text('${entry.key} x${entry.value}'),
  //                     trailing: IconButton(
  //                       icon: const Icon(Icons.remove_circle_outline),
  //                       onPressed: () {
  //                         setModalState(() {
  //                           removeFromCart(entry.key);
  //                         });
  //                       },
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cerrar'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // // Función Para Seleccionar La Fecha
  // Future<void> selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Registrar pedido'),
  //       actions: [
  //         badges.Badge(
  //           badgeContent: Text(
  //             itemsInCart.toString(),
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //           position: badges.BadgePosition.topEnd(top: 0, end: 3),
  //           child: IconButton(
  //             icon: const Icon(Icons.shopping_cart),
  //             onPressed: showCartModal, // Muestra El Modal Del Carrito
  //           ),
  //         ),
  //       ],
  //     ),
  //     resizeToAvoidBottomInset: true,
  //     body: SingleChildScrollView(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Información del Cliente',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 10),
  //             TextField(
  //               onChanged: (value) {
  //                 customerName = value;
  //               },
  //               decoration: const InputDecoration(
  //                 labelText: 'Nombre del Cliente',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             TextField(
  //               onChanged: (value) {
  //                 customerContact = value;
  //               },
  //               decoration: const InputDecoration(
  //                 labelText: 'Contacto del Cliente',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             TextField(
  //               onChanged: (value) {
  //                 customerName =
  //                     value; // Cambiar esto si necesitas otra variable
  //               },
  //               decoration: const InputDecoration(
  //                 labelText: 'Descripción',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             const Text(
  //               'Fecha de Venta:',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 10),
  //             GestureDetector(
  //               onTap: () => selectDate(context),
  //               child: AbsorbPointer(
  //                 child: TextField(
  //                   decoration: InputDecoration(
  //                     labelText: selectedDate == null
  //                         ? 'Seleccionar Fecha'
  //                         : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
  //                     border: const OutlineInputBorder(),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             DropdownButton<String>(
  //               hint: const Text('Seleccionar Categoría de Producto'),
  //               value: selectedCategory.isEmpty ? null : selectedCategory,
  //               onChanged: (String? newValue) {
  //                 if (newValue != null) {
  //                   setState(() {
  //                     selectedCategory = newValue;
  //                     products = productList[selectedCategory] ?? [];
  //                   });
  //                 }
  //               },
  //               items: categories.map<DropdownMenuItem<String>>((String value) {
  //                 return DropdownMenuItem<String>(
  //                   value: value,
  //                   child: Text(value),
  //                 );
  //               }).toList(),
  //             ),
  //             const SizedBox(height: 20),
  //             if (products.isNotEmpty) ...[
  //               const Text(
  //                 'Seleccionar Producto',
  //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 10),
  //               Container(
  //                 height: 200, // Ajusta esta altura según tus necesidades
  //                 child: ListView.builder(
  //                   itemCount: products.length,
  //                   itemBuilder: (context, index) {
  //                     return ListTile(
  //                       title: Text(products[index]),
  //                       trailing: IconButton(
  //                         icon: const Icon(Icons.add),
  //                         onPressed: () {
  //                           addToCart(products[index]);
  //                         },
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //             const SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text(
  //                         'Venta registrada para $customerName el ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
  //                   ),
  //                 );
  //               },
  //               child: const Text('Registrar Venta'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }


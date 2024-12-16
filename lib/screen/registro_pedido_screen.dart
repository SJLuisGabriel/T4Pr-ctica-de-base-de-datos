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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: Text(
                'Productos en el Carrito',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: cartItems.entries.map((entry) {
                    return ListTile(
                      title: Text('${entry.key} x${entry.value}'),
                      leading: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setModalState(() {
                            removeFromCart(entry.key);
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setModalState(() {
                            addToCart(entry.key);
                          });
                        },
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showOrderFormModal();
                  },
                  child: const Text('Realizar Pedido'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showOrderFormModal() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    DateTime? orderDate;
    String description = '';
    final TextEditingController dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles del Pedido',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su nombre';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha del Pedido',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          orderDate = selectedDate;
                          dateController.text =
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                        });
                      }
                    },
                    controller: dateController,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese una descripción';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            try {
                              // Crear el documento del pedido en Firestore
                              final pedidoRef = await FirebaseFirestore.instance
                                  .collection('pedidos')
                                  .add({
                                'titulo': name,
                                'fecha_agendada': orderDate != null
                                    ? Timestamp.fromDate(orderDate!)
                                    : FieldValue.serverTimestamp(),
                                'descripcion': description,
                                'estatus': 'Pendiente',
                              });

                              // Registrar productos como subdocumentos en la subcolección "productos"
                              for (final entry in cartItems.entries) {
                                final productName = entry.key;
                                final productQuantity = entry.value;

                                // Obtener información adicional del producto
                                final productInfo = productList.values
                                    .expand((list) => list)
                                    .firstWhere(
                                      (product) =>
                                          product['nombre'] == productName,
                                      orElse: () => {},
                                    );

                                await pedidoRef
                                    .collection('productos_pedido')
                                    .add({
                                  'nombre': productName,
                                  'cantidad': productQuantity,
                                  'precio': productInfo['precio'] ?? 0,
                                  'categoria': productInfo['categoria'] ??
                                      'Sin categoría',
                                  'imagen': productInfo['imagen_url'],
                                });
                              }

                              // Limpiar el carrito y mostrar confirmación
                              setState(() {
                                cartItems.clear();
                                itemsInCart = 0;
                              });

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Pedido registrado con éxito')),
                              );
                            } catch (e) {
                              // Manejar errores de Firestore
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error al registrar el pedido: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Enviar Pedido'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
                const SizedBox(height: 10),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: selectedCategory == category
                    ? const Color.fromARGB(255, 0, 105, 92)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedCategory == category
                        ? Colors.white
                        : Colors.black,
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
          childAspectRatio:
              2.3 / 4, // Ajustar relación de aspecto para imágenes más grandes
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
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

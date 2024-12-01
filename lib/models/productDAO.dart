// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProductDAO {
  int? idProducto;
  String? nombre;
  String? categoria;
  String? descripcion;
  String? imagen;
  int? precio;

  ProductDAO({
    this.idProducto,
    this.nombre,
    this.categoria,
    this.descripcion,
    this.imagen,
    this.precio,
  });

  factory ProductDAO.fromMap(Map<String, dynamic> product) {
    return ProductDAO(
      idProducto: product['idProducto'],
      nombre: product['nombre'],
      categoria: product['categoria'],
      descripcion: product['descripcion'],
      imagen: product['imagen'],
      precio: product['precio'],
    );
  }
}

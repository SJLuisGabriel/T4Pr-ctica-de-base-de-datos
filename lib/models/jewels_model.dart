class JewelsModel {
  int? idJoya;
  String? nombre;
  String? descripcion;
  String? categoria;
  String? precio;
  String? stock;
  String? fechaAgregado;

  JewelsModel({
    this.idJoya,
    this.nombre,
    this.descripcion,
    this.categoria,
    this.precio,
    this.stock,
    this.fechaAgregado,
  });

  // factory JewelsModel.fromMap(Map<String, dynamic> joyas){
  //   return JewelsModel(
  //     id: joyas['id'],
  //     nombre: joyas['nombre'],
  //     descripcion: joyas['descripcion'],
  //     categoria: joyas['categoria'],
  //     precio: joyas['precio'],
  //     stock: joyas['stock'],
  //     fechaAgregado: joyas['fecha_agregado']
  //   );
  // }
}

class OrderModel {
  int? idOrden;
  int? idCliente;
  String? titulo;
  String? fechaAgendada;
  String? estatus;
  String? notas;
  int? cantidad;

  OrderModel({
    this.idOrden,
    this.idCliente,
    this.titulo,
    this.fechaAgendada,
    this.estatus,
    this.notas,
    this.cantidad
  });
}

class Cita {
  int? idcita; // opcional
  String lugar;
  String fecha;
  String hora;
  String anotaciones;
  int idpersona;

  Cita({
    this.idcita, // debe ser opcional
    required this.lugar,
    required this.fecha,
    required this.hora,
    required this.anotaciones,
    required this.idpersona,
  });

  Map<String, dynamic> toJSON() {
    return {
      'LUGAR': lugar,
      'FECHA': fecha,
      'HORA': hora,
      'ANOTACIONES': anotaciones,
      'IDPERSONA': idpersona,
    };
  }
}

class Persona {
  int? idpersona; // Nullable, SQLite asignará el valor
  String nombre;
  String telefono;

  Persona({
    this.idpersona,
    required this.nombre,
    required this.telefono,
  });

  Map<String, dynamic> toJSON() {
    return {
      'nombre': nombre,
      'telefono': telefono,
    };
  }
}

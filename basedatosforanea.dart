import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'persona.dart';
import 'cita.dart';

class DB {
  static Future<Database> conectarDB() async {
    return openDatabase(
      join(await getDatabasesPath(), "ejercicio2.db"),
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE PERSONA(
            IDPERSONA INTEGER PRIMARY KEY AUTOINCREMENT,
            NOMBRE TEXT,
            TELEFONO TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE CITA(
            IDCITA INTEGER PRIMARY KEY AUTOINCREMENT,
            LUGAR TEXT,
            FECHA TEXT,
            HORA TEXT,
            ANOTACIONES TEXT,
            IDPERSONA INTEGER,
            FOREIGN KEY(IDPERSONA) REFERENCES PERSONA(IDPERSONA)
              ON DELETE CASCADE
              ON UPDATE CASCADE
          )
        """);
      },
    );
  }

  static Future<int> insertarPersona(Persona p) async {
    final db = await conectarDB();
    return db.insert("PERSONA", p.toJSON());
  }

  static Future<int> insertarCita(Cita c) async {
    final db = await conectarDB();
    return db.insert("CITA", c.toJSON());
  }

  static Future<List<Map<String, dynamic>>> listarPersonas() async {
    final db = await conectarDB();
    return db.query("PERSONA");
  }

  static Future<List<Map<String, dynamic>>> listarCitas() async {
    final db = await conectarDB();
    return db.query("CITA");
  }
}

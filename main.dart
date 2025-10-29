import 'package:flutter/material.dart';
import 'basedatosforanea.dart';
import 'persona.dart';
import 'cita.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PrincipalApp(),
    theme: ThemeData(
      colorSchemeSeed: Colors.deepPurple,
      useMaterial3: true,
    ),
  ));
}

class PrincipalApp extends StatefulWidget {
  @override
  State<PrincipalApp> createState() => _PrincipalAppState();
}

class _PrincipalAppState extends State<PrincipalApp> {
  int _index = 0;

  final List<Widget> _pages = [
    PersonasPage(),
    CitasPage(),
    HoyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Citas y Personas"),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent.shade100,
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int idx) {
          setState(() => _index = idx);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Personas'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Citas'),
          NavigationDestination(icon: Icon(Icons.today), label: 'Hoy'),
        ],
      ),
    );
  }
}

//---------------- PERSONAS ----------------
class PersonasPage extends StatefulWidget {
  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  List<Persona> _personas = [];
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();

  Future<void> _cargarPersonas() async {
    final datos = await DB.listarPersonas();
    setState(() {
      _personas = datos
          .map((e) => Persona(
        idpersona: e['IDPERSONA'] as int,
        nombre: e['NOMBRE'] as String,
        telefono: e['TELEFONO'] as String,
      ))
          .toList();
    });
  }

  Future<void> _agregarPersona() async {
    if (_nombreCtrl.text.isEmpty || _telCtrl.text.isEmpty) return;

    await DB.insertarPersona(Persona(
      nombre: _nombreCtrl.text,
      telefono: _telCtrl.text,
    ));

    _nombreCtrl.clear();
    _telCtrl.clear();
    _cargarPersonas();
    Navigator.pop(context);
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Agregar Persona"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nombreCtrl, decoration: InputDecoration(labelText: "Nombre")),
            TextField(
                controller: _telCtrl, decoration: InputDecoration(labelText: "Teléfono")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          ElevatedButton(onPressed: _agregarPersona, child: Text("Guardar")),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarPersonas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _personas.isEmpty
          ? Center(child: Text("No hay personas registradas"))
          : ListView.builder(
        itemCount: _personas.length,
        itemBuilder: (ctx, i) {
          final p = _personas[i];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade200,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(p.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Teléfono: ${p.telefono}"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple.shade100,
      ),
    );
  }
}

//---------------- CITAS ----------------
class CitasPage extends StatefulWidget {
  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  List<Cita> _citas = [];
  List<Persona> _personas = [];
  Persona? _personaSeleccionada;

  final TextEditingController _lugarCtrl = TextEditingController();
  final TextEditingController _fechaCtrl = TextEditingController();
  final TextEditingController _horaCtrl = TextEditingController();
  final TextEditingController _anotacionesCtrl = TextEditingController();

  Future<void> _cargarDatos() async {
    final datosC = await DB.listarCitas();
    final datosP = await DB.listarPersonas();

    setState(() {
      _personas = datosP
          .map((e) => Persona(
        idpersona: e['IDPERSONA'] as int,
        nombre: e['NOMBRE'] as String,
        telefono: e['TELEFONO'] as String,
      ))
          .toList();

      _citas = datosC
          .map((e) => Cita(
        idcita: e['IDCITA'] as int,
        lugar: e['LUGAR'] as String,
        fecha: e['FECHA'] as String,
        hora: e['HORA'] as String,
        anotaciones: e['ANOTACIONES'] as String,
        idpersona: e['IDPERSONA'] as int,
      ))
          .toList();
    });
  }

  Future<void> _agregarCita() async {
    if (_personaSeleccionada == null ||
        _lugarCtrl.text.isEmpty ||
        _fechaCtrl.text.isEmpty ||
        _horaCtrl.text.isEmpty) return;

    await DB.insertarCita(Cita(
      lugar: _lugarCtrl.text,
      fecha: _fechaCtrl.text, // asegúrate que sea yyyy-MM-dd
      hora: _horaCtrl.text,
      anotaciones: _anotacionesCtrl.text,
      idpersona: _personaSeleccionada!.idpersona!,
    ));

    _cargarDatos();
    Navigator.pop(context);
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Agregar Cita"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Persona>(
                value: _personaSeleccionada,
                hint: Text("Seleccione una persona"),
                items: _personas.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.nombre),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _personaSeleccionada = val),
              ),
              TextField(controller: _lugarCtrl, decoration: InputDecoration(labelText: "Lugar")),
              TextField(controller: _fechaCtrl, decoration: InputDecoration(labelText: "Fecha (yyyy-MM-dd)")),
              TextField(controller: _horaCtrl, decoration: InputDecoration(labelText: "Hora")),
              TextField(controller: _anotacionesCtrl, decoration: InputDecoration(labelText: "Anotaciones")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          ElevatedButton(onPressed: _agregarCita, child: Text("Guardar")),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _citas.isEmpty
          ? Center(child: Text("No hay citas registradas"))
          : ListView.builder(
        itemCount: _citas.length,
        itemBuilder: (ctx, i) {
          final c = _citas[i];
          final persona = _personas.firstWhere(
                  (p) => p.idpersona == c.idpersona,
              orElse: () => Persona(nombre: "Desconocido", telefono: ""));
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              title: Text("${c.lugar} - ${c.fecha} ${c.hora}"),
              subtitle: Text("Persona: ${persona.nombre}\n${c.anotaciones}"),
              leading: Icon(Icons.event_note, color: Colors.deepPurple),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple.shade100,
      ),
    );
  }
}

//---------------- HOY ----------------
class HoyPage extends StatefulWidget {
  @override
  State<HoyPage> createState() => _HoyPageState();
}

class _HoyPageState extends State<HoyPage> {
  List<Cita> _citasHoy = [];
  List<Persona> _personas = [];

  Future<void> _cargarCitasHoy() async {
    final datosC = await DB.listarCitas();
    final datosP = await DB.listarPersonas();

    setState(() {
      _personas = datosP
          .map((e) => Persona(
        idpersona: e['IDPERSONA'] as int,
        nombre: e['NOMBRE'] as String,
        telefono: e['TELEFONO'] as String,
      ))
          .toList();

      final hoy = DateTime.now();
      final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);

      _citasHoy = datosC.map((e) => Cita(
        idcita: e['IDCITA'] as int,
        lugar: e['LUGAR'] as String,
        fecha: e['FECHA'] as String,
        hora: e['HORA'] as String,
        anotaciones: e['ANOTACIONES'] as String,
        idpersona: e['IDPERSONA'] as int,
      )).where((c) {
        try {
          final fechaCita = DateTime.parse(c.fecha);
          final fechaSolo = DateTime(fechaCita.year, fechaCita.month, fechaCita.day);
          return !fechaSolo.isBefore(hoySolo);
        } catch (_) {
          return false;
        }
      }).toList();

// Ordenar por fecha
      _citasHoy.sort((a, b) => a.fecha.compareTo(b.fecha));

    });
  }

  @override
  void initState() {
    super.initState();
    _cargarCitasHoy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _citasHoy.isEmpty
          ? Center(child: Text("No hay citas para hoy o posteriores"))
          : ListView.builder(
        itemCount: _citasHoy.length,
        itemBuilder: (ctx, i) {
          final c = _citasHoy[i];
          final persona = _personas.firstWhere(
                  (p) => p.idpersona == c.idpersona,
              orElse: () => Persona(nombre: "Desconocido", telefono: ""));
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              title: Text("${c.lugar} - ${c.fecha} ${c.hora}"),
              subtitle: Text("Persona: ${persona.nombre}\n${c.anotaciones}"),
              leading: Icon(Icons.today, color: Colors.deepPurple),
            ),
          );
        },
      ),
    );
  }
}

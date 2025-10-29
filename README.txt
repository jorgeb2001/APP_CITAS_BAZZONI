# Gestión de Citas y Personas

## Descripción
App en Flutter para registrar personas y sus citas. Incluye:
- Registro de personas.
- Registro de citas asociadas a personas.
- Pestaña "Hoy" que muestra citas de hoy y posteriores.

## Requisitos
- Flutter >= 3.0
- Dependencias:
  - sqflite
  - path

## Instrucciones
1. Clonar el repositorio.
2. Ejecutar `flutter pub get`.
3. Correr la app con `flutter run`.
4. Ingresar las fechas en formato `yyyy-MM-dd` (ej: 2025-10-28).

## Notas
- La base de datos se guarda localmente.
- La pestaña "Hoy" filtra y ordena automáticamente las citas de hoy en adelante.

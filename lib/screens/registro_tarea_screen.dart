import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../data/agenda_memoria.dart';
import '../logic/formato_fecha.dart';
import '../models/prioridad.dart';
import '../models/tarea.dart';
import '../widgets/encabezado_app.dart';
import '../widgets/selector_prioridad.dart';

/// Pantalla 2: formulario para capturar una tarea academica.
class RegistroTareaScreen extends StatefulWidget {
  const RegistroTareaScreen({super.key});

  @override
  State<RegistroTareaScreen> createState() => _RegistroTareaScreenState();
}

class _RegistroTareaScreenState extends State<RegistroTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _materia = TextEditingController();
  final _descripcion = TextEditingController();
  DateTime? _fecha;
  Prioridad? _prioridad;

  @override
  void dispose() {
    _titulo.dispose();
    _materia.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final seleccion = await showDatePicker(
      context: context,
      initialDate: _fecha ?? ahora,
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 3),
    );
    if (seleccion != null) {
      setState(() => _fecha = seleccion);
    }
  }

  void _guardar() {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido || _fecha == null || _prioridad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa titulo, materia, fecha y prioridad.'),
        ),
      );
      return;
    }

    if (FormatoFecha.soloDia(_fecha!).isBefore(FormatoFecha.soloDia(DateTime.now()))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Advertencia: la fecha ya vencio. Se guardara igual.'),
        ),
      );
    }

    final agenda = AgendaScope.of(context);
    agenda.agregar(
      Tarea(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _titulo.text.trim(),
        materia: _materia.text.trim(),
        descripcion: _descripcion.text.trim(),
        fechaEntrega: _fecha!,
        prioridad: _prioridad!,
      ),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tarea registrada'),
          content: const Text(
            'La tarea quedo en memoria. Puedes ver el resumen en Agenda.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacementNamed(context, Rutas.consulta);
              },
              child: const Text('Ver resultados'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EncabezadoApp(titulo: 'Crear tarea', mostrarAtras: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: 'Titulo',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El titulo es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _materia,
              decoration: const InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La materia es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcion,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripcion',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(
                _fecha == null
                    ? 'Seleccionar fecha de entrega'
                    : 'Entrega: ${FormatoFecha.largo(_fecha!)}',
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _elegirFecha,
            ),
            const SizedBox(height: 8),
            const Text(
              'Prioridad',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SelectorPrioridad(
              valor: _prioridad,
              onChanged: (value) => setState(() => _prioridad = value),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardar,
              child: const Text('Guardar tarea'),
            ),
          ],
        ),
      ),
    );
  }
}

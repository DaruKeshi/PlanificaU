import 'package:flutter/material.dart';

import '../app/rutas.dart';
import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../logic/formato_fecha.dart';
import '../models/materia.dart';
import '../models/prioridad.dart';
import '../models/tarea.dart';
import 'selector_prioridad.dart';

/// Formulario compartido por el registro y la edición de tareas.
class FormularioTarea extends StatefulWidget {
  const FormularioTarea({
    super.key,
    this.tarea,
    required this.guardar,
    required this.alGuardar,
  });

  final Tarea? tarea;
  final Future<void> Function(Tarea tarea) guardar;
  final VoidCallback alGuardar;

  @override
  State<FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<FormularioTarea> {
  static const String _crearMateria = '__crear_materia__';

  final _formKey = GlobalKey<FormState>();
  final _materiaKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _titulo = TextEditingController(
    text: widget.tarea?.titulo ?? '',
  );
  String? _materia;
  late final TextEditingController _descripcion = TextEditingController(
    text: widget.tarea?.descripcion ?? '',
  );
  DateTime? _fecha;
  Prioridad? _prioridad;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final materiaInicial = widget.tarea?.materia.trim() ?? '';
    _materia = materiaInicial.isEmpty ? null : materiaInicial;
    _fecha = widget.tarea?.fechaEntrega;
    _prioridad = widget.tarea?.prioridad;
  }

  @override
  void dispose() {
    _titulo.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: PlanificaUTheme.primario,
              surface: PlanificaUTheme.papel,
            ),
          ),
          child: child!,
        );
      },
    );
    if (seleccion != null) {
      setState(() => _fecha = seleccion);
    }
  }

  Future<void> _cambiarMateria(String? valor) async {
    if (valor == null) {
      setState(() => _materia = null);
      return;
    }
    if (valor == _crearMateria) {
      final resultado = await Navigator.of(context)
          .pushNamed(Rutas.registroMateria);
      if (!mounted || resultado is! Materia) return;
      final nombre = resultado.nombre.trim();
      if (nombre.isEmpty) return;
      setState(() => _materia = nombre);
      _materiaKey.currentState?.didChange(nombre);
      return;
    }
    setState(() => _materia = valor);
  }

  Future<void> _guardar() async {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido ||
        _materia == null ||
        _materia!.trim().isEmpty ||
        _fecha == null ||
        _prioridad == null) {
      _aviso('Revisa título, materia, fecha y prioridad.');
      return;
    }

    if (FormatoFecha.soloDia(_fecha!)
        .isBefore(FormatoFecha.soloDia(DateTime.now()))) {
      _aviso('La fecha ya venció. Se guardará igual.');
    }

    final tarea = Tarea(
      id: widget.tarea?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      materia: _materia!.trim(),
      descripcion: _descripcion.text.trim(),
      fechaEntrega: _fecha!,
      prioridad: _prioridad!,
      completada: widget.tarea?.completada ?? false,
    );

    setState(() => _guardando = true);
    try {
      await widget.guardar(tarea);
      if (mounted) widget.alGuardar();
    } catch (error) {
      if (mounted) _aviso(AgendaFirestore.mensaje(error), esError: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _aviso(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError
            ? PlanificaUTheme.prioridadAlta
            : PlanificaUTheme.tinta,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agenda = AgendaScope.of(context);
    final nombres = <String>{
      for (final materia in agenda.materias) materia.nombre.trim(),
    }..remove('');
    final actual = _materia?.trim();
    if (actual != null && actual.isNotEmpty) nombres.add(actual);
    final opciones = nombres.toList()..sort();

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth,
              height: 700,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.tarea == null
                          ? '¿Qué tienes que entregar?'
                          : 'Actualiza los datos de la tarea.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cuéntanos lo justo para no perder el plazo.',
                      style: TextStyle(color: PlanificaUTheme.tintaSuave),
                    ),
                    const SizedBox(height: 18),
                    _seccion('DETALLES', [
                      TextFormField(
                        controller: _titulo,
                        decoration: const InputDecoration(
                          labelText: 'Título de la tarea',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El título es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: _materiaKey,
                        initialValue:
                            actual != null && opciones.contains(actual)
                            ? actual
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Materia',
                          prefixIcon: Icon(Icons.menu_book_outlined),
                        ),
                        hint: const Text('Selecciona una materia'),
                        items: [
                          ...opciones.map(
                            (nombre) => DropdownMenuItem<String>(
                              value: nombre,
                              child: Text(nombre),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: _crearMateria,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: PlanificaUTheme.acento,
                                ),
                                SizedBox(width: 8),
                                Text('Nueva materia...'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: _cambiarMateria,
                        validator: (_) =>
                            _materia == null || _materia!.trim().isEmpty
                            ? 'La materia es obligatoria'
                            : null,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Las materias creadas aquí también quedan en Notas.',
                          style: TextStyle(
                            fontSize: 11,
                            color: PlanificaUTheme.tintaSuave,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descripcion,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _seccion('FECHA Y PRIORIDAD', [
                      Material(
                        color: PlanificaUTheme.papel,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _elegirFecha,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: PlanificaUTheme.borde),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: PlanificaUTheme.acentoSuave,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.event_rounded,
                                    color: PlanificaUTheme.acento,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Fecha de entrega',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: PlanificaUTheme.tintaSuave,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _fecha == null
                                            ? 'Seleccionar fecha'
                                            : FormatoFecha.largo(_fecha!),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Prioridad',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      SelectorPrioridad(
                        valor: _prioridad,
                        onChanged: (value) =>
                            setState(() => _prioridad = value),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _guardando
                            ? 'Guardando...'
                            : widget.tarea == null
                            ? 'Guardar tarea'
                            : 'Guardar cambios',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _seccion(String titulo, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: PlanificaUTheme.tintaSuave,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

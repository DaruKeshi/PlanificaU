import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/agenda_firestore.dart';
import '../models/corte.dart';
import '../models/materia.dart';

/// Formulario compartido para registrar y editar materias con sus cortes.
class FormularioMateria extends StatefulWidget {
  const FormularioMateria({
    super.key,
    this.materia,
    required this.guardar,
    required this.alGuardar,
  });

  final Materia? materia;
  final Future<void> Function(Materia materia) guardar;
  final ValueChanged<Materia> alGuardar;

  @override
  State<FormularioMateria> createState() => _FormularioMateriaState();
}

class _CorteControl {
  _CorteControl({
    this.id,
    required this.numero,
    required String nota,
    required String peso,
  }) : nota = TextEditingController(text: nota),
       peso = TextEditingController(text: peso);

  final String? id;
  final int numero;
  final TextEditingController nota;
  final TextEditingController peso;

  void dispose() {
    nota.dispose();
    peso.dispose();
  }
}

class _FormularioMateriaState extends State<FormularioMateria> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre = TextEditingController(
    text: widget.materia?.nombre ?? '',
  );
  late final TextEditingController _aprobacion = TextEditingController(
    text: _texto(
      widget.materia?.notaAprobacion ?? Materia.aprobacionPorDefecto,
    ),
  );
  late double _escala =
      widget.materia?.escalaMaxima ?? Materia.escalaPorDefecto;
  late final List<_CorteControl> _cortes = _controlesIniciales();
  bool _guardando = false;

  List<_CorteControl> _controlesIniciales() {
    final cortes =
        widget.materia?.cortes ?? Materia.crearCortes(Materia.cortesPorDefecto);
    final total = cortes.fold<double>(0, (suma, c) => suma + c.peso);
    final controles = cortes
        .map(
          (c) => _CorteControl(
            id: c.id,
            numero: c.numero,
            nota: c.nota == null ? '' : _texto(c.nota!),
            peso: _porcentajeTexto(
              total == 0 ? 100 / cortes.length : c.peso / total * 100,
            ),
          ),
        )
        .toList();

    if (controles.isNotEmpty) {
      final suma = controles.fold<double>(
        0,
        (valor, control) =>
            valor + (double.tryParse(_norm(control.peso.text)) ?? 0),
      );
      final ultimo = controles.last;
      final actual = double.tryParse(_norm(ultimo.peso.text)) ?? 0;
      final ajustado = actual + _redondear1(100 - suma);
      if (ajustado > 0 && ajustado <= 100) {
        ultimo.peso.text = _porcentajeTexto(ajustado);
      }
    }

    return controles;
  }

  static String _texto(double valor) =>
      valor % 1 == 0 ? valor.toInt().toString() : valor.toString();
  static String _porcentajeTexto(double valor) =>
      valor % 1 == 0 ? valor.toInt().toString() : valor.toStringAsFixed(1);
  static double _redondear1(double valor) => (valor * 10).roundToDouble() / 10;
  static String _norm(String texto) => texto.trim().replaceFirst(',', '.');

  double get _totalPorcentajes => _cortes.fold<double>(
    0,
    (suma, corte) => suma + (double.tryParse(_norm(corte.peso.text)) ?? 0),
  );

  /// Reparte 100% entre los cortes cuando cambia la cantidad.
  void _redistribuirPesos() {
    final cantidad = _cortes.length;
    final base = _redondear1(100 / cantidad);
    var asignado = 0.0;
    for (var i = 0; i < cantidad; i++) {
      final valor = i == cantidad - 1 ? _redondear1(100 - asignado) : base;
      _cortes[i].peso.text = _porcentajeTexto(valor);
      asignado += valor;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _aprobacion.dispose();
    for (final corte in _cortes) {
      corte.dispose();
    }
    super.dispose();
  }

  void _cambiarEscala(double? valor) {
    if (valor == null) return;
    setState(() {
      _escala = valor;
      final sugerida = (valor * 0.6 * 10).roundToDouble() / 10;
      _aprobacion.text = _texto(sugerida);
    });
  }

  void _agregarCorte() {
    if (_cortes.length >= Materia.maximoCortes) return;
    final numero = _cortes.length + 1;
    setState(() {
      _cortes.add(
        _CorteControl(id: 'corte-$numero', numero: numero, nota: '', peso: '0'),
      );
      _redistribuirPesos();
    });
  }

  void _quitarCorte() {
    if (_cortes.length <= Materia.minimoCortes) return;
    setState(() {
      _cortes.removeLast().dispose();
      _redistribuirPesos();
    });
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final aprobacion = double.tryParse(_norm(_aprobacion.text));
    if (aprobacion == null || aprobacion <= 0 || aprobacion > _escala) {
      _aviso('La nota de aprobación debe estar entre 0 y $_escala.');
      return;
    }

    final porcentajes = <double>[];
    for (var i = 0; i < _cortes.length; i++) {
      final porcentaje = double.tryParse(_norm(_cortes[i].peso.text));
      if (porcentaje == null || porcentaje <= 0 || porcentaje > 100) {
        _aviso('El peso del corte ${i + 1} debe estar entre 1 y 100%.');
        return;
      }
      porcentajes.add(porcentaje);
    }
    final total = porcentajes.fold<double>(0, (suma, p) => suma + p);
    if ((total - 100).abs() > 0.11) {
      _aviso(
        'Los pesos deben sumar 100% (ahora suman ${_porcentajeTexto(total)}%).',
      );
      return;
    }

    final cortes = <Corte>[];
    for (var i = 0; i < _cortes.length; i++) {
      final control = _cortes[i];
      final textoNota = _norm(control.nota.text);
      double? nota;
      if (textoNota.isNotEmpty) {
        nota = double.tryParse(textoNota);
        if (nota == null || nota < 0 || nota > _escala) {
          _aviso('La nota del corte ${i + 1} debe estar entre 0 y $_escala.');
          return;
        }
      }

      cortes.add(
        Corte(
          id: control.id ?? 'corte-${i + 1}',
          numero: i + 1,
          nombre: 'Corte ${i + 1}',
          peso: porcentajes[i] / 100,
          nota: nota,
        ),
      );
    }

    final materia = Materia(
      id:
          widget.materia?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: _nombre.text.trim(),
      escalaMaxima: _escala,
      notaAprobacion: aprobacion,
      cortes: cortes,
    );

    setState(() => _guardando = true);
    try {
      await widget.guardar(materia);
      if (mounted) widget.alGuardar(materia);
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
    final totalPesos = _totalPorcentajes;
    final pesosValidos = (totalPesos - 100).abs() <= 0.11;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
        children: [
          Text(
            widget.materia == null
                ? '¿Qué materia quieres seguir?'
                : 'Ajusta los cortes de ${widget.materia!.nombre}.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Define la escala, los cortes y qué porcentaje vale cada uno.',
            style: TextStyle(color: PlanificaUTheme.tintaSuave),
          ),
          const SizedBox(height: 24),
          _seccion('DATOS DE LA MATERIA', [
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre de la materia',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              initialValue: _escala,
              decoration: const InputDecoration(
                labelText: 'Escala de calificación',
                prefixIcon: Icon(Icons.tune_rounded),
              ),
              items: const [5.0, 10.0, 20.0, 100.0]
                  .map(
                    (valor) => DropdownMenuItem<double>(
                      value: valor,
                      child: Text('0 – ${_texto(valor)}'),
                    ),
                  )
                  .toList(),
              onChanged: _cambiarEscala,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _aprobacion,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Nota mínima para aprobar (de 0 a $_escala)',
                prefixIcon: const Icon(Icons.verified_outlined),
              ),
            ),
          ]),
          const SizedBox(height: 22),
          _seccion('CORTES Y PONDERACIÓN', [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: PlanificaUTheme.primarioSuave,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Número de cortes',
                    style: TextStyle(
                      color: PlanificaUTheme.primario,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _cortes.length > Materia.minimoCortes
                            ? _quitarCorte
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: PlanificaUTheme.primario,
                      ),
                      Text(
                        '${_cortes.length}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: PlanificaUTheme.primario,
                        ),
                      ),
                      IconButton(
                        onPressed: _cortes.length < Materia.maximoCortes
                            ? _agregarCorte
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: PlanificaUTheme.primario,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entre 2 y 10 cortes. El peso de cada corte se mide en porcentaje y deben sumar 100%.',
              style: TextStyle(fontSize: 12, color: PlanificaUTheme.tintaSuave),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Total de ponderación',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_porcentajeTexto(totalPesos)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: pesosValidos
                        ? PlanificaUTheme.primario
                        : PlanificaUTheme.prioridadAlta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._cortes.map(
              (corte) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: PlanificaUTheme.papel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PlanificaUTheme.borde),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: PlanificaUTheme.acentoSuave,
                            child: Text(
                              '${corte.numero}',
                              style: const TextStyle(
                                color: PlanificaUTheme.acento,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Corte ${corte.numero}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: corte.nota,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Nota',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: corte.peso,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Peso (%)',
                                suffixText: '%',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 28),
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
                  : widget.materia == null
                  ? 'Guardar materia'
                  : 'Guardar cambios',
            ),
          ),
        ],
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
